"""Building outlines near a point, for suggesting the roof on the solar map.

Source: Overture Maps buildings (checked 2026-10-17, release 2026-09-23.1), published as one
PMTiles archive of Mapbox vector tiles (z0-14, gzip, layer "building"):
  https://tiles.overturemaps.org/<release>/buildings.pmtiles
The latest release's archive is listed in the STAC catalog (https://stac.overturemaps.org/catalog.json,
"latest" -> <release>/buildings/catalog.json, link rel "pmtiles"). Overture merges OpenStreetMap
with Google Open Buildings and Microsoft ML footprints, so most roofs in Bangladesh have an
outline even where OpenStreetMap has none. Licence ODbL; attribution below must be shown.

Only the z14 tile(s) around the point are read, with HTTP range requests (a few hundred kB).
"""

from __future__ import annotations

import gzip
import logging
import math
import threading
import time
from collections import OrderedDict
from collections.abc import Callable
from dataclasses import dataclass
from typing import Any

import httpx
import mapbox_vector_tile
from pmtiles.reader import Reader
from shapely.geometry import MultiPolygon, Point, Polygon, shape
from shapely.ops import unary_union

from app.security import ApiError

logger = logging.getLogger(__name__)

STAC_ROOT = "https://stac.overturemaps.org"
DEFAULT_URL = "https://tiles.overturemaps.org/2026-09-23.1/buildings.pmtiles"
ATTRIBUTION = "Building outlines © OpenStreetMap contributors, Overture Maps Foundation (incl. Google Open Buildings, Microsoft ML footprints)"
ZOOM = 14
LAYER = "building"
URL_TTL_S = 12 * 3600
EARTH_M_PER_DEG = 6371008.8 * math.pi / 180

LonLat = tuple[float, float]


@dataclass(frozen=True)
class Building:
    ring: list[LonLat]  # outer ring, lon/lat, not closed
    area_m2: float
    distance_m: float  # 0 when the point is inside
    source: str


def _tile_of(lat: float, lon: float, z: int) -> tuple[float, float]:
    """Fractional tile x, y (Web Mercator, y down)."""
    n = 2**z
    r = math.radians(lat)
    return (lon + 180) / 360 * n, (1 - math.log(math.tan(r) + 1 / math.cos(r)) / math.pi) / 2 * n


def _lonlat(tx: float, ty: float, z: int) -> LonLat:
    n = 2**z
    return tx / n * 360 - 180, math.degrees(math.atan(math.sinh(math.pi * (1 - 2 * ty / n))))


