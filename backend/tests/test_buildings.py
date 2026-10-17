from __future__ import annotations

import math

import mapbox_vector_tile
from fastapi.testclient import TestClient
from shapely.geometry import box

from app.main import build_services, create_app
from app.solar.buildings import ZOOM, BuildingFootprints, _tile_of
from tests.conftest import AUTH, FakeExtractor, FakeNasa, make_settings

LAT, LON = 23.8, 90.4
FX, FY = _tile_of(LAT, LON, ZOOM)
TX, TY = math.floor(FX), math.floor(FY)
# the point in tile pixels (extent 4096)
PX, PY = (FX - TX) * 4096, (FY - TY) * 4096


def _tile(features: list[tuple[str, object, str]]) -> bytes:
    return mapbox_vector_tile.encode(
        [{"name": "building", "features": [{"geometry": g, "properties": {"id": i, "@geometry_source": s}} for i, g, s in features]}],
        default_options={"y_coord_down": True},
    )


def _finder() -> tuple[BuildingFootprints, list[tuple[int, int, int]]]:
    big = box(PX - 300, PY - 300, PX + 300, PY + 300)  # ~60 m square around the point
    shed = box(PX - 50, PY - 50, PX + 50, PY + 50)  # a smaller shed inside it
    far = box(PX + 2000, PY + 2000, PX + 2100, PY + 2100)  # hundreds of metres away
    # a building cut by the tile edge: half in this tile, half in the next one east
    left = box(4096 - 100, PY - 100, 4096, PY + 100)
    right = box(0, PY - 100, 100, PY + 100)
    tiles = {
        (ZOOM, TX, TY): _tile([("big", big, "Google Open Buildings"), ("shed", shed, "OpenStreetMap"), ("far", far, "OpenStreetMap"), ("cut", left, "Microsoft ML Buildings")]),
        (ZOOM, TX + 1, TY): _tile([("cut", right, "Microsoft ML Buildings")]),
    }
    calls: list[tuple[int, int, int]] = []

    def source(z: int, x: int, y: int) -> bytes | None:
        calls.append((z, x, y))
        return tiles.get((z, x, y))

    return BuildingFootprints(tile_source=source), calls


def test_containing_building_first_smallest_wins_far_ones_dropped() -> None:
    finder, _ = _finder()
    found = finder.near(LAT, LON, radius_m=150)
    assert [b.source for b in found[:2]] == ["OpenStreetMap", "Google Open Buildings"]  # shed inside big shed first
    assert found[0].distance_m == 0 and found[1].distance_m == 0
    assert found[0].area_m2 < found[1].area_m2
    assert all(b.distance_m <= 150 for b in found)
    assert len(found[0].ring) == 4


def test_building_cut_by_tile_edge_is_joined_again() -> None:
    finder, calls = _finder()
    # stand right at the east edge of the tile so the neighbour tile is read too
    lon_edge = (TX + 1) / 2**ZOOM * 360 - 180 - 1e-6
    found = finder.near(LAT, lon_edge, radius_m=40)
    cut = [b for b in found if b.source == "Microsoft ML Buildings"]
    assert len(cut) == 1
    assert (ZOOM, TX + 1, TY) in calls
    single_half = finder.near(LAT, LON, radius_m=150)  # cached tiles, same answer
    assert single_half


def test_endpoint_returns_outlines_and_attribution() -> None:
    finder, _ = _finder()
    svc = build_services(make_settings(), extractor=FakeExtractor(), nasa=FakeNasa(), buildings=finder)
    client = TestClient(create_app(svc), raise_server_exceptions=False)
    r = client.get("/v1/solar/buildings", params={"lat": LAT, "lon": LON}, headers=AUTH)
    assert r.status_code == 200
    body = r.json()
    assert "Overture" in body["attribution"] and "OpenStreetMap" in body["attribution"]
    first = body["buildings"][0]
    assert first["distance_m"] == 0 and len(first["polygon"]) == 4
    assert abs(first["polygon"][0]["lat"] - LAT) < 0.001 and abs(first["polygon"][0]["lon"] - LON) < 0.001
    assert client.get("/v1/solar/buildings", params={"lat": 100, "lon": LON}, headers=AUTH).status_code == 422
    assert client.get("/v1/solar/buildings", params={"lat": LAT, "lon": LON}).status_code == 401
