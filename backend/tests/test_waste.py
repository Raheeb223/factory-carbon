from __future__ import annotations

from make_demo_data import make_demo_data

from app.schemas import WasteAnalyzeRequest
from app.waste.detector import analyze
from tests.conftest import AUTH, make_client


def demo_request(with_production: bool = True, seed: int = 42) -> tuple[WasteAnalyzeRequest, list[str]]:
    demo = make_demo_data(seed)
    months = [
        {"month": m.month, "kwh": m.electricity_kwh, "production": m.production_units if with_production else None, "cost_bdt": m.electricity_cost_bdt}
        for m in demo.months
    ]
    return WasteAnalyzeRequest.model_validate({"months": months, "production_unit_label": "pieces"}), demo.anomaly_months


def test_demo_data_is_synthetic_with_two_anomalies() -> None:
    demo = make_demo_data()
    assert demo.synthetic and "SYNTHETIC" in demo.label
    assert len(demo.months) == 24 and len(demo.anomaly_months) == 2


def test_ols_finds_injected_anomalies_with_few_false_flags() -> None:
    for seed in (1, 7, 42, 99):
        req, anomalies = demo_request(seed=seed)
        r = analyze(req)
        assert r.status == "ok" and r.method == "ols_production"
        assert set(anomalies) <= set(r.flagged_months), (seed, r.flagged_months)
        assert len(set(r.flagged_months) - set(anomalies)) <= 1, (seed, r.flagged_months)


def test_ols_message_and_cost() -> None:
    req, anomalies = demo_request()
    r = analyze(req)
    flagged = {m.month: m for m in r.months if m.flagged}
    m = flagged[anomalies[0]]
    assert m.excess_kwh is not None and m.excess_kwh > 0
    assert m.excess_cost_bdt == round(m.excess_kwh * r.avg_bdt_per_kwh, 0)  # type: ignore[operator]
    assert m.upper_kwh is not None and m.actual_kwh > m.upper_kwh
    msg = next(x for x in r.messages if "October 2023" in x)
    assert "more electricity than expected for the units produced" in msg
    assert "kWh" in msg and "Tk" in msg and "compressors" in msg
    assert r.model_summary["r_squared"] is not None


def test_mad_fallback_without_production() -> None:
    req, anomalies = demo_request(with_production=False)
    r = analyze(req)
    assert r.method == "median_mad"
    assert r.confidence_label is not None and "lower confidence, no production data" in r.confidence_label.lower()
    assert all(m.production is None for m in r.months)


def test_insufficient_data() -> None:
    req = WasteAnalyzeRequest.model_validate({"months": [{"month": f"2024-0{i}", "kwh": 1000, "production": 10} for i in range(1, 6)]})
    r = analyze(req)
    assert r.status == "insufficient_data"
    assert r.month_count == 5 and r.required_months == 6
    assert r.months == []


def test_no_costs_when_no_bill_amounts() -> None:
    req, _ = demo_request()
    for m in req.months:
        m.cost_bdt = None
    r = analyze(req)
    assert r.avg_bdt_per_kwh is None
    assert all(m.excess_cost_bdt is None for m in r.months)
    assert any("cost unknown" in msg for msg in r.messages)


def test_endpoint() -> None:
    c, _ = make_client()
    req, anomalies = demo_request()
    r = c.post("/v1/waste/analyze", headers=AUTH, json=req.model_dump())
    assert r.status_code == 200
    assert set(anomalies) <= set(r.json()["flagged_months"])
