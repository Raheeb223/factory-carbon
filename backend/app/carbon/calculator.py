"""Scope 1 + Scope 2 (location-based) monthly emissions from confirmed bills (spec 6.2).

Rules:
- Scope 2 = kWh x grid factor. Scope 1 = litres x diesel factor + m3 x gas factor.
- A month/source without data is null, never zero.
- A source whose factor is not set produces null values plus an explicit error.
- Totals are sums of what could be computed; incomplete months are marked as such.
"""

from __future__ import annotations

from collections import defaultdict
from collections.abc import Iterable

from app.carbon.factors import all_factor_info, factor_for
from app.schemas import (
    CANONICAL_UNIT,
    CalculationError,
    CarbonCalculateRequest,
    CarbonCalculateResponse,
    CarbonTotals,
    DataQualityNote,
    MonthEmissions,
    SourceType,
)
from app.security import ApiError
from app.settings import EmissionFactors

SOURCES: tuple[SourceType, ...] = ("electricity", "diesel", "gas")
SOURCE_LABEL: dict[SourceType, str] = {"electricity": "grid electricity", "diesel": "diesel", "gas": "natural gas"}

METHODOLOGY = [
    "Scope 2 (location-based) = electricity kWh x grid emission factor (kg CO2e/kWh) / 1000.",
    "Scope 1 = diesel litres x diesel factor (kg CO2e/L) / 1000 + gas m3 x gas factor (kg CO2e/m3) / 1000.",
    "Total = Scope 1 + Scope 2, in tonnes CO2e (tCO2e).",
    "Intensity = total tCO2e / units produced x 1,000, only for months with complete data and production.",
    "Months without data are shown as empty (null), never as zero.",
    "Only quantities from bills confirmed by the user, manual entries and imported history are used.",
    "Bill photos are read by AI (Google Gemini); every value is shown to the factory manager, who checks or corrects it before it is saved. Unconfirmed AI output is never used. The report lists each entry and how it was entered.",
    "The Bangladesh grid factor covers CO2 only; the diesel and natural gas factors are CO2e (CO2 + CH4 + N2O). Totals are reported as tCO2e.",
]


def month_range(start: str, end: str) -> list[str]:
    y, m = int(start[:4]), int(start[5:7])
    ey, em = int(end[:4]), int(end[5:7])
    out: list[str] = []
    while (y, m) <= (ey, em):
        out.append(f"{y:04d}-{m:02d}")
        m += 1
        if m == 13:
            y, m = y + 1, 1
    return out


def _r(v: float | None, nd: int = 6) -> float | None:
    return None if v is None else round(v, nd)


def _sum_or_none(values: Iterable[float | None]) -> float | None:
    present = [v for v in values if v is not None]
    return sum(present) if present else None


def calculate(req: CarbonCalculateRequest, factors: EmissionFactors) -> CarbonCalculateResponse:
    for b in req.bills:
        if b.unit != CANONICAL_UNIT[b.bill_type]:
            raise ApiError(
                422,
                "unit_mismatch",
                f"A {b.bill_type} entry for {b.billing_month} uses unit {b.unit}; expected {CANONICAL_UNIT[b.bill_type]}.",
            )

    all_months = [b.billing_month for b in req.bills] + [p.month for p in req.production]
    start = req.period_start or (min(all_months) if all_months else None)
    end = req.period_end or (max(all_months) if all_months else None)
    if start and end and start > end:
        raise ApiError(422, "invalid_period", "period_start is after period_end.")
    months = month_range(start, end) if start and end else []
    in_period = set(months)

    qty: dict[SourceType, dict[str, float]] = {s: defaultdict(float) for s in SOURCES}
    bill_count: dict[tuple[SourceType, str], int] = defaultdict(int)
    edited_months: set[str] = set()
    origin_months: dict[str, set[str]] = defaultdict(set)
    for b in req.bills:
        if b.billing_month not in in_period:
            continue
        qty[b.bill_type][b.billing_month] += b.consumed_units
        bill_count[(b.bill_type, b.billing_month)] += 1
        if b.user_edited_fields:
            edited_months.add(b.billing_month)
        origin_months[b.origin].add(b.billing_month)

    production: dict[str, float] = defaultdict(float)
    for p in req.production:
        if p.month in in_period:
            production[p.month] += p.units_produced
            origin_months[f"production_{p.origin}"].add(p.month)

    tracked = [s for s in SOURCES if qty[s]]
    factor_values: dict[SourceType, float | None] = {}
    errors: list[CalculationError] = []
    placeholders: list[str] = []
    for s in tracked:
        name, cv = factor_for(factors, s)
        factor_values[s] = cv.value
        if cv.value is None:
            errors.append(
                CalculationError(
                    code="factor_not_set",
                    factor=name,
                    message=f"The {SOURCE_LABEL[s]} emission factor is not set in the backend configuration, "
                    f"so {'Scope 2' if s == 'electricity' else 'Scope 1 ' + SOURCE_LABEL[s]} emissions cannot be calculated.",
                )
            )
        elif cv.status == "PLACEHOLDER":
            placeholders.append(name)

    rows: list[MonthEmissions] = []
    for month in months:
        t: dict[SourceType, float | None] = {}
        missing: list[str] = []
        for s in tracked:
            amount = qty[s].get(month)
            f = factor_values[s]
            if amount is None:
                t[s] = None
                missing.append(f"{s}:no_data")
            elif f is None:
                t[s] = None
                missing.append(f"{s}:factor_not_set")
            else:
                t[s] = amount * f / 1000.0
        scope1 = _sum_or_none([t.get("diesel"), t.get("gas")])
        scope2 = t.get("electricity")
        total = _sum_or_none([scope1, scope2])
        complete = bool(tracked) and not missing and total is not None
        prod = production.get(month)
        intensity = total / prod * 1000.0 if complete and prod and prod > 0 and total is not None else None
        rows.append(
            MonthEmissions(
                month=month,
                electricity_kwh=_r(qty["electricity"].get(month), 3),
                diesel_litres=_r(qty["diesel"].get(month), 3),
                gas_m3=_r(qty["gas"].get(month), 3),
                scope2_electricity_t=_r(t.get("electricity")),
                scope1_diesel_t=_r(t.get("diesel")),
                scope1_gas_t=_r(t.get("gas")),
                scope1_t=_r(scope1),
                scope2_t=_r(scope2),
                total_t=_r(total),
                is_complete=complete,
                missing=missing,
                production_units=_r(prod, 3),
                intensity_t_per_1000_units=_r(intensity),
            )
        )

    intensity_rows = [r for r in rows if r.intensity_t_per_1000_units is not None]
    prod_sum = sum(r.production_units or 0 for r in intensity_rows)
    period_intensity = (
        sum(r.total_t or 0 for r in intensity_rows) / prod_sum * 1000.0 if intensity_rows and prod_sum > 0 else None
    )
    totals = CarbonTotals(
        scope1_t=_r(_sum_or_none(r.scope1_t for r in rows)),
        scope2_t=_r(_sum_or_none(r.scope2_t for r in rows)),
        total_t=_r(_sum_or_none(r.total_t for r in rows)),
        production_units=_r(_sum_or_none(production.get(m) for m in months), 3),
        intensity_t_per_1000_units=_r(period_intensity),
        months_in_period=len(months),
        months_with_data=sum(1 for m in months if any(qty[s].get(m) is not None for s in SOURCES)),
        complete_months=sum(1 for r in rows if r.is_complete),
    )

    notes = _quality_notes(months, tracked, qty, production, bill_count, edited_months, origin_months, placeholders, totals)
    return CarbonCalculateResponse(
        period_start=start,
        period_end=end,
        months=rows,
        totals=totals,
        factors=all_factor_info(factors),
        placeholders_in_use=placeholders,
        errors=errors,
        data_quality_notes=notes,
        production_unit_label=req.production_unit_label,
        methodology=METHODOLOGY,
    )


