from __future__ import annotations

import io
from collections.abc import Callable
from pathlib import Path

from pypdf import PdfReader

from app.report.pdf import DRAFT_STAMP, SYNTHETIC_STAMP
from tests.conftest import AUTH, make_client


def _bills() -> list[dict[str, object]]:
    out: list[dict[str, object]] = []
    for m in range(1, 7):
        out.append({"billing_month": f"2024-{m:02d}", "bill_type": "electricity", "consumed_units": 10_000 + m * 100, "unit": "kWh", "total_amount_bdt": 100_000})
        out.append({"billing_month": f"2024-{m:02d}", "bill_type": "diesel", "consumed_units": 200, "unit": "litre"})
    return out


def _payload(**extra: object) -> dict[str, object]:
    return {
        "factory": {"name": "Test Garments Ltd", "location": "Gazipur"},
        "carbon": {"bills": _bills(), "production": [{"month": "2024-01", "units_produced": 40_000}], "production_unit_label": "pieces"},
        **extra,
    }


def _pages(pdf: bytes) -> list[str]:
    return [p.extract_text() or "" for p in PdfReader(io.BytesIO(pdf)).pages]


def test_pdf_has_sections_and_draft_stamp_on_every_page(config_dir_factory: Callable[..., Path]) -> None:
    c, _ = make_client(config_dir=config_dir_factory(grid_electricity=None))
    r = c.post("/v1/report/pdf", headers=AUTH, json=_payload())
    assert r.status_code == 200, r.text
    assert r.headers["content-type"] == "application/pdf"
    assert r.content.startswith(b"%PDF")
    pages = _pages(r.content)
    assert len(pages) >= 3
    assert all(DRAFT_STAMP in p for p in pages)
    text = "\n".join(pages)
    for section in ("Test Garments Ltd", "Summary", "Monthly emissions", "Methodology", "Emission factors", "Data quality notes"):
        assert section in text
    assert "Not calculated" in text  # grid factor not set
    assert SYNTHETIC_STAMP not in text


def test_pdf_without_placeholders_has_no_draft_stamp() -> None:
    c, _ = make_client()  # shipped config: all emission factors verified
    r = c.post("/v1/report/pdf", headers=AUTH, json=_payload())
    assert r.status_code == 200
    assert all(DRAFT_STAMP not in p for p in _pages(r.content))


def test_pdf_synthetic_and_solar_sections() -> None:
    c, _ = make_client()
    square = [{"lat": 23.81, "lon": 90.41}, {"lat": 23.81, "lon": 90.4104}, {"lat": 23.8104, "lon": 90.4104}, {"lat": 23.8104, "lon": 90.41}]
    consumption = [{"month": f"2024-{m:02d}", "kwh": 20_000, "cost_bdt": 200_000} for m in range(1, 13)]
    solar = c.post("/v1/solar/estimate", headers=AUTH, json={"polygon": square, "consumption": consumption, "params": {"capex_bdt_per_kwp": 50_000}}).json()
    r = c.post("/v1/report/pdf", headers=AUTH, json=_payload(solar=solar, contains_synthetic_data=True))
    assert r.status_code == 200, r.text
    pages = _pages(r.content)
    assert all(SYNTHETIC_STAMP in p for p in pages)
    text = "\n".join(pages)
    assert "Rooftop solar pre-feasibility" in text
    assert "professional assessment" in text


def test_pdf_handles_empty_data() -> None:
    c, _ = make_client()
    r = c.post("/v1/report/pdf", headers=AUTH, json={"factory": {"name": "X"}, "carbon": {"bills": []}})
    assert r.status_code == 200
    assert r.content.startswith(b"%PDF")


def test_pdf_is_a_traceable_draft() -> None:
    bills = _bills()
    bills[0] |= {"origin": "bill_image", "user_edited_fields": ["consumed_units"], "confirmed_at": "2026-10-11T08:00:00Z"}
    bills[1] |= {"origin": "manual"}
    c, _ = make_client()
    r = c.post("/v1/report/pdf", headers=AUTH, json=_payload(carbon={"bills": bills, "production_unit_label": "pieces"}))
    assert r.status_code == 200, r.text
    text = " ".join(" ".join(_pages(r.content)).split())
    assert "Draft Greenhouse Gas Emissions Report" in text
    assert "not yet been validated against the buyer" in text
    assert "Reporting period" in text and "Emission sources included" in text
    assert "direct emissions" in text and "purchased grid electricity" in text
    assert "CO2 only" in text and "CO2e (CO2 + CH4 + N2O" in text  # gases per factor
    assert "Source data (audit trail)" in text
    assert "manager corrected: consumed units" in text and "Typed in by manager" in text
    assert "2026-10-11" in text


def test_pdf_lists_lpg_and_furnace_oil_when_used() -> None:
    c, _ = make_client()
    bills = _bills() + [
        {"billing_month": "2024-02", "bill_type": "lpg", "consumed_units": 450, "unit": "kg"},
        {"billing_month": "2024-03", "bill_type": "furnace_oil", "consumed_units": 1200, "unit": "litre"},
    ]
    payload = _payload()
    payload["carbon"] = {**payload["carbon"], "bills": bills}  # type: ignore[dict-item]
    r = c.post("/v1/report/pdf", headers=AUTH, json=payload)
    assert r.status_code == 200, r.text
    text = "\n".join(_pages(r.content))
    assert "LPG (Scope 1)" in text and "furnace oil (Scope 1)" in text
    assert "LPG kg" in text and "F. oil L" in text


def test_pdf_cover_shows_facility_profile() -> None:
    c, _ = make_client()
    payload = _payload(factory={"name": "Test Garments Ltd", "location": "Konabari", "district": "Gazipur", "facility_type": "knit", "workers": 1200, "shifts_per_day": 2})
    r = c.post("/v1/report/pdf", headers=AUTH, json=payload)
    assert r.status_code == 200, r.text
    cover = _pages(r.content)[0]
    assert "Konabari, Gazipur" in cover
    assert "Knit garments | 1,200 workers | 2 shifts per day" in cover


def test_pdf_has_energy_table() -> None:
    c, _ = make_client()
    r = c.post("/v1/report/pdf", headers=AUTH, json=_payload())
    text = "\n".join(_pages(r.content))
    assert "Energy consumption" in text
    assert "net calorific value" in text
