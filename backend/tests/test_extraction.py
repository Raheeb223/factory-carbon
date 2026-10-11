from __future__ import annotations

import json
from datetime import date
from pathlib import Path
from types import SimpleNamespace
from typing import Any

import pytest

from app.extraction.gemini_client import (
    RESPONSE_JSON_SCHEMA,
    ExtractionFailed,
    GeminiExtractor,
    parse_model_output,
    scrub_identifiers,
)
from app.extraction.ground_truth import GroundTruth, compare
from app.extraction.prompts import EXTRACTION_PROMPT
from app.extraction.upload import sniff_mime
from app.extraction.validate import validate_bill
from app.schemas import ExtractedBill
from app.security import ApiError, DailyCap
from app.settings import DEFAULT_CONFIG_DIR, load_app_config
from tests.conftest import AUTH, BPDB_BILL, JPEG_BYTES, PNG_BYTES, FakeExtractor, make_client

RULES = load_app_config(DEFAULT_CONFIG_DIR).validation_rules
TRUTH_DIR = Path(__file__).resolve().parent.parent / "data" / "ground_truth"

BPDB_RAW: dict[str, Any] = {
    "bill_type": "electricity",
    "utility_name": "Bangladesh Power Development Board",
    "billing_month": "2024-05",
    "period_start": "2024-05-01",
    "period_end": "2024-05-30",
    "consumed_units": 120,
    "unit": "kWh",
    "total_amount_bdt": 683.74,
    "tariff_code": "LT-B",
    "sanctioned_load_kw": 2.0,
    "field_confidence": {"consumed_units": "high", "tariff_code": "high"},
    "notes": "Bill-month total 683.74; net payable 684.00. Meter multiplying factor 1.2.",
}


# ---------------------------------------------------------------- fake SDK client


class FakeModels:
    def __init__(self, outcomes: list[Any]) -> None:
        self.outcomes = outcomes
        self.calls: list[dict[str, Any]] = []

    def generate_content(self, **kwargs: Any) -> Any:
        self.calls.append(kwargs)
        outcome = self.outcomes.pop(0)
        if isinstance(outcome, Exception):
            raise outcome
        return SimpleNamespace(text=outcome)


class FakeGenAI:
    def __init__(self, outcomes: list[Any]) -> None:
        self.models = FakeModels(outcomes)


class CodedError(Exception):
    def __init__(self, code: int) -> None:
        super().__init__(f"code {code}")
        self.code = code


def extractor(outcomes: list[Any], cap: int = 100) -> tuple[GeminiExtractor, FakeGenAI, list[float]]:
    sleeps: list[float] = []
    client = FakeGenAI(outcomes)
    return GeminiExtractor(client, "test-model", DailyCap(cap), sleep=sleeps.append), client, sleeps


# ---------------------------------------------------------------- prompt & schema


def test_prompt_contains_required_rules() -> None:
    p = " ".join(EXTRACTION_PROMPT.lower().split())
    assert "customer's copy" in p
    assert "never compute it from present minus previous" in p
    assert "bangla digits" in p
    assert "day/month/year" in p
    assert "never guess" in p
    assert "meter numbers" in p and "consumer/account numbers" in p


def test_schema_has_no_personal_fields_and_no_defs() -> None:
    props = RESPONSE_JSON_SCHEMA["properties"]
    for forbidden in ("customer_name", "address", "meter_number", "consumer_number", "account_number"):
        assert forbidden not in props
    assert "$defs" not in json.dumps(RESPONSE_JSON_SCHEMA)


# ---------------------------------------------------------------- parsing


def test_parse_valid_output() -> None:
    bill = parse_model_output(BPDB_RAW)
    assert bill.consumed_units == 120
    assert bill.period_start == date(2024, 5, 1)
    assert bill.field_confidence == {"consumed_units": "high", "tariff_code": "high"}