def _quality_notes(
    months: list[str],
    tracked: list[SourceType],
    qty: dict[SourceType, dict[str, float]],
    production: dict[str, float],
    bill_count: dict[tuple[SourceType, str], int],
    edited_months: set[str],
    origin_months: dict[str, set[str]],
    placeholders: list[str],
    totals: CarbonTotals,
) -> list[DataQualityNote]:
    notes: list[DataQualityNote] = []
    if not months:
        notes.append(DataQualityNote(code="no_data", message="No confirmed bills or production data were provided."))
        return notes
    for s in tracked:
        gaps = [m for m in months if m not in qty[s]]
        if gaps:
            notes.append(
                DataQualityNote(
                    code=f"missing_{s}_data",
                    message=f"No {SOURCE_LABEL[s]} data for {len(gaps)} month(s); those months are shown as empty, not zero.",
                    months=gaps,
                )
            )
    empty = [m for m in months if not any(m in qty[s] for s in SOURCES)]
    if empty:
        notes.append(DataQualityNote(code="months_without_data", message=f"{len(empty)} month(s) have no energy data at all.", months=empty))
    if production:
        no_prod = [m for m in months if m not in production]
        if no_prod:
            notes.append(DataQualityNote(code="missing_production", message="Production is missing for some months, so intensity is not shown for them.", months=no_prod))
    multi = sorted({m for (s, m), n in bill_count.items() if n > 1})
    if multi:
        notes.append(DataQualityNote(code="multiple_entries_same_month", message="More than one entry of the same type exists for these months; their quantities were added together. Check for duplicates.", months=multi))
    if edited_months:
        notes.append(DataQualityNote(code="user_edited_values", message="Some values were corrected by the user after automatic reading.", months=sorted(edited_months)))
    if origin_months.get("manual"):
        notes.append(DataQualityNote(code="manual_entries", message="Some entries were typed in manually without a bill image.", months=sorted(origin_months["manual"])))
    if origin_months.get("imported") or origin_months.get("production_imported"):
        m = sorted(origin_months.get("imported", set()) | origin_months.get("production_imported", set()))
        notes.append(DataQualityNote(code="imported_history", message="Some data was imported from a spreadsheet (not from a bill image).", months=m))
    if origin_months.get("demo") or origin_months.get("production_demo"):
        m = sorted(origin_months.get("demo", set()) | origin_months.get("production_demo", set()))
        notes.append(DataQualityNote(code="synthetic_data", message="SYNTHETIC demo data is included. These results do not describe a real factory.", months=m))
    if placeholders:
        notes.append(DataQualityNote(code="placeholder_factors", message="Unverified (PLACEHOLDER) emission factors are in use: " + ", ".join(placeholders) + ". Verify before any real submission."))
    if totals.complete_months < totals.months_with_data:
        notes.append(DataQualityNote(code="incomplete_totals", message="Totals include months with missing sources or factors; they understate the true footprint."))
    return notes
