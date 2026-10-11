"""Evaluate Gemini bill extraction against ground truth.

For every image in data/sample_bills/ with a matching data/ground_truth/<stem>.json,
run the real extractor (needs GEMINI_API_KEY and GEMINI_MODEL) and print per-field
accuracy and every mismatch.

Usage (from backend/):
    python -m scripts.eval_extraction
    python -m scripts.eval_extraction --samples data/sample_bills --truth data/ground_truth
"""

from __future__ import annotations

import argparse
import sys
from collections import defaultdict
from pathlib import Path

BACKEND = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND))

from app.extraction.gemini_client import ExtractionFailed, GeminiExtractor, build_genai_client  # noqa: E402
from app.extraction.ground_truth import FieldResult, GroundTruth, compare  # noqa: E402
from app.extraction.upload import sniff_mime  # noqa: E402
from app.security import DailyCap  # noqa: E402
from app.settings import get_settings  # noqa: E402

IMAGE_SUFFIXES = {".png", ".jpg", ".jpeg", ".pdf"}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--samples", type=Path, default=BACKEND / "data" / "sample_bills")
    parser.add_argument("--truth", type=Path, default=BACKEND / "data" / "ground_truth")
    args = parser.parse_args()

    settings = get_settings()
    if not settings.gemini_configured:
        print("GEMINI_API_KEY and GEMINI_MODEL must be set (see .env.example).", file=sys.stderr)
        return 2
    assert settings.gemini_api_key and settings.gemini_model
    extractor = GeminiExtractor(
        build_genai_client(settings.gemini_api_key.get_secret_value(), settings.gemini_call_timeout_s),
        settings.gemini_model,
        DailyCap(10_000),
    )

    images = sorted(p for p in args.samples.iterdir() if p.suffix.lower() in IMAGE_SUFFIXES) if args.samples.exists() else []
    if not images:
        print(f"No sample bills found in {args.samples}.")
        return 1

    per_field: dict[str, list[bool]] = defaultdict(list)
    mismatches: list[tuple[str, FieldResult]] = []
    alternatives: list[tuple[str, FieldResult]] = []
    failures: list[str] = []
    for img in images:
        truth_path = args.truth / f"{img.stem}.json"
        if not truth_path.exists():
            print(f"skip {img.name}: no ground truth {truth_path.name}")
            continue
        data = img.read_bytes()
        mime = sniff_mime(data)
        if mime is None:
            print(f"skip {img.name}: not a PNG/JPEG/PDF")
            continue
        try:
            bill = extractor.extract(data, mime)
        except ExtractionFailed as e:
            failures.append(f"{img.name}: extraction failed ({e})")
            continue
        for r in compare(bill, GroundTruth.load(truth_path)):
            per_field[r.field].append(r.ok)
            if not r.ok:
                mismatches.append((img.name, r))
            elif r.matched_alternative is not None:
                alternatives.append((img.name, r))
        if bill.notes:
            print(f"{img.name} notes: {bill.notes}")

    print(f"\nModel: {settings.gemini_model}\n")
    print(f"{'field':<22}{'correct':>8}{'total':>7}{'accuracy':>10}")
    for field, oks in sorted(per_field.items()):
        print(f"{field:<22}{sum(oks):>8}{len(oks):>7}{sum(oks) / len(oks):>10.0%}")
    all_ok = [ok for oks in per_field.values() for ok in oks]
    if all_ok:
        print(f"{'ALL FIELDS':<22}{sum(all_ok):>8}{len(all_ok):>7}{sum(all_ok) / len(all_ok):>10.0%}")
    if mismatches:
        print("\nMismatches:")
        for name, r in mismatches:
            print(f"  {name} {r.field}: expected {r.expected!r}, got {r.actual!r}")
    if alternatives:
        print("\nAccepted alternatives (recorded):")
        for name, r in alternatives:
            print(f"  {name} {r.field}: returned {r.actual!r} (matches {r.matched_alternative!r})")
    for f in failures:
        print("FAILED", f)
    return 0 if not mismatches and not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
