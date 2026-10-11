"""Server-side plausibility checks on an extracted bill (spec 6.1).

Returns warnings for the review screen. Never blocks and never changes values.
"""

from __future__ import annotations

from app.schemas import CANONICAL_UNIT, ExtractedBill, ExtractionWarning
from app.settings import ValidationRules


def validate_bill(bill: ExtractedBill, rules: ValidationRules) -> list[ExtractionWarning]:
    warnings: list[ExtractionWarning] = []

    def warn(field: str | None, code: str, message: str) -> None:
        warnings.append(ExtractionWarning(field=field, code=code, message=message))

    if bill.bill_type == "unknown":
        warn("bill_type", "unknown_bill_type", "Bill type could not be identified. Please select it.")

    start, end = bill.period_start, bill.period_end
    if start and end:
        if end < start:
            warn("period_end", "period_end_before_start", "Period end is before period start.")
        else:
            days = (end - start).days + 1
            if not rules.period_days.min <= days <= rules.period_days.max:
                warn(
                    "period_end",
                    "unusual_period_length",
                    f"Billing period is {days} days; a monthly bill is usually "
                    f"{rules.period_days.min:g}-{rules.period_days.max:g} days.",
                )

    if bill.billing_month and end and bill.billing_month != f"{end.year:04d}-{end.month:02d}":
        warn(
            "billing_month",
            "month_period_mismatch",
            f"Billing month {bill.billing_month} does not match the period end date {end.isoformat()}. "
            "Check which month this bill belongs to.",
        )

    units = bill.consumed_units
    if units is not None:
        if units <= 0:
            warn("consumed_units", "units_not_positive", "Consumed units should be greater than zero.")
        ceiling = rules.units_ceiling.get(bill.unit) if bill.unit else None
        if ceiling is not None and units > ceiling:
            warn("consumed_units", "units_above_ceiling", f"Consumed units {units:g} {bill.unit} is unusually high. Please check.")

    expected_unit = CANONICAL_UNIT.get(bill.bill_type)
    if bill.unit and expected_unit and bill.unit != expected_unit:
        warn("unit", "unit_type_mismatch", f"Unit {bill.unit} is unusual for a {bill.bill_type} bill (expected {expected_unit}).")

    band = rules.bdt_per_unit.get(bill.bill_type)
    if band and units and units > 0 and bill.total_amount_bdt is not None:
        per_unit = bill.total_amount_bdt / units
        if not band.min <= per_unit <= band.max:
            warn(
                "total_amount_bdt",
                "price_per_unit_out_of_band",
                f"Amount per unit is Tk {per_unit:.2f}, outside the usual range "
                f"Tk {band.min:g}-{band.max:g}. Check the units and the amount.",
            )

    for field, level in sorted(bill.field_confidence.items()):
        if level == "low":
            warn(field, "low_confidence", "The reader was not confident about this value. Please check it on the image.")

    return warnings
