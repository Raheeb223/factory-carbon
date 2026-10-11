from __future__ import annotations

from collections.abc import Callable
from pathlib import Path

import pytest

from app.carbon.calculator import calculate, month_range
from app.schemas import CarbonCalculateRequest
from app.settings import load_app_config
from tests.conftest import AUTH, make_client

GRID = 0.6  # test-only value, not a real factor


def bill(month: str, kind: str, qty: float, **kw: object) -> dict[str, object]:
    unit = {"electricity": "kWh", "diesel": "litre", "gas": "m3"}[kind]
    return {"billing_month": month, "bill_type": kind, "consumed_units": qty, "unit": unit, **kw}


def req(bills: list[dict[str, object]], production: list[dict[str, object]] | None = None, **kw: object) -> CarbonCalculateRequest:
    return CarbonCalculateRequest.model_validate({"bills": bills, "production": production or [], **kw})


@pytest.fixture
def factors_with_grid(config_dir_factory: Callable[..., Path]):  # type: ignore[no-untyped-def]
    return load_app_config(config_dir_factory(grid_electricity=GRID)).emission_factors


@pytest.fixture
def factors_default():  # type: ignore[no-untyped-def]
    from app.settings import DEFAULT_CONFIG_DIR

    return load_app_config(DEFAULT_CONFIG_DIR).emission_factors


def test_month_range_crosses_year() -> None:
    assert month_range("2023-11", "2024-02") == ["2023-11", "2023-12", "2024-01", "2024-02"]


def test_scope2_and_scope1_values(factors_with_grid) -> None:  # type: ignore[no-untyped-def]
    r = calculate(req([bill("2024-01", "electricity", 10_000), bill("2024-01", "diesel", 100), bill("2024-01", "gas", 1000)]), factors_with_grid)
    m = r.months[0]
    assert m.scope2_t == pytest.approx(10_000 * GRID / 1000)
    assert m.scope1_diesel_t == pytest.approx(100 * factors_with_grid.diesel.value / 1000)
    assert m.scope1_gas_t == pytest.approx(1000 * factors_with_grid.natural_gas.value / 1000)
    assert m.scope1_t == pytest.approx(m.scope1_diesel_t + m.scope1_gas_t)
    assert m.total_t == pytest.approx(m.scope1_t + m.scope2_t)
    assert m.is_complete
    assert r.errors == []
    assert r.placeholders_in_use == []


def test_missing_months_are_null_not_zero(factors_with_grid) -> None:  # type: ignore[no-untyped-def]
    r = calculate(req([bill("2024-01", "electricity", 1000), bill("2024-03", "electricity", 1000)]), factors_with_grid)
    assert [m.month for m in r.months] == ["2024-01", "2024-02", "2024-03"]
    feb = r.months[1]
    assert feb.electricity_kwh is None and feb.scope2_t is None and feb.total_t is None
    assert not feb.is_complete and feb.missing == ["electricity:no_data"]
    codes = {n.code: n for n in r.data_quality_notes}
    assert codes["missing_electricity_data"].months == ["2024-02"]
    assert r.totals.months_with_data == 2 and r.totals.months_in_period == 3


def test_grid_factor_not_set_gives_clear_error(config_dir_factory: Callable[..., Path]) -> None:
    factors = load_app_config(config_dir_factory(grid_electricity=None)).emission_factors
    r = calculate(req([bill("2024-01", "electricity", 1000), bill("2024-01", "diesel", 50)]), factors)
    assert [e.code for e in r.errors] == ["factor_not_set"]
    assert r.errors[0].factor == "grid_electricity"
    m = r.months[0]
    assert m.scope2_t is None
    assert m.scope1_t == pytest.approx(50 * factors.diesel.value / 1000, abs=1e-6)
    assert not m.is_complete and "electricity:factor_not_set" in m.missing
    assert r.factors["grid_electricity"].value is None
    assert r.factors["grid_electricity"].status == "PLACEHOLDER"


def test_untracked_source_not_reported_missing(factors_with_grid) -> None:  # type: ignore[no-untyped-def]
    r = calculate(req([bill("2024-01", "electricity", 1000)]), factors_with_grid)
    assert r.months[0].is_complete
    assert r.months[0].diesel_litres is None
    assert "diesel" not in r.placeholders_in_use


