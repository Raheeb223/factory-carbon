"""Matplotlib charts rendered to PNG bytes for the PDF report."""

from __future__ import annotations

import io

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

from app.schemas import CarbonCalculateResponse, SolarEstimateResponse  # noqa: E402

SOURCE_COLORS = {"electricity": "#2a6f97", "diesel": "#c8553d", "gas": "#e0a458"}
MONTH_ABBR = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")


def _png(fig: plt.Figure) -> bytes:
    buf = io.BytesIO()
    fig.savefig(buf, format="png", dpi=160, bbox_inches="tight")
    plt.close(fig)
    return buf.getvalue()


def monthly_emissions_chart(carbon: CarbonCalculateResponse) -> bytes:
    rows = carbon.months
    labels = [f"{MONTH_ABBR[int(r.month[5:7]) - 1]}\n{r.month[2:4]}" for r in rows]
    series = {
        "electricity": [r.scope2_electricity_t for r in rows],
        "diesel": [r.scope1_diesel_t for r in rows],
        "gas": [r.scope1_gas_t for r in rows],
    }
    names = {"electricity": "Grid electricity (Scope 2)", "diesel": "Diesel (Scope 1)", "gas": "Natural gas (Scope 1)"}
    fig, ax = plt.subplots(figsize=(8, 3.6))
    x = list(range(len(rows)))
    bottom = [0.0] * len(rows)
    for key, values in series.items():
        if all(v is None for v in values):
            continue
        heights = [v or 0.0 for v in values]
        ax.bar(x, heights, bottom=bottom, color=SOURCE_COLORS[key], label=names[key], width=0.7)
        bottom = [b + h for b, h in zip(bottom, heights, strict=True)]
    for i, r in enumerate(rows):
        if r.total_t is None:
            ax.text(i, 0, "no\ndata", ha="center", va="bottom", fontsize=6, color="#777777")
        elif not r.is_complete:
            ax.text(i, bottom[i], "*", ha="center", va="bottom", fontsize=9, color="#555555")
    ax.set_xticks(x, labels, fontsize=6)
    ax.set_ylabel("tCO2e")
    ax.spines[["top", "right"]].set_visible(False)
    ax.grid(axis="y", alpha=0.3)
    if ax.get_legend_handles_labels()[0]:
        ax.legend(fontsize=7, frameon=False, loc="upper left", bbox_to_anchor=(0, 1.15), ncols=3)
    return _png(fig)


def solar_cashflow_chart(solar: SolarEstimateResponse) -> bytes | None:
    if solar.financials is None:
        return None
    rows = solar.financials.cashflow
    fig, ax = plt.subplots(figsize=(8, 3.0))
    values = [r.cumulative_bdt / 1e6 for r in rows]
    ax.plot([r.year for r in rows], values, color="#2a6f97", marker="o", markersize=2.5)
    ax.axhline(0, color="#999999", linewidth=0.8)
    ax.set_xlabel("Year")
    ax.set_ylabel("Cumulative cash flow (million BDT)")
    ax.spines[["top", "right"]].set_visible(False)
    ax.grid(alpha=0.3)
    return _png(fig)
