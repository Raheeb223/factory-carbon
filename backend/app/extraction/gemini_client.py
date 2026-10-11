"""Gemini bill extraction via the official Google Gen AI SDK (`google-genai`).

The raw model output is validated into `ExtractedBill`. Anything that does not parse
cleanly becomes null (never guessed), and personal identifiers are scrubbed from the
free-text fields as a second line of defence behind the prompt.
"""

from __future__ import annotations

import json
import logging
import re
import time
from collections.abc import Callable
from datetime import date
from typing import Any, Protocol

from pydantic import ValidationError

from app.extraction.prompts import EXTRACTION_PROMPT
from app.schemas import EXTRACTED_FIELDS, ExtractedBill
from app.security import ApiError, DailyCap

logger = logging.getLogger(__name__)

_NULLABLE_STRING = {"type": ["string", "null"]}
_NULLABLE_NUMBER = {"type": ["number", "null"]}
_CONFIDENCE = {"type": "string", "enum": ["high", "medium", "low"]}

# Flat JSON Schema (no $defs) using only keywords the Gemini docs list as supported.
RESPONSE_JSON_SCHEMA: dict[str, Any] = {
    "type": "object",
    "properties": {
        "bill_type": {"type": "string", "enum": ["electricity", "gas", "diesel", "unknown"]},
        "utility_name": _NULLABLE_STRING,
        "billing_month": {**_NULLABLE_STRING, "description": "YYYY-MM"},
        "period_start": {**_NULLABLE_STRING, "description": "ISO date YYYY-MM-DD"},
        "period_end": {**_NULLABLE_STRING, "description": "ISO date YYYY-MM-DD"},
        "consumed_units": {**_NULLABLE_NUMBER, "description": "printed consumed units"},
        # Enum fields are optional (omitted = unknown) because `null` inside `enum` is
        # not in the documented schema subset.
        "unit": {"type": "string", "enum": ["kWh", "m3", "litre"]},
        "total_amount_bdt": _NULLABLE_NUMBER,
        "tariff_code": _NULLABLE_STRING,
        "sanctioned_load_kw": _NULLABLE_NUMBER,
        "field_confidence": {
            "type": "object",
            "properties": {f: _CONFIDENCE for f in EXTRACTED_FIELDS},
        },
        "notes": _NULLABLE_STRING,
    },
    "required": [*[f for f in EXTRACTED_FIELDS if f != "unit"], "field_confidence", "notes"],
}

_MONTH_RE = re.compile(r"^\d{4}-(0[1-9]|1[0-2])$")
# Runs of 6+ digits (allowing spaces/dashes) look like account/meter/phone numbers.
_LONG_NUMBER_RE = re.compile(r"\d(?:[\s-]?\d){5,}")


class ExtractionFailed(Exception):
    """Gemini could not produce usable output after all retries."""


class GenAIClientLike(Protocol):
    @property
    def models(self) -> Any: ...


def scrub_identifiers(text: str | None) -> str | None:
    if text is None:
        return None
    cleaned = _LONG_NUMBER_RE.sub("[redacted]", text).strip()
    return cleaned or None


def _as_number(v: Any) -> float | None:
    if isinstance(v, bool):
        return None
    if isinstance(v, int | float):
        return float(v)
    return None


def _as_iso_date(v: Any) -> date | None:
    if not isinstance(v, str):
        return None
    try:
        return date.fromisoformat(v.strip())
    except ValueError:
        return None