def test_parse_invalid_values_become_null() -> None:
    bill = parse_model_output(
        {
            "bill_type": "water",
            "billing_month": "May 2024",
            "period_start": "30/05/2024",
            "consumed_units": "120",
            "unit": "units",
            "total_amount_bdt": True,
            "field_confidence": {"consumed_units": "very high", "unit": "high", "bogus": "low"},
        }
    )
    assert bill.bill_type == "unknown"
    assert bill.billing_month is None
    assert bill.period_start is None
    assert bill.consumed_units is None
    assert bill.unit is None
    assert bill.total_amount_bdt is None
    assert bill.field_confidence == {}  # confidence dropped for null/unknown fields


def test_scrub_identifiers_removes_long_numbers() -> None:
    assert scrub_identifiers("Consumer no 12345678 and meter 98-765-432") == "Consumer no [redacted] and meter [redacted]"
    assert scrub_identifiers("Tariff LT-B, 120 kWh") == "Tariff LT-B, 120 kWh"
    assert scrub_identifiers("   ") is None


def test_notes_are_scrubbed_on_parse() -> None:
    bill = parse_model_output({**BPDB_RAW, "notes": "Account 0123456789 seen"})
    assert bill.notes is not None and "0123456789" not in bill.notes


# ---------------------------------------------------------------- client: config, retries, cap


def test_extract_sends_image_with_schema_and_zero_temperature() -> None:
    ex, client, _ = extractor([json.dumps(BPDB_RAW)])
    bill = ex.extract(PNG_BYTES, "image/png")
    assert bill.tariff_code == "LT-B"
    call = client.models.calls[0]
    assert call["model"] == "test-model"
    assert call["config"].temperature == 0
    assert call["config"].response_mime_type == "application/json"
    assert call["config"].response_json_schema == RESPONSE_JSON_SCHEMA
    part = call["contents"][1]
    assert part.inline_data.mime_type == "image/png"


def test_retries_with_exponential_backoff_then_succeeds() -> None:
    ex, client, sleeps = extractor([CodedError(503), "not json", json.dumps(BPDB_RAW)])
    assert ex.extract(PNG_BYTES, "image/png").consumed_units == 120
    assert len(client.models.calls) == 3
    assert sleeps == [1.0, 2.0]


def test_gives_up_after_three_retries() -> None:
    ex, client, sleeps = extractor([CodedError(500)] * 4)
    with pytest.raises(ExtractionFailed):
        ex.extract(PNG_BYTES, "image/png")
    assert len(client.models.calls) == 4
    assert sleeps == [1.0, 2.0, 4.0]


def test_no_retry_on_client_error() -> None:
    ex, client, _ = extractor([CodedError(400), json.dumps(BPDB_RAW)])
    with pytest.raises(ExtractionFailed):
        ex.extract(PNG_BYTES, "image/png")
    assert len(client.models.calls) == 1


def test_daily_cap_counts_each_call() -> None:
    ex, _, _ = extractor([CodedError(503), json.dumps(BPDB_RAW)], cap=1)
    with pytest.raises(ApiError) as e:
        ex.extract(PNG_BYTES, "image/png")
    assert e.value.code == "daily_cap_reached"


# ---------------------------------------------------------------- validation


def test_bpdb_bill_has_no_warnings() -> None:
    assert validate_bill(BPDB_BILL, RULES) == []


def test_validation_warnings() -> None:
    bill = ExtractedBill(
        bill_type="electricity",
        billing_month="2024-06",
        period_start=date(2024, 5, 1),
        period_end=date(2024, 5, 10),
        consumed_units=100,
        unit="m3",
        total_amount_bdt=10_000,
        field_confidence={"total_amount_bdt": "low"},
    )
    codes = {w.code for w in validate_bill(bill, RULES)}
    assert codes == {"unusual_period_length", "month_period_mismatch", "unit_type_mismatch", "price_per_unit_out_of_band", "low_confidence"}


def test_validation_end_before_start_and_ceiling() -> None:
    bill = ExtractedBill(bill_type="diesel", period_start=date(2024, 5, 30), period_end=date(2024, 5, 1), consumed_units=10_000_000, unit="litre")
    codes = {w.code for w in validate_bill(bill, RULES)}
    assert {"period_end_before_start", "units_above_ceiling"} <= codes


def test_validation_zero_units_and_unknown_type() -> None:
    codes = {w.code for w in validate_bill(ExtractedBill(bill_type="unknown", consumed_units=0), RULES)}
    assert codes == {"unknown_bill_type", "units_not_positive"}


