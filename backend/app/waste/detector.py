"""Electricity waste / anomaly detector (spec 6.3).

- >= 6 months with both kWh and production: OLS kWh ~ production, leave-one-out 95%
  prediction interval per month; months above the upper bound are flagged.
- Otherwise, >= 6 months of kWh: leave-one-out median/MAD fallback (robust z > 3),
  labelled lower confidence.
- Fewer than 6 months of kWh: insufficient_data.
"""

from __future__ import annotations

import math
from calendar import month_name

import numpy as np
import statsmodels.api as sm

from app.schemas import WasteAnalyzeRequest, WasteAnalyzeResponse, WasteMonthResult

MIN_MONTHS = 6
ALPHA = 0.05
MAD_SCALE = 1.4826  # makes MAD consistent with the standard deviation for normal data
MAD_Z = 3.0
MAX_PASSES = 3

LIMITATIONS = [
    "Based on a small sample of monthly totals, so results are indicative only.",
    "Without sub-metering, it cannot tell which machine or area used the extra electricity.",
    "It flags months that are statistical outliers; it cannot identify the cause.",
    "Changes in product mix, working hours, weather or new machines can explain a flag.",
    "Months with missing data are left out.",
]
CONFIDENCE_OLS = "Expected use is based on the production level (regression on production)."
CONFIDENCE_MAD = "Lower confidence, no production data: compared with the factory's typical month."
CHECK_HINT = "Check compressors, idle machines and generator changeover."


def _label(month: str) -> str:
    return f"{month_name[int(month[5:7])]} {month[:4]}"


def _fmt(n: float) -> str:
    return f"{n:,.0f}"


def _avg_price(req: WasteAnalyzeRequest) -> float | None:
    paired = [(m.kwh, m.cost_bdt) for m in req.months if m.kwh and m.kwh > 0 and m.cost_bdt is not None]
    kwh = sum(k for k, _ in paired)
    return sum(c for _, c in paired) / kwh if kwh > 0 else None


def _ols_loo_pass(x: np.ndarray, y: np.ndarray, excluded: set[int]) -> list[tuple[float, float, float]]:
    out: list[tuple[float, float, float]] = []
    for i in range(len(x)):
        mask = np.array([j != i and j not in excluded for j in range(len(x))])
        fit = sm.OLS(y[mask], sm.add_constant(x[mask])).fit()
        frame = fit.get_prediction(np.array([[1.0, x[i]]])).summary_frame(alpha=ALPHA)
        out.append((float(frame["mean"].iloc[0]), float(frame["obs_ci_lower"].iloc[0]), float(frame["obs_ci_upper"].iloc[0])))
    return out


def _ols_loo(x: np.ndarray, y: np.ndarray) -> tuple[list[tuple[float, float, float]], dict[str, float | None]]:
    """For each i, fit on the other months and predict month i with a 95% prediction interval.

    One flagged month can widen the interval of another and hide it (masking), so up to
    MAX_PASSES passes refit without months already flagged, keeping >= MIN_MONTHS - 1 in each fit.
    """
    excluded: set[int] = set()
    out = _ols_loo_pass(x, y, excluded)
    for _ in range(MAX_PASSES - 1):
        flagged = {i for i, (_, _, upper) in enumerate(out) if y[i] > upper}
        if flagged == excluded or len(x) - len(flagged) - 1 < MIN_MONTHS - 1:
            break
        excluded = flagged
        out = _ols_loo_pass(x, y, excluded)
    keep = np.array([i not in excluded for i in range(len(x))])
    full = sm.OLS(y[keep], sm.add_constant(x[keep])).fit()
    summary: dict[str, float | None] = {
        "intercept_kwh": float(full.params[0]),
        "kwh_per_unit": float(full.params[1]),
        "r_squared": float(full.rsquared),
        "n": float(int(keep.sum())),
    }
    return out, summary


def _mad_loo(y: np.ndarray) -> tuple[list[tuple[float, float, float]], dict[str, float | None]]:
    out: list[tuple[float, float, float]] = []
    for i in range(len(y)):
        rest = np.delete(y, i)
        med = float(np.median(rest))
        mad = float(np.median(np.abs(rest - med))) * MAD_SCALE
        out.append((med, med - MAD_Z * mad, med + MAD_Z * mad))
    med_all = float(np.median(y))
    return out, {"median_kwh": med_all, "mad_kwh": float(np.median(np.abs(y - med_all)) * MAD_SCALE), "n": float(len(y))}


