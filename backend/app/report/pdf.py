"""PDF report generation with reportlab (spec 6.5)."""

from __future__ import annotations

import io
from datetime import UTC, datetime
from pathlib import Path

import matplotlib
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen.canvas import Canvas
from reportlab.platypus import Image, PageBreak, Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle
from xml.sax.saxutils import escape

from app.report.charts import monthly_emissions_chart, solar_cashflow_chart
from app.schemas import CarbonCalculateResponse, ConfirmedBillInput, FactoryInfo, SolarEstimateResponse

DRAFT_STAMP = "DRAFT: contains unverified emission factors"
SYNTHETIC_STAMP = "SYNTHETIC DEMO DATA - not a real factory"
VALIDATION_NOTE = (
    "Draft emissions report for internal review. Its methodology and format have not yet been "
    "validated against the buyer's reporting requirements."
)
SOURCE_LABEL = {"electricity": "Grid electricity", "diesel": "Diesel", "gas": "Natural gas"}
UNIT_LABEL = {"kWh": "kWh", "litre": "L", "m3": "m3"}


def _how_entered(b: ConfirmedBillInput) -> str:
    """Plain description of where a value came from, for the audit trail."""
    if b.origin == "bill_image":
        if b.user_edited_fields:
            return "Bill photo read by AI; manager corrected: " + ", ".join(f.replace("_", " ") for f in b.user_edited_fields)
        return "Bill photo read by AI; checked and confirmed by manager"
    return {"manual": "Typed in by manager", "imported": "Imported from history file", "demo": "Synthetic demo data"}[b.origin]
_FONT = "Helvetica"
_FONT_BOLD = "Helvetica-Bold"


def _register_fonts() -> None:
    """Use DejaVu Sans (bundled with matplotlib) for wider Unicode coverage than Helvetica."""
    global _FONT, _FONT_BOLD
    if _FONT == "DejaVuSans":
        return
    font_dir = Path(matplotlib.get_data_path()) / "fonts" / "ttf"
    try:
        pdfmetrics.registerFont(TTFont("DejaVuSans", str(font_dir / "DejaVuSans.ttf")))
        pdfmetrics.registerFont(TTFont("DejaVuSans-Bold", str(font_dir / "DejaVuSans-Bold.ttf")))
        _FONT, _FONT_BOLD = "DejaVuSans", "DejaVuSans-Bold"
    except Exception:  # fall back to built-in Helvetica
        pass


def _unit(u: str) -> str:
    """kg_CO2e_per_kWh -> kg CO2e/kWh"""
    return u.replace("_per_", "/").replace("_", " ")


def _fmt(v: float | None, nd: int = 2, missing: str = "not available") -> str:
    return missing if v is None else f"{v:,.{nd}f}"


def _styles() -> dict[str, ParagraphStyle]:
    base = getSampleStyleSheet()
    return {
        "title": ParagraphStyle("t", parent=base["Title"], fontName=_FONT_BOLD, fontSize=20, leading=24),
        "h1": ParagraphStyle("h1", parent=base["Heading1"], fontName=_FONT_BOLD, fontSize=14, spaceBefore=6, spaceAfter=6),
        "h2": ParagraphStyle("h2", parent=base["Heading2"], fontName=_FONT_BOLD, fontSize=11, spaceBefore=6, spaceAfter=4),
        "body": ParagraphStyle("b", parent=base["BodyText"], fontName=_FONT, fontSize=9, leading=12),
        "small": ParagraphStyle("s", parent=base["BodyText"], fontName=_FONT, fontSize=7.5, leading=9.5),
        "center": ParagraphStyle("c", parent=base["BodyText"], fontName=_FONT, fontSize=11, alignment=TA_CENTER, leading=15),
        "warn": ParagraphStyle("w", parent=base["BodyText"], fontName=_FONT_BOLD, fontSize=10, textColor=colors.HexColor("#b00020"), alignment=TA_CENTER),
    }