# ---------------------------------------------------------------- ground truth


def test_ground_truth_accepts_either_bpdb_total() -> None:
    truth = GroundTruth.load(TRUTH_DIR / "bpdb_may24.json")
    for total in (684.0, 683.74):
        results = compare(parse_model_output({**BPDB_RAW, "total_amount_bdt": total}), truth)
        assert all(r.ok for r in results), [r for r in results if not r.ok]
        total_result = next(r for r in results if r.field == "total_amount_bdt")
        assert total_result.matched_alternative == total


def test_ground_truth_flags_computed_meter_difference() -> None:
    truth = GroundTruth.load(TRUTH_DIR / "bpdb_may24.json")
    results = compare(parse_model_output({**BPDB_RAW, "consumed_units": 100}), truth)
    bad = [r.field for r in results if not r.ok]
    assert bad == ["consumed_units"]


# ---------------------------------------------------------------- endpoint


def test_sniff_mime() -> None:
    assert sniff_mime(PNG_BYTES) == "image/png"
    assert sniff_mime(JPEG_BYTES) == "image/jpeg"
    assert sniff_mime(b"%PDF-1.7") == "application/pdf"
    assert sniff_mime(b"GIF89a") is None


def test_extract_endpoint_returns_bill_and_warnings() -> None:
    fake = FakeExtractor()
    c, _ = make_client(extractor=fake)
    r = c.post("/v1/extract-bill", headers=AUTH, files={"file": ("bill.jpg", JPEG_BYTES, "image/jpeg")})
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["bill"]["consumed_units"] == 120
    assert body["warnings"] == []
    assert body["model"] == "fake-model"
    assert fake.calls == [(len(JPEG_BYTES), "image/jpeg")]


def test_extract_rejects_non_image_content() -> None:
    c, _ = make_client(extractor=FakeExtractor())
    r = c.post("/v1/extract-bill", headers=AUTH, files={"file": ("bill.png", b"GIF89a....", "image/png")})
    assert r.status_code == 415


def test_extract_rejects_bad_declared_type() -> None:
    c, _ = make_client(extractor=FakeExtractor())
    r = c.post("/v1/extract-bill", headers=AUTH, files={"file": ("x.html", PNG_BYTES, "text/html")})
    assert r.status_code == 415


def test_extract_rejects_large_file() -> None:
    c, _ = make_client(extractor=FakeExtractor(), max_upload_mb=0.001)
    r = c.post("/v1/extract-bill", headers=AUTH, files={"file": ("bill.png", PNG_BYTES + b"\x00" * 5000, "image/png")})
    assert r.status_code == 413


def test_extract_unconfigured_is_503() -> None:
    c, _ = make_client(extractor=None)
    r = c.post("/v1/extract-bill", headers=AUTH, files={"file": ("bill.png", PNG_BYTES, "image/png")})
    assert r.status_code == 503
    assert r.json()["error"]["code"] == "extraction_unavailable"


def test_extract_failure_is_502_without_details() -> None:
    c, _ = make_client(extractor=FakeExtractor(error=ExtractionFailed("ServerError")))
    r = c.post("/v1/extract-bill", headers=AUTH, files={"file": ("bill.png", PNG_BYTES, "image/png")})
    assert r.status_code == 502
    assert "Traceback" not in r.text and "ServerError" not in r.text


def test_extract_rate_limit() -> None:
    c, _ = make_client(extractor=FakeExtractor(), extract_rate_limit_per_minute=1)
    send = lambda: c.post("/v1/extract-bill", headers=AUTH, files={"file": ("b.png", PNG_BYTES, "image/png")})  # noqa: E731
    assert send().status_code == 200
    assert send().status_code == 429


def test_unexpected_error_hides_stack_trace() -> None:
    c, _ = make_client(extractor=FakeExtractor(error=RuntimeError("secret internals")))
    r = c.post("/v1/extract-bill", headers=AUTH, files={"file": ("bill.png", PNG_BYTES, "image/png")})
    assert r.status_code == 500
    assert "secret internals" not in r.text and "Traceback" not in r.text
