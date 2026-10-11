"""Compare an ExtractedBill against a ground-truth JSON file (used by the eval script and tests)."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from app.schemas import ExtractedBill

NUMERIC_TOLERANCE = 0.005


@dataclass(frozen=True)
class FieldResult:
    field: str
    expected: Any
    actual: Any
    ok: bool
    matched_alternative: Any | None = None


@dataclass(frozen=True)
class GroundTruth:
    image_stem: str
    expected: dict[str, Any]
    alternatives: dict[str, list[Any]]

    @classmethod
    def load(cls, path: Path) -> GroundTruth:
        data = json.loads(path.read_text(encoding="utf-8"))
        return cls(
            image_stem=data.get("image", path.stem),
            expected=data["expected"],
            alternatives=data.get("alternatives", {}),
        )


def _equal(expected: Any, actual: Any) -> bool:
    if expected is None or actual is None:
        return expected is actual
    if isinstance(expected, int | float) and isinstance(actual, int | float):
        return abs(float(expected) - float(actual)) <= NUMERIC_TOLERANCE
    return str(expected).strip().casefold() == str(actual).strip().casefold()


def compare(bill: ExtractedBill, truth: GroundTruth) -> list[FieldResult]:
    actual_all = bill.model_dump(mode="json")
    results: list[FieldResult] = []
    for field, expected in truth.expected.items():
        actual = actual_all.get(field)
        options = truth.alternatives.get(field, [expected])
        match = next((o for o in options if _equal(o, actual)), None)
        ok = match is not None or _equal(expected, actual)
        results.append(
            FieldResult(field=field, expected=expected, actual=actual, ok=ok, matched_alternative=match if field in truth.alternatives else None)
        )
    return results