def test_intensity_only_for_complete_months_with_production(factors_with_grid) -> None:  # type: ignore[no-untyped-def]
    r = calculate(
        req(
            [bill("2024-01", "electricity", 10_000), bill("2024-02", "electricity", 20_000)],
            [{"month": "2024-01", "units_produced": 50_000}],
            production_unit_label="pieces",
        ),
        factors_with_grid,
    )
    jan, feb = r.months
    assert jan.intensity_t_per_1000_units == pytest.approx(6.0 / 50_000 * 1000)
    assert feb.intensity_t_per_1000_units is None
    assert r.totals.intensity_t_per_1000_units == pytest.approx(jan.intensity_t_per_1000_units)
    assert any(n.code == "missing_production" for n in r.data_quality_notes)


def test_quality_notes_for_origins_and_edits(factors_with_grid) -> None:  # type: ignore[no-untyped-def]
    r = calculate(
        req([
            bill("2024-01", "electricity", 1000, user_edited_fields=["consumed_units"]),
            bill("2024-02", "electricity", 1000, origin="imported"),
            bill("2024-03", "electricity", 1000, origin="demo"),
            bill("2024-03", "electricity", 500, origin="manual"),
        ]),
        factors_with_grid,
    )
    codes = {n.code: n.months for n in r.data_quality_notes}
    assert codes["user_edited_values"] == ["2024-01"]
    assert codes["imported_history"] == ["2024-02"]
    assert codes["synthetic_data"] == ["2024-03"]
    assert codes["manual_entries"] == ["2024-03"]
    assert codes["multiple_entries_same_month"] == ["2024-03"]
    assert "placeholder_factors" not in codes  # all factors verified
    assert r.months[2].electricity_kwh == 1500


def test_placeholder_factor_is_reported(config_dir_factory: Callable[..., Path]) -> None:
    factors = load_app_config(config_dir_factory(statuses={"diesel": "PLACEHOLDER"})).emission_factors
    r = calculate(req([bill("2024-01", "diesel", 10)]), factors)
    assert r.placeholders_in_use == ["diesel"]
    assert any(n.code == "placeholder_factors" for n in r.data_quality_notes)


def test_default_factors_are_verified_with_sources(factors_default) -> None:  # type: ignore[no-untyped-def]
    assert factors_default.grid_electricity.value == pytest.approx(0.62)
    assert "Department of Environment" in factors_default.grid_electricity.source
    assert factors_default.diesel.value == pytest.approx(2.66155)
    assert factors_default.natural_gas.value == pytest.approx(2.06672)
    for f in factors_default.as_dict().values():
        assert f.status == "verified" and f.source and f.year


def test_explicit_period_includes_empty_edges(factors_with_grid) -> None:  # type: ignore[no-untyped-def]
    r = calculate(req([bill("2024-02", "electricity", 1000)], period_start="2024-01", period_end="2024-03"), factors_with_grid)
    assert [m.total_t is None for m in r.months] == [True, False, True]


def test_no_data(factors_default) -> None:  # type: ignore[no-untyped-def]
    r = calculate(req([]), factors_default)
    assert r.months == [] and r.totals.total_t is None
    assert r.data_quality_notes[0].code == "no_data"


def test_endpoint_unit_mismatch_422() -> None:
    c, _ = make_client()
    r = c.post("/v1/carbon/calculate", headers=AUTH, json={"bills": [{"billing_month": "2024-01", "bill_type": "gas", "consumed_units": 5, "unit": "kWh"}]})
    assert r.status_code == 422
    assert r.json()["error"]["code"] == "unit_mismatch"


def test_endpoint_rejects_bad_month() -> None:
    c, _ = make_client()
    r = c.post("/v1/carbon/calculate", headers=AUTH, json={"bills": [bill("2024-13", "electricity", 1)]})
    assert r.status_code == 422


def test_endpoint_returns_factor_metadata() -> None:
    c, _ = make_client()
    r = c.post("/v1/carbon/calculate", headers=AUTH, json={"bills": [bill("2024-01", "diesel", 10)]})
    assert r.status_code == 200
    f = r.json()["factors"]["diesel"]
    assert f["status"] == "verified" and "DESNZ" in f["source"] and f["unit"] == "kg_CO2e_per_litre"