def _table(data: list[list[object]], col_widths: list[float], header: bool = True) -> Table:
    t = Table(data, colWidths=col_widths, repeatRows=1 if header else 0)
    style = [
        ("FONT", (0, 0), (-1, -1), _FONT, 8),
        ("GRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#bbbbbb")),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ]
    if header:
        style += [("FONT", (0, 0), (-1, 0), _FONT_BOLD, 8), ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#eef2f5"))]
    t.setStyle(TableStyle(style))
    return t


def build_pdf(
    factory: FactoryInfo,
    carbon: CarbonCalculateResponse,
    solar: SolarEstimateResponse | None,
    synthetic: bool,
    generated_at: datetime | None = None,
    bills: list[ConfirmedBillInput] | None = None,
) -> bytes:
    _register_fonts()
    st = _styles()
    generated_at = generated_at or datetime.now(UTC)
    factors_all = list(carbon.factors.values()) + (list(solar.factors.values()) if solar else [])
    draft = any(f.status == "PLACEHOLDER" for f in factors_all)
    unit_label = escape(carbon.production_unit_label or "units")
    period = f"{carbon.period_start} to {carbon.period_end}" if carbon.period_start else "no data"

    story: list[object] = []
    # ---- cover
    story += [Spacer(1, 40 * mm), Paragraph("Draft Greenhouse Gas Emissions Report", st["title"]), Paragraph("Scope 1 (direct) and Scope 2 (purchased electricity, location-based), from utility bills", st["center"]), Spacer(1, 12 * mm)]
    story.append(Paragraph(f"<b>{escape(factory.name)}</b>", st["center"]))
    if factory.location:
        story.append(Paragraph(escape(factory.location), st["center"]))
    story += [Spacer(1, 6 * mm), Paragraph(f"Reporting period: {period}", st["center"]), Paragraph(f"Generated: {generated_at.strftime('%Y-%m-%d %H:%M UTC')}", st["center"]), Spacer(1, 10 * mm)]
    story += [Paragraph(VALIDATION_NOTE, st["center"]), Spacer(1, 6 * mm)]
    if draft:
        story.append(Paragraph(DRAFT_STAMP + ". Do not submit until all factors are verified.", st["warn"]))
    if synthetic:
        story.append(Paragraph(SYNTHETIC_STAMP, st["warn"]))
    story.append(PageBreak())

    # ---- summary
    t = carbon.totals
    names = {"electricity": "grid electricity (Scope 2)", "diesel": "diesel (Scope 1)", "gas": "natural gas (Scope 1)"}
    present = [k for k, has in (("electricity", any(m.electricity_kwh is not None for m in carbon.months)), ("diesel", any(m.diesel_litres is not None for m in carbon.months)), ("gas", any(m.gas_m3 is not None for m in carbon.months))) if has]
    included = ", ".join(names[k] for k in present) or "none"
    story.append(Paragraph("Summary", st["h1"]))
    summary: list[list[str]] = [
        ["Reporting period", period],
        ["Emission sources included", included],
        ["Scope 1: direct emissions from fuel burned on site (diesel, natural gas), tCO2e", _fmt(t.scope1_t, 3)],
        ["Scope 2: indirect emissions from purchased grid electricity (location-based), tCO2*", _fmt(t.scope2_t, 3)],
        ["Total (Scope 1 + Scope 2), tCO2e", _fmt(t.total_t, 3)],
        [f"Intensity, tCO2e per 1,000 {unit_label}", _fmt(t.intensity_t_per_1000_units, 4)],
        [f"Production, {unit_label}", _fmt(t.production_units, 0)],
        ["Months in period / with data / complete", f"{t.months_in_period} / {t.months_with_data} / {t.complete_months}"],
    ]
    # Paragraphs so long labels wrap instead of running into the value column (text is
    # already safe: fixed labels, numbers and the escaped unit label).
    story.append(_table([["Metric", "Value"], *[[Paragraph(a, st["body"]), Paragraph(b, st["body"])] for a, b in summary]], [115 * mm, 55 * mm]))
    story.append(Paragraph("* The Bangladesh grid factor covers CO2 only (CH4 and N2O from power generation are not included); Scope 1 factors are CO2e. Totals are given as tCO2e.", st["small"]))
    if carbon.errors:
        story.append(Spacer(1, 4 * mm))
        for e in carbon.errors:
            story.append(Paragraph(f"<font color='#b00020'><b>Not calculated:</b></font> {escape(e.message)}", st["body"]))

    # ---- monthly
    story.append(Paragraph("Monthly emissions", st["h1"]))
    if carbon.months:
        story.append(Image(io.BytesIO(monthly_emissions_chart(carbon)), width=170 * mm, height=76 * mm))
        story.append(Paragraph("* month with missing sources or factors (partial). Empty months have no data and are not zero.", st["small"]))
        rows: list[list[object]] = [["Month", "kWh", "Diesel L", "Gas m3", "Scope 1 t", "Scope 2 t", "Total t", "Complete"]]
        for r in carbon.months:
            rows.append([r.month, _fmt(r.electricity_kwh, 0, "-"), _fmt(r.diesel_litres, 0, "-"), _fmt(r.gas_m3, 0, "-"), _fmt(r.scope1_t, 3, "-"), _fmt(r.scope2_t, 3, "-"), _fmt(r.total_t, 3, "-"), "yes" if r.is_complete else "no"])
        story.append(_table(rows, [18 * mm, 22 * mm, 19 * mm, 21 * mm, 21 * mm, 21 * mm, 21 * mm, 23 * mm]))
    else:
        story.append(Paragraph("No data.", st["body"]))

    # ---- methodology
    story.append(PageBreak())
    story.append(Paragraph("Methodology", st["h1"]))
    for line in carbon.methodology:
        story.append(Paragraph("&bull; " + escape(line), st["body"]))
    story.append(Paragraph("Emission factors", st["h2"]))
    frows: list[list[object]] = [["Factor", "Value", "Unit", "Gases", "Source", "Year", "Status"]]
    for f in carbon.factors.values():
        frows.append([
            Paragraph(escape(f.name), st["small"]),
            _fmt(f.value, 4, "not set"),
            Paragraph(escape(_unit(f.unit)), st["small"]),
            Paragraph(escape(f.gases or "-"), st["small"]),
            Paragraph(escape(f.source or "-"), st["small"]),
            str(f.year or "-"),
            Paragraph(escape(f.status), st["small"]),
        ])
    story.append(_table(frows, [22 * mm, 14 * mm, 22 * mm, 25 * mm, 57 * mm, 11 * mm, 19 * mm]))

    # ---- data quality
    story.append(Paragraph("Data quality notes", st["h1"]))
    if carbon.data_quality_notes:
        for n in carbon.data_quality_notes:
            months = f" ({', '.join(n.months)})" if n.months else ""
            story.append(Paragraph("&bull; " + escape(n.message + months), st["body"]))
    else:
        story.append(Paragraph("None.", st["body"]))
    story.append(Paragraph("Scope: Scope 1 and 2 from utility bills only. No Scope 3; no coal, biomass or other fuels unless entered manually.", st["small"]))

    # ---- audit trail: every number traces back to a bill and to how it was entered
    if bills:
        story.append(Paragraph("Source data (audit trail)", st["h1"]))
        story.append(Paragraph("Every quantity used above, with where it came from. AI-read values were confirmed by the manager before use.", st["body"]))
        arows: list[list[object]] = [["Month", "Source", "Quantity", "Amount, BDT", "How it was entered", "Confirmed"]]
        for b in sorted(bills, key=lambda x: (x.billing_month, x.bill_type)):
            arows.append([
                b.billing_month,
                SOURCE_LABEL.get(b.bill_type, b.bill_type),
                f"{b.consumed_units:,.0f} {UNIT_LABEL.get(b.unit, b.unit)}",
                _fmt(b.total_amount_bdt, 0, "-"),
                Paragraph(escape(_how_entered(b)), st["small"]),
                (b.confirmed_at or "-")[:10],
            ])
        story.append(_table(arows, [16 * mm, 24 * mm, 24 * mm, 22 * mm, 64 * mm, 20 * mm]))

    # ---- solar
    if solar is not None:
        story.append(PageBreak())
        story.append(Paragraph("Rooftop solar pre-feasibility", st["h1"]))
        story.append(Paragraph(escape(solar.disclaimer), st["warn"]))
        srows: list[list[object]] = [
            ["Metric", "Value"],
            ["Roof area / usable area, m2", f"{solar.roof_area_m2:,.0f} / {solar.usable_area_m2:,.0f}"],
            ["System size, kWp", _fmt(solar.kwp, 1)],
            ["Peak sun hours (annual average)", f"{solar.peak_sun_hours_annual_avg:.2f} ({solar.irradiance_source})"],
            ["Annual generation, kWh", _fmt(solar.annual_generation_kwh, 0)],
            ["Share of consumption offset", "not available" if solar.offset_share is None else f"{solar.offset_share * 100:.1f}%"],
            ["CO2 avoided, tCO2e/year", _fmt(solar.co2_avoided_t_per_year, 2)],
        ]
        if solar.financials:
            fin = solar.financials
            srows += [["Capex, BDT", _fmt(fin.capex_bdt, 0)], ["Year-1 net savings, BDT", _fmt(fin.year1_net_bdt, 0)], ["Simple payback, years", _fmt(fin.simple_payback_years, 1, "no payback")]]
        story.append(_table(srows, [90 * mm, 80 * mm]))
        chart = solar_cashflow_chart(solar)
        if chart:
            story.append(Spacer(1, 4 * mm))
            story.append(Image(io.BytesIO(chart), width=170 * mm, height=64 * mm))
        for w in solar.warnings:
            story.append(Paragraph("&bull; " + escape(w.message), st["small"]))

    def on_page(canvas: Canvas, doc: SimpleDocTemplate) -> None:
        canvas.saveState()
        w, h = A4
        if draft:
            canvas.setFont(_FONT_BOLD, 9)
            canvas.setFillColor(colors.HexColor("#b00020"))
            canvas.drawCentredString(w / 2, h - 12 * mm, DRAFT_STAMP)
        if synthetic:
            canvas.setFont(_FONT_BOLD, 9)
            canvas.setFillColor(colors.HexColor("#b00020"))
            canvas.drawCentredString(w / 2, h - 17 * mm, SYNTHETIC_STAMP)
        canvas.setFont(_FONT, 7)
        canvas.setFillColor(colors.HexColor("#666666"))
        canvas.drawString(15 * mm, 10 * mm, f"{factory.name} - GHG report {period}")
        canvas.drawRightString(w - 15 * mm, 10 * mm, f"Page {doc.page}")
        canvas.restoreState()

    buf = io.BytesIO()
    doc = SimpleDocTemplate(buf, pagesize=A4, leftMargin=18 * mm, rightMargin=18 * mm, topMargin=22 * mm, bottomMargin=18 * mm, title=f"GHG report - {factory.name}", author="BillToGreen")
    doc.build(story, onFirstPage=on_page, onLaterPages=on_page)
    return buf.getvalue()
