from __future__ import annotations

import math
from collections.abc import Callable
from pathlib import Path
from typing import Any

import httpx
import pytest

from app.schemas import ConsumptionMonth, LatLon, SolarParamOverrides
from app.security import ApiError
from app.settings import DEFAULT_CONFIG_DIR, load_app_config
from app.solar.geometry import roof_geometry
from app.solar.model import DISCLAIMER, estimate, resolve_params
from app.solar.nasa_power import NasaPowerClient, parse_power_response
from tests.conftest import AUTH, FakeNasa, make_client

CONFIG = load_app_config(DEFAULT_CONFIG_DIR)
DHAKA = (23.8103, 90.4125)


def square(side_m: float, lat: float = DHAKA[0], lon: float = DHAKA[1]) -> list[LatLon]:
    dlat = side_m / 111_320.0
    dlon = side_m / (111_320.0 * math.cos(math.radians(lat)))
    return [LatLon(lat=lat, lon=lon), LatLon(lat=lat, lon=lon + dlon), LatLon(lat=lat + dlat, lon=lon + dlon), LatLon(lat=lat + dlat, lon=lon)]


def run(area: float, psh: float, overrides: SolarParamOverrides, consumption: list[ConsumptionMonth] | None = None, factors: Any = None) -> Any:
    params = resolve_params(overrides, CONFIG.solar_defaults, consumption or [])
    return estimate(
        area_m2=area,
        centroid=LatLon(lat=DHAKA[0], lon=DHAKA[1]),
        psh_monthly=[psh] * 12,
        irradiance_source="manual",
        params=params,
        consumption=consumption or [],
        factors=factors or CONFIG.emission_factors,
    )


def test_spec_example_131400_kwh() -> None:
    r = run(1000, 4.5, SolarParamOverrides(usable_roof_fraction=0.7, m2_per_kwp=7, performance_ratio=0.8))
    assert r.kwp == pytest.approx(100)
    assert r.annual_generation_kwh == pytest.approx(131_400, abs=0.5)
    assert r.disclaimer == DISCLAIMER
    assert r.financials is None  # no capex -> no financials


def test_defaults_are_used_and_labelled() -> None:
    r = run(1000, 4.5, SolarParamOverrides())
    assert r.kwp == pytest.approx(1000 * 0.6 / 7, abs=1e-3)
    used = {p.name: p for p in r.params_used}
    assert used["usable_roof_fraction"].origin == "default" and used["usable_roof_fraction"].status == "verified"
    assert used["capex_bdt_per_kwp"].status == "PLACEHOLDER"
    assert used["capex_bdt_per_kwp"].value is None


def test_geometry_area_of_square() -> None:
    g = roof_geometry(square(40), 20, 500_000)
    assert g.area_m2 == pytest.approx(1600, rel=0.01)
    assert g.centroid.lat == pytest.approx(DHAKA[0] + 20 / 111_320, abs=1e-5)


def test_geometry_rejects_self_intersection_and_small() -> None:
    p = square(40)
    bowtie = [p[0], p[2], p[1], p[3]]
    with pytest.raises(ApiError) as e:
        roof_geometry(bowtie, 20, 500_000)
    assert e.value.code == "invalid_polygon"
    with pytest.raises(ApiError) as e:
        roof_geometry(square(3), 20, 500_000)
    assert e.value.code == "polygon_too_small"
    with pytest.raises(ApiError) as e:
        roof_geometry([p[0], p[1], p[0]], 20, 500_000)
    assert e.value.code == "invalid_polygon"


def test_self_consumption_capped_without_net_metering() -> None:
    cons = [ConsumptionMonth(month=f"2024-{m:02d}", kwh=5000) for m in range(1, 13)]
    r = run(1000, 4.5, SolarParamOverrides(usable_roof_fraction=0.7, m2_per_kwp=7, performance_ratio=0.8), cons)
    assert r.annual_consumption_kwh == pytest.approx(60_000)
    assert r.self_consumed_kwh == pytest.approx(60_000)
    assert r.exported_kwh == 0
    assert r.offset_share == pytest.approx(1.0)
    assert any(w.code == "excess_not_counted" and w.value for w in r.warnings)


def test_co2_avoided_needs_grid_factor(config_dir_factory: Callable[..., Path]) -> None:
    cons = [ConsumptionMonth(month=f"2024-{m:02d}", kwh=50_000) for m in range(1, 13)]
    unset = load_app_config(config_dir_factory(grid_electricity=None)).emission_factors
    r = run(1000, 4.5, SolarParamOverrides(usable_roof_fraction=0.7, m2_per_kwp=7, performance_ratio=0.8), cons, unset)
    assert r.co2_avoided_t_per_year is None
    assert any(w.code == "grid_factor_not_set" for w in r.warnings)
    factors = load_app_config(config_dir_factory(grid_electricity=0.5)).emission_factors
    r2 = run(1000, 4.5, SolarParamOverrides(usable_roof_fraction=0.7, m2_per_kwp=7, performance_ratio=0.8), cons, factors)
    assert r2.co2_avoided_t_per_year == pytest.approx(131_400 * 0.5 / 1000, rel=1e-4)


