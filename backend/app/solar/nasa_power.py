"""NASA POWER monthly climatology of all-sky surface shortwave downward irradiance.

Endpoint (checked 2026-10-10, POWER API v2.10.1):
  GET https://power.larc.nasa.gov/api/temporal/climatology/point
      ?parameters=ALLSKY_SFC_SW_DWN&community=RE&longitude=..&latitude=..&format=JSON
Response: properties.parameter.ALLSKY_SFC_SW_DWN = {JAN..DEC, ANN} in kW-hr/m^2/day
(numerically equal to peak sun hours). Missing values use header.fill_value (-999).
"""

from __future__ import annotations

import json
import logging
import threading
from pathlib import Path
from typing import Any

import httpx

from app.security import ApiError

logger = logging.getLogger(__name__)

POWER_URL = "https://power.larc.nasa.gov/api/temporal/climatology/point"
PARAMETER = "ALLSKY_SFC_SW_DWN"
MONTH_KEYS = ("JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC")
ROUND_DEGREES = 2  # ~1 km; POWER's native grid is far coarser


class NasaPowerClient:
    def __init__(self, timeout_s: float, cache_dir: Path | None = None, http: httpx.Client | None = None) -> None:
        self._timeout_s = timeout_s
        self._cache_dir = cache_dir
        self._http = http
        self._memory: dict[tuple[float, float], list[float]] = {}
        self._lock = threading.Lock()

    @staticmethod
    def cache_key(lat: float, lon: float) -> tuple[float, float]:
        return round(lat, ROUND_DEGREES), round(lon, ROUND_DEGREES)

    def _disk_path(self, key: tuple[float, float]) -> Path | None:
        if self._cache_dir is None:
            return None
        return self._cache_dir / f"power_{key[0]:.2f}_{key[1]:.2f}.json"

    def monthly_peak_sun_hours(self, lat: float, lon: float) -> list[float]:
        key = self.cache_key(lat, lon)
        with self._lock:
            if key in self._memory:
                return list(self._memory[key])
        path = self._disk_path(key)
        if path and path.exists():
            try:
                values = json.loads(path.read_text(encoding="utf-8"))
                if isinstance(values, list) and len(values) == 12:
                    with self._lock:
                        self._memory[key] = [float(v) for v in values]
                    return [float(v) for v in values]
            except (OSError, ValueError):
                logger.warning("nasa_cache_unreadable")
        values = self._fetch(*key)
        with self._lock:
            self._memory[key] = values
        if path:
            try:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(json.dumps(values), encoding="utf-8")
            except OSError:
                logger.warning("nasa_cache_write_failed")
        return list(values)

    def _fetch(self, lat: float, lon: float) -> list[float]:
        params = {"parameters": PARAMETER, "community": "RE", "longitude": lon, "latitude": lat, "format": "JSON"}
        try:
            if self._http is not None:
                resp = self._http.get(POWER_URL, params=params, timeout=self._timeout_s)
            else:
                resp = httpx.get(POWER_URL, params=params, timeout=self._timeout_s)
            resp.raise_for_status()
            return parse_power_response(resp.json())
        except httpx.TimeoutException as e:
            raise ApiError(504, "irradiance_timeout", "NASA POWER did not respond in time. Enter peak sun hours manually or try again.") from e
        except (httpx.HTTPError, ValueError) as e:
            logger.warning("nasa_power_failed type=%s", type(e).__name__)
            raise ApiError(502, "irradiance_unavailable", "Could not get solar irradiance from NASA POWER. Enter peak sun hours manually or try again.") from e


def parse_power_response(body: Any) -> list[float]:
    try:
        series = body["properties"]["parameter"][PARAMETER]
        fill = float(body.get("header", {}).get("fill_value", -999.0))
        values = [float(series[k]) for k in MONTH_KEYS]
    except (KeyError, TypeError) as e:
        raise ValueError("unexpected NASA POWER response shape") from e
    if any(v == fill or v < 0 for v in values):
        raise ValueError("NASA POWER returned missing values for this location")
    return values
