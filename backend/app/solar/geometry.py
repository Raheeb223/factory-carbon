"""Roof polygon geometry: geodesic area and centroid."""

from __future__ import annotations

from dataclasses import dataclass

from pyproj import Geod
from shapely.geometry import Polygon
from shapely.validation import explain_validity

from app.schemas import LatLon
from app.security import ApiError

_GEOD = Geod(ellps="WGS84")


@dataclass(frozen=True)
class RoofGeometry:
    area_m2: float
    centroid: LatLon


def roof_geometry(points: list[LatLon], min_area_m2: float, max_area_m2: float) -> RoofGeometry:
    coords = [(p.lon, p.lat) for p in points]
    if len(coords) > 1 and coords[0] == coords[-1]:
        coords = coords[:-1]
    if len(set(coords)) < 3:
        raise ApiError(422, "invalid_polygon", "The roof outline needs at least 3 distinct corners.")
    poly = Polygon(coords)
    if not poly.is_valid:
        reason = explain_validity(poly)
        raise ApiError(422, "invalid_polygon", f"The roof outline is not a valid shape (edges cross or overlap): {reason}.")
    area, _perimeter = _GEOD.geometry_area_perimeter(poly)
    area = abs(area)
    if area < min_area_m2:
        raise ApiError(422, "polygon_too_small", f"The roof outline is only {area:.0f} m2; draw at least {min_area_m2:.0f} m2.")
    if area > max_area_m2:
        raise ApiError(422, "polygon_too_large", f"The roof outline is {area:,.0f} m2, larger than the {max_area_m2:,.0f} m2 limit.")
    c = poly.centroid
    return RoofGeometry(area_m2=area, centroid=LatLon(lat=c.y, lon=c.x))