def test_financials_with_capex() -> None:
    cons = [ConsumptionMonth(month=f"2024-{m:02d}", kwh=50_000, cost_bdt=500_000) for m in range(1, 13)]
    o = SolarParamOverrides(usable_roof_fraction=0.7, m2_per_kwp=7, performance_ratio=0.8, degradation_per_year=0.0, capex_bdt_per_kwp=50_000, om_fraction_of_capex_per_year=0.01)
    r = run(1000, 4.5, o, cons)
    f = r.financials
    assert f is not None
    assert f.electricity_price_bdt_per_kwh == pytest.approx(10.0)
    assert f.capex_bdt == pytest.approx(5_000_000)
    assert f.year1_savings_bdt == pytest.approx(1_314_000)
    assert f.year1_om_bdt == pytest.approx(50_000)
    assert f.simple_payback_years == pytest.approx(5_000_000 / 1_264_000, abs=0.01)
    assert len(f.cashflow) == 26 and f.cashflow[0].cumulative_bdt == -5_000_000
    assert f.cashflow[-1].cumulative_bdt == pytest.approx(-5_000_000 + 25 * 1_264_000, abs=30)


def test_financials_need_price() -> None:
    cons = [ConsumptionMonth(month=f"2024-{m:02d}", kwh=50_000) for m in range(1, 13)]
    r = run(1000, 4.5, SolarParamOverrides(capex_bdt_per_kwp=50_000), cons)
    assert r.financials is None
    assert any(w.code == "price_missing" for w in r.warnings)


def test_parse_power_response_and_fill_value() -> None:
    body = {"header": {"fill_value": -999.0}, "properties": {"parameter": {"ALLSKY_SFC_SW_DWN": {k: 4.0 for k in ("JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC")}}}}
    assert parse_power_response(body) == [4.0] * 12
    body["properties"]["parameter"]["ALLSKY_SFC_SW_DWN"]["MAR"] = -999.0
    with pytest.raises(ValueError):
        parse_power_response(body)
    with pytest.raises(ValueError):
        parse_power_response({"nope": 1})


def _power_transport(counter: list[int], status: int = 200) -> httpx.MockTransport:
    def handler(request: httpx.Request) -> httpx.Response:
        counter.append(1)
        assert request.url.params["parameters"] == "ALLSKY_SFC_SW_DWN"
        assert request.url.params["community"] == "RE"
        months = ("JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC")
        return httpx.Response(status, json={"header": {"fill_value": -999}, "properties": {"parameter": {"ALLSKY_SFC_SW_DWN": {m: 5.0 for m in months}}}})

    return httpx.MockTransport(handler)


def test_nasa_client_caches_by_rounded_location(tmp_path: Path) -> None:
    calls: list[int] = []
    client = NasaPowerClient(5, cache_dir=tmp_path, http=httpx.Client(transport=_power_transport(calls)))
    assert client.monthly_peak_sun_hours(23.81031, 90.41249) == [5.0] * 12
    assert client.monthly_peak_sun_hours(23.81039, 90.41201) == [5.0] * 12
    assert len(calls) == 1
    fresh = NasaPowerClient(5, cache_dir=tmp_path, http=httpx.Client(transport=_power_transport(calls)))
    assert fresh.monthly_peak_sun_hours(23.81, 90.41) == [5.0] * 12
    assert len(calls) == 1  # served from disk cache


def test_nasa_client_errors_are_clear() -> None:
    client = NasaPowerClient(5, http=httpx.Client(transport=_power_transport([], status=500)))
    with pytest.raises(ApiError) as e:
        client.monthly_peak_sun_hours(23.8, 90.4)
    assert e.value.code == "irradiance_unavailable"

    def timeout(_: httpx.Request) -> httpx.Response:
        raise httpx.ReadTimeout("slow")

    client = NasaPowerClient(5, http=httpx.Client(transport=httpx.MockTransport(timeout)))
    with pytest.raises(ApiError) as e:
        client.monthly_peak_sun_hours(23.8, 90.4)
    assert e.value.code == "irradiance_timeout"


def _poly_json(side: float) -> list[dict[str, float]]:
    return [p.model_dump() for p in square(side)]


def test_endpoint_with_nasa_and_manual() -> None:
    nasa = FakeNasa([4.0] * 12)
    c, _ = make_client(nasa=nasa)
    r = c.post("/v1/solar/estimate", headers=AUTH, json={"polygon": _poly_json(40)})
    assert r.status_code == 200, r.text
    assert r.json()["irradiance_source"] == "nasa_power" and nasa.calls == 1
    r = c.post("/v1/solar/estimate", headers=AUTH, json={"polygon": _poly_json(40), "manual_peak_sun_hours": 5})
    assert r.json()["irradiance_source"] == "manual" and nasa.calls == 1


def test_endpoint_invalid_polygon_422() -> None:
    c, _ = make_client()
    p = _poly_json(40)
    r = c.post("/v1/solar/estimate", headers=AUTH, json={"polygon": [p[0], p[2], p[1], p[3]]})
    assert r.status_code == 422 and r.json()["error"]["code"] == "invalid_polygon"


def test_defaults_endpoint() -> None:
    c, _ = make_client()
    body = c.get("/v1/solar/defaults", headers=AUTH).json()
    names = {p["name"]: p for p in body["params"]}
    assert names["usable_roof_fraction"]["value"] == 0.6
    assert names["m2_per_kwp"]["value"] == 7
    assert names["performance_ratio"]["value"] == 0.78
    assert body["net_metering"] is False
