from __future__ import annotations

from app.report.loan import monthly_instalment, plan_loan
from app.schemas import LoanTerms, SolarEstimateResponse
from tests.conftest import AUTH, make_client
from tests.test_report import _pages, _payload

SQUARE = [{"lat": 23.81, "lon": 90.41}, {"lat": 23.81, "lon": 90.4104}, {"lat": 23.8104, "lon": 90.4104}, {"lat": 23.8104, "lon": 90.41}]


def _solar(c, **params: object) -> dict[str, object]:  # type: ignore[no-untyped-def]
    consumption = [{"month": f"2024-{m:02d}", "kwh": 20_000, "cost_bdt": 200_000} for m in range(1, 13)]
    r = c.post("/v1/solar/estimate", headers=AUTH, json={"polygon": SQUARE, "consumption": consumption, "params": {"capex_bdt_per_kwp": 50_000, **params}})
    assert r.status_code == 200, r.text
    return r.json()  # type: ignore[no-any-return]


def test_instalment_matches_annuity_formula() -> None:
    assert abs(monthly_instalment(1_000_000, 9, 5) - 20_758.36) < 0.01
    assert monthly_instalment(120_000, 0, 1) == 10_000


def test_plan_coverage_and_after_loan_savings() -> None:
    c, _ = make_client()
    solar = SolarEstimateResponse.model_validate(_solar(c))
    plan = plan_loan(solar, LoanTerms(loan_share=0.8, years=5, annual_rate_pct=9))
    assert plan is not None and solar.financials is not None
    assert plan.loan_bdt == solar.financials.capex_bdt * 0.8
    assert plan.repayment_by_year[:5] == [plan.monthly_instalment_bdt * 12] * 5
    assert all(v == 0 for v in plan.repayment_by_year[5:])
    assert plan.min_coverage == min(n / p for n, p in zip(plan.net_by_year[:5], plan.repayment_by_year[:5]))
    assert plan.savings_after_loan_bdt == sum(plan.net_by_year[5:])
    # A short, expensive loan is harder to repay from savings than a long cheap one.
    hard = plan_loan(solar, LoanTerms(loan_share=1, years=2, annual_rate_pct=20))
    assert hard is not None and hard.min_coverage is not None and hard.min_coverage < (plan.min_coverage or 0)


def test_loan_pdf_has_verdict_checklist_and_where_to_apply() -> None:
    c, _ = make_client()
    r = c.post("/v1/report/loan-pdf", headers=AUTH, json=_payload(solar=_solar(c), loan={"loan_share": 0.7, "years": 7, "annual_rate_pct": 8.5}))
    assert r.status_code == 200, r.text
    assert r.headers["content-type"] == "application/pdf"
    text = "\n".join(_pages(r.content))
    for s in ("Green Finance Readiness Summary", "Test Garments Ltd", "Monthly instalment", "7 years at 8.5%", "Readiness checklist", "Where to apply", "not a credit assessment"):
        assert s in text, s
    assert "SYNTHETIC" not in text


def test_loan_pdf_needs_token_solar_and_financials() -> None:
    c, _ = make_client()
    assert c.post("/v1/report/loan-pdf", json=_payload(solar=_solar(c))).status_code == 401
    assert c.post("/v1/report/loan-pdf", headers=AUTH, json=_payload()).status_code == 422
    no_fin = {**_solar(c), "financials": None}
    r = c.post("/v1/report/loan-pdf", headers=AUTH, json=_payload(solar=no_fin))
    assert r.status_code == 422 and r.json()["error"]["code"] == "solar_financials_missing"
    bad = c.post("/v1/report/loan-pdf", headers=AUTH, json=_payload(solar=_solar(c), loan={"years": 0}))
    assert bad.status_code == 422


def test_loan_pdf_flags_synthetic_data() -> None:
    c, _ = make_client()
    r = c.post("/v1/report/loan-pdf", headers=AUTH, json=_payload(solar=_solar(c), contains_synthetic_data=True))
    assert "SYNTHETIC DEMO DATA" in "\n".join(_pages(r.content))