def parse_model_output(raw: dict[str, Any]) -> ExtractedBill:
    """Convert raw model JSON into an ExtractedBill. Invalid values become null."""
    bill_type = raw.get("bill_type")
    if bill_type not in ("electricity", "gas", "diesel", "unknown"):
        bill_type = "unknown"
    month = raw.get("billing_month")
    unit = raw.get("unit")
    conf_raw = raw.get("field_confidence") or {}
    confidence = {
        k: v for k, v in conf_raw.items() if k in EXTRACTED_FIELDS and v in ("high", "medium", "low")
    } if isinstance(conf_raw, dict) else {}

    def text(key: str, max_len: int) -> str | None:
        v = raw.get(key)
        return scrub_identifiers(v[:max_len]) if isinstance(v, str) else None

    bill = ExtractedBill(
        bill_type=bill_type,
        utility_name=text("utility_name", 120),
        billing_month=month if isinstance(month, str) and _MONTH_RE.match(month) else None,
        period_start=_as_iso_date(raw.get("period_start")),
        period_end=_as_iso_date(raw.get("period_end")),
        consumed_units=_as_number(raw.get("consumed_units")),
        unit=unit if unit in ("kWh", "m3", "litre") else None,
        total_amount_bdt=_as_number(raw.get("total_amount_bdt")),
        tariff_code=text("tariff_code", 40),
        sanctioned_load_kw=_as_number(raw.get("sanctioned_load_kw")),
        field_confidence={},
        notes=text("notes", 1000),
    )
    # Keep confidence only for fields that actually have a value.
    values = bill.model_dump()
    bill.field_confidence = {k: v for k, v in confidence.items() if values.get(k) is not None}
    return bill


class GeminiExtractor:
    """Calls Gemini with the bill image and returns a parsed ExtractedBill."""

    def __init__(
        self,
        client: GenAIClientLike,
        model: str,
        daily_cap: DailyCap,
        max_retries: int = 3,
        base_backoff_s: float = 1.0,
        sleep: Callable[[float], None] = time.sleep,
    ) -> None:
        self._client = client
        self.model = model
        self._cap = daily_cap
        self._max_retries = max_retries
        self._base_backoff_s = base_backoff_s
        self._sleep = sleep

    def _config(self) -> Any:
        from google.genai import types

        return types.GenerateContentConfig(
            temperature=0,
            response_mime_type="application/json",
            response_json_schema=RESPONSE_JSON_SCHEMA,
        )

    def _call_once(self, image: bytes, mime_type: str) -> ExtractedBill:
        from google.genai import types

        response = self._client.models.generate_content(
            model=self.model,
            contents=[EXTRACTION_PROMPT, types.Part.from_bytes(data=image, mime_type=mime_type)],
            config=self._config(),
        )
        text = getattr(response, "text", None)
        if not text:
            raise ValueError("empty model response")
        raw = json.loads(text)
        if not isinstance(raw, dict):
            raise ValueError("model response is not a JSON object")
        return parse_model_output(raw)

    def extract(self, image: bytes, mime_type: str) -> ExtractedBill:
        attempts = 1 + self._max_retries
        last_error: Exception | None = None
        for attempt in range(attempts):
            if not self._cap.try_acquire():
                raise ApiError(429, "daily_cap_reached", "The daily bill-reading limit has been reached. Try again tomorrow or enter the bill manually.")
            try:
                return self._call_once(image, mime_type)
            except (ValueError, ValidationError, json.JSONDecodeError) as e:
                last_error = e
                logger.warning("gemini_output_invalid attempt=%d type=%s", attempt + 1, type(e).__name__)
            except Exception as e:  # SDK/network errors; never log payloads
                last_error = e
                code = getattr(e, "code", None)
                logger.warning("gemini_call_failed attempt=%d type=%s code=%s", attempt + 1, type(e).__name__, code)
                if isinstance(code, int) and 400 <= code < 500 and code not in (408, 429):
                    break  # client errors (bad key, bad model) will not succeed on retry
            if attempt < attempts - 1:
                self._sleep(self._base_backoff_s * (2**attempt))
        raise ExtractionFailed(type(last_error).__name__ if last_error else "unknown")


def build_genai_client(api_key: str, timeout_s: float) -> Any:
    from google import genai
    from google.genai import types

    return genai.Client(api_key=api_key, http_options=types.HttpOptions(timeout=int(timeout_s * 1000)))