def analyze(req: WasteAnalyzeRequest) -> WasteAnalyzeResponse:
    months = sorted({m.month: m for m in req.months}.values(), key=lambda m: m.month)
    with_kwh = [m for m in months if m.kwh is not None and m.kwh > 0]
    paired = [m for m in with_kwh if m.production is not None and m.production > 0]
    price = _avg_price(req)

    if len(with_kwh) < MIN_MONTHS:
        return WasteAnalyzeResponse(
            status="insufficient_data",
            method=None,
            confidence_label=None,
            month_count=len(with_kwh),
            required_months=MIN_MONTHS,
            months=[],
            flagged_months=[],
            avg_bdt_per_kwh=price,
            messages=[
                f"Only {len(with_kwh)} month(s) of electricity data. At least {MIN_MONTHS} months are needed; "
                "import past bills to enable this check."
            ],
            limitations=LIMITATIONS,
            model_summary={},
        )

    if len(paired) >= MIN_MONTHS:
        method, label, used = "ols_production", CONFIDENCE_OLS, paired
        x = np.array([m.production for m in used], dtype=float)
        y = np.array([m.kwh for m in used], dtype=float)
        if float(np.ptp(x)) == 0.0:
            method, label = "median_mad", CONFIDENCE_MAD + " (production did not vary)"
            preds, summary = _mad_loo(y)
        else:
            preds, summary = _ols_loo(x, y)
    else:
        method, label, used = "median_mad", CONFIDENCE_MAD, with_kwh
        y = np.array([m.kwh for m in used], dtype=float)
        preds, summary = _mad_loo(y)

    results: list[WasteMonthResult] = []
    messages: list[str] = []
    for m, (expected, lower, upper) in zip(used, preds, strict=True):
        actual = float(m.kwh or 0)
        flagged = actual > upper
        excess = actual - expected if flagged else None
        pct = excess / expected * 100.0 if flagged and expected > 0 and excess is not None else None
        cost = excess * price if excess is not None and price is not None else None
        results.append(
            WasteMonthResult(
                month=m.month,
                actual_kwh=round(actual, 2),
                production=m.production,
                expected_kwh=round(expected, 2),
                lower_kwh=round(max(lower, 0.0), 2),
                upper_kwh=round(upper, 2),
                flagged=flagged,
                excess_kwh=None if excess is None else round(excess, 2),
                excess_pct=None if pct is None else round(pct, 1),
                excess_cost_bdt=None if cost is None else round(cost, 0),
            )
        )
        if flagged and excess is not None:
            basis = "for the units produced" if method == "ols_production" else "compared with a typical month"
            cost_part = f", about Tk {_fmt(cost)}" if cost is not None else " (cost unknown: no bill amounts)"
            pct_part = f"about {pct:.0f}% more" if pct is not None and math.isfinite(pct) else "more"
            messages.append(
                f"{_label(m.month)} used {pct_part} electricity than expected {basis}; "
                f"about {_fmt(excess)} kWh{cost_part}. {CHECK_HINT}"
            )

    flagged_months = [r.month for r in results if r.flagged]
    if not flagged_months:
        messages.append("No month used clearly more electricity than expected.")
    skipped = len(with_kwh) - len(used)
    if skipped > 0:
        messages.append(f"{skipped} month(s) without production data were left out of the comparison.")
    if price is None:
        messages.append("No bill amounts were provided, so costs are not estimated.")

    return WasteAnalyzeResponse(
        status="ok",
        method=method,  # type: ignore[arg-type]
        confidence_label=label,
        month_count=len(used),
        required_months=MIN_MONTHS,
        months=results,
        flagged_months=flagged_months,
        avg_bdt_per_kwh=None if price is None else round(price, 4),
        messages=messages,
        limitations=LIMITATIONS,
        model_summary={k: (None if v is None else round(v, 6)) for k, v in summary.items()},
    )