class BuildingFootprints:
    def __init__(
        self,
        timeout_s: float = 15.0,
        url: str | None = None,
        http: httpx.Client | None = None,
        tile_source: Callable[[int, int, int], bytes | None] | None = None,
    ) -> None:
        self._timeout_s = timeout_s
        self._fixed_url = url
        self._http = http or httpx.Client(timeout=timeout_s, follow_redirects=True, headers={"User-Agent": "BillToGreen/0.1"})
        self._tile_source = tile_source  # tests inject decoded-tile bytes here
        self._url: str | None = None
        self._url_at = 0.0
        self._ranges: OrderedDict[tuple[str, int, int], bytes] = OrderedDict()
        self._tiles: OrderedDict[tuple[int, int, int], list[tuple[str, Polygon, str]]] = OrderedDict()
        self._lock = threading.Lock()

    # -- archive location ---------------------------------------------------------------

    def _archive_url(self) -> str:
        if self._fixed_url:
            return self._fixed_url
        if self._url and time.monotonic() - self._url_at < URL_TTL_S:
            return self._url
        url = DEFAULT_URL
        try:
            latest = self._http.get(f"{STAC_ROOT}/catalog.json").json()["latest"]
            links = self._http.get(f"{STAC_ROOT}/{latest}/buildings/catalog.json").json()["links"]
            url = next(link["href"] for link in links if link.get("rel") == "pmtiles")
        except (httpx.HTTPError, ValueError, KeyError, StopIteration, TypeError):
            logger.warning("overture_stac_unavailable; using %s", DEFAULT_URL)
        self._url, self._url_at = url, time.monotonic()
        return url

    # -- tiles ----------------------------------------------------------------------------

    def _get_bytes(self, url: str, offset: int, length: int) -> bytes:
        key = (url, offset, length)
        with self._lock:
            if key in self._ranges:
                self._ranges.move_to_end(key)
                return self._ranges[key]
        resp = self._http.get(url, headers={"Range": f"bytes={offset}-{offset + length - 1}"})
        resp.raise_for_status()
        data = resp.content
        with self._lock:
            self._ranges[key] = data
            while len(self._ranges) > 64:
                self._ranges.popitem(last=False)
        return data

    def _raw_tile(self, z: int, x: int, y: int) -> bytes | None:
        if self._tile_source is not None:
            return self._tile_source(z, x, y)
        url = self._archive_url()
        return Reader(lambda offset, length: self._get_bytes(url, offset, length)).get(z, x, y)

    def _tile(self, z: int, x: int, y: int) -> list[tuple[str, Polygon, str]]:
        """(feature id, polygon in lon/lat, geometry source) for every building in the tile."""
        key = (z, x, y)
        with self._lock:
            if key in self._tiles:
                self._tiles.move_to_end(key)
                return self._tiles[key]
        raw = self._raw_tile(z, x, y)
        out: list[tuple[str, Polygon, str]] = []
        if raw:
            if raw[:2] == b"\x1f\x8b":
                raw = gzip.decompress(raw)
            layer = mapbox_vector_tile.decode(raw, default_options={"y_coord_down": True}).get(LAYER, {})
            extent = float(layer.get("extent", 4096))

            def to_ll(c: Any) -> list[LonLat]:
                return [_lonlat(x + px / extent, y + py / extent, z) for px, py in c]

            for i, f in enumerate(layer.get("features", [])):
                g = f.get("geometry") or {}
                props = f.get("properties") or {}
                polys = [g["coordinates"]] if g.get("type") == "Polygon" else g.get("coordinates", []) if g.get("type") == "MultiPolygon" else []
                for rings in polys:
                    if not rings or len(rings[0]) < 3:
                        continue
                    p = Polygon(to_ll(rings[0]), [to_ll(r) for r in rings[1:] if len(r) >= 3])
                    if p.is_valid and not p.is_empty:
                        out.append((str(props.get("id") or f"{key}:{i}"), p, str(props.get("@geometry_source") or "Overture")))
        with self._lock:
            self._tiles[key] = out
            while len(self._tiles) > 24:
                self._tiles.popitem(last=False)
        return out

    # -- query ----------------------------------------------------------------------------

    def near(self, lat: float, lon: float, radius_m: float = 150.0) -> list[Building]:
        """Buildings within [radius_m] of the point, the one containing it first, then nearest."""
        fx, fy = _tile_of(lat, lon, ZOOM)
        # metres per tile at this latitude, to know which neighbouring tiles the radius reaches
        tile_m = EARTH_M_PER_DEG * 360 / 2**ZOOM * math.cos(math.radians(lat))
        r_tiles = radius_m / tile_m
        xs = range(math.floor(fx - r_tiles), math.floor(fx + r_tiles) + 1)
        ys = range(math.floor(fy - r_tiles), math.floor(fy + r_tiles) + 1)
        try:
            features = [f for x in xs for y in ys for f in self._tile(ZOOM, x, y)]
        except httpx.TimeoutException as e:
            raise ApiError(504, "buildings_timeout", "The building outline service did not respond in time. Tap the roof corners instead.") from e
        except (httpx.HTTPError, ValueError, OSError) as e:
            logger.warning("buildings_failed type=%s", type(e).__name__)
            raise ApiError(502, "buildings_unavailable", "Could not load building outlines. Tap the roof corners instead.") from e

        # Vector tiles cut buildings at tile edges: join the pieces of each building again.
        parts: dict[str, list[Polygon]] = {}
        sources: dict[str, str] = {}
        for fid, poly, source in features:
            parts.setdefault(fid, []).append(poly)
            sources[fid] = source

        k_lon = EARTH_M_PER_DEG * math.cos(math.radians(lat))

        def metres(p: Polygon) -> Polygon:
            return Polygon([((x - lon) * k_lon, (y - lat) * EARTH_M_PER_DEG) for x, y in p.exterior.coords])

        here = Point(0, 0)
        found: list[Building] = []
        for fid, polys in parts.items():
            merged = unary_union(polys) if len(polys) > 1 else polys[0]
            if isinstance(merged, MultiPolygon):
                merged = max(merged.geoms, key=lambda g: g.area)
            if not isinstance(merged, Polygon) or merged.is_empty:
                continue
            m = metres(merged)
            dist = m.distance(here)
            if dist > radius_m:
                continue
            simple = merged.simplify(0.3 / EARTH_M_PER_DEG, preserve_topology=True)
            ring = list(shape(simple).exterior.coords)[:-1] if isinstance(simple, Polygon) else list(merged.exterior.coords)[:-1]
            if len(ring) < 3 or len(ring) > 200:
                continue
            found.append(Building(ring=[(x, y) for x, y in ring], area_m2=m.area, distance_m=dist, source=sources[fid]))
        found.sort(key=lambda b: (b.distance_m > 0, b.distance_m if b.distance_m > 0 else b.area_m2))
        return found
