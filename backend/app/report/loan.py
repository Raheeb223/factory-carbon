"""Green loan readiness: can the solar plan's savings repay a loan for it? Plus a bank-ready PDF summary."""

from __future__ import annotations

import io
from dataclasses import dataclass
from datetime import UTC, datetime
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfgen.canvas import Canvas
from reportlab.platypus import Image, Paragraph, SimpleDocTemplate, Spacer

from app.report import pdf as base
from app.report.charts import loan_coverage_chart
from app.schemas import CarbonCalculateResponse, ConfirmedBillInput, FactoryInfo, LoanTerms, SolarEstimateResponse

DISCLAIMER = (
    "Pre-feasibility summary prepared by the factory with BillToGreen. It is not a credit assessment or a loan offer. "
    "The interest rate and loan terms are assumptions entered by the factory; eligibility, rates and terms are set by the lender."
)
WHERE_TO_APPLY = (
    "Ask your bank about its green or sustainable finance products for rooftop solar. Banks in Bangladesh can lend for "
    "renewable energy under Bangladesh Bank's sustainable finance policy and its green refinance schemes, and IDCOL "
    "supports rooftop solar financing through partner organisations. Check current schemes and terms with the lender."
)
USUALLY_ASKED = (
    "This summary and the GHG emissions report",
    "12 months of utility bills (the originals behind the figures here)",
    "An installer's quotation for the system",
    "A structural check of the roof by an engineer",
    "Trade licence, TIN and recent bank statements",
)
STRUCTURE_WARNINGS = ("structure_unknown", "structure_needs_work")


@dataclass(frozen=True)
class LoanPlan:
    capex_bdt: float
    loan_bdt: float
    own_money_bdt: float
    monthly_instalment_bdt: float
    total_interest_bdt: float
    year1_net_monthly_bdt: float
    # Lowest yearly net savings / yearly repayment over the loan years (a debt service coverage ratio).
    min_coverage: float | None
    net_by_year: list[float]
    repayment_by_year: list[float]
    savings_after_loan_bdt: float

    @property
    def pays_itself(self) -> bool:
        return self.min_coverage is not None and self.min_coverage >= 1


def monthly_instalment(principal: float, annual_rate_pct: float, years: int) -> float:
    n = years * 12
    r = annual_rate_pct / 100 / 12
    if r == 0:
        return principal / n
    return principal * r / (1 - (1 + r) ** -n)


def plan_loan(solar: SolarEstimateResponse, terms: LoanTerms) -> LoanPlan | None:
    """None when the solar plan has no financials (no electricity price or consumption)."""
    fin = solar.financials
    if fin is None:
        return None
    loan = fin.capex_bdt * terms.loan_share
    emi = monthly_instalment(loan, terms.annual_rate_pct, terms.years)
    net = [c.net_bdt for c in fin.cashflow if c.year >= 1]  # year 0 is the capex itself
    repay = [emi * 12 if i < terms.years else 0.0 for i in range(len(net))]
    loan_years = [(n, p) for n, p in zip(net, repay) if p > 0]
    coverage = min(n / p for n, p in loan_years) if loan_years else None
    return LoanPlan(
        capex_bdt=fin.capex_bdt,
        loan_bdt=loan,
        own_money_bdt=fin.capex_bdt - loan,
        monthly_instalment_bdt=emi,
        total_interest_bdt=emi * terms.years * 12 - loan,
        year1_net_monthly_bdt=fin.year1_net_bdt / 12,
        min_coverage=coverage,
        net_by_year=net,
        repayment_by_year=repay,
        savings_after_loan_bdt=sum(n for n, p in zip(net, repay) if p == 0),
    )


def readiness(
    factory: FactoryInfo, carbon: CarbonCalculateResponse, solar: SolarEstimateResponse, plan: LoanPlan
) -> list[tuple[str, bool, str]]:
    """(check, passed, detail) rows a lender would look for first."""
    months = carbon.totals.months_with_data
    placeholders = [f.name for f in [*carbon.factors.values(), *solar.factors.values()] if f.status == "PLACEHOLDER"]
    structure = next((w.code for w in solar.warnings if w.code in STRUCTURE_WARNINGS), None)
    return [
        ("12 months of utility bills", months >= 12, f"{months} month{'s' if months != 1 else ''} with data"),
        ("Solar sized on the factory's own use", solar.annual_consumption_kwh is not None, "from the bills" if solar.annual_consumption_kwh is not None else "no consumption data"),
        ("Savings cover the loan repayment", plan.pays_itself, "lowest year: " + ("-" if plan.min_coverage is None else f"{plan.min_coverage:.2f}x")),
        ("Roof structure checked by an engineer", structure is None, {None: "checked", "structure_unknown": "not checked yet", "structure_needs_work": "needs work"}[structure]),
        ("Emission factors verified", not placeholders, "all verified" if not placeholders else "unverified: " + ", ".join(placeholders)),
        ("Factory profile complete", bool(factory.location) and factory.workers is not None, "location and workers" if factory.location and factory.workers is not None else "add location and workers"),
    ]


def _bdt(v: float) -> str:
    return f"BDT {v:,.0f}"


def _wrapped(rows: list[list[str]], style: ParagraphStyle) -> list[list[object]]:
    """Header as is, body cells as Paragraphs so long values wrap inside their column."""
    return [rows[0], *[[Paragraph(escape(c), style) for c in r] for r in rows[1:]]]


def build_loan_pdf(
    factory: FactoryInfo,
    carbon: CarbonCalculateResponse,
    solar: SolarEstimateResponse,
    terms: LoanTerms,
    plan: LoanPlan,
    synthetic: bool,
    bills: list[ConfirmedBillInput],
    generated_at: datetime | None = None,
) -> bytes:
    base._register_fonts()
    st = base._styles()
    generated_at = generated_at or datetime.now(UTC)
    period = f"{carbon.period_start} to {carbon.period_end}" if carbon.period_start else "no data"
    story: list[object] = [
        Paragraph("Green Finance Readiness Summary", st["title"]),
        Paragraph("Rooftop solar project, for a bank or lender", st["center"]),
        Spacer(1, 4 * mm),
        Paragraph(f"<b>{escape(factory.name)}</b>", st["center"]),
    ]
    place = ", ".join(p for p in (factory.location, factory.district) if p)
    profile = [
        place or None,
        base.FACILITY_LABEL[factory.facility_type] if factory.facility_type else None,
        f"{factory.workers:,} workers" if factory.workers is not None else None,
    ]
    if any(profile):
        story.append(Paragraph(escape(" | ".join(p for p in profile if p)), st["center"]))
    story.append(Paragraph(f"Generated {generated_at.strftime('%Y-%m-%d')}", st["center"]))
    if synthetic:
        story.append(Paragraph(base.SYNTHETIC_STAMP, st["warn"]))

    # ---- headline
    monthly_net, emi = plan.year1_net_monthly_bdt, plan.monthly_instalment_bdt
    if plan.pays_itself:
        verdict = f"Solar savings repay the loan: about {_bdt(monthly_net)} saved a month against a {_bdt(emi)} monthly instalment."
    else:
        share = 0 if emi == 0 else monthly_net / emi * 100
        verdict = f"Solar savings cover about {share:.0f}% of the {_bdt(emi)} monthly instalment in year 1; the factory pays the rest."
    story += [Spacer(1, 4 * mm), Paragraph(f"<b>{escape(verdict)}</b>", st["center"])]

    # ---- project and financing
    story.append(Paragraph("The project", st["h1"]))
    project = [
        ["Metric", "Value"],
        ["System size", f"{solar.kwp:,.1f} kWp on {solar.usable_area_m2:,.0f} m2 of usable roof"],
        ["Generation, first year", f"{solar.annual_generation_kwh:,.0f} kWh"],
        ["Share of the factory's electricity", "-" if solar.offset_share is None else f"{solar.offset_share * 100:.0f}%"],
        ["CO2 avoided", "-" if solar.co2_avoided_t_per_year is None else f"{solar.co2_avoided_t_per_year:,.1f} tCO2 a year"],
        ["Project cost (capex)", _bdt(plan.capex_bdt)],
        ["Net savings, first year", _bdt(plan.year1_net_monthly_bdt * 12)],
    ]
    story.append(base._table(_wrapped(project, st["body"]), [70 * mm, 100 * mm]))
    story.append(Paragraph("Proposed financing (assumed by the factory)", st["h1"]))
    financing = [
        ["Item", "Value"],
        ["Loan amount", f"{_bdt(plan.loan_bdt)} ({terms.loan_share * 100:.0f}% of capex)"],
        ["Factory's own money", _bdt(plan.own_money_bdt)],
        ["Term and interest rate", f"{terms.years} years at {terms.annual_rate_pct:g}% a year"],
        ["Monthly instalment", _bdt(emi)],
        ["Total interest", _bdt(plan.total_interest_bdt)],
        ["Lowest yearly coverage (net savings / repayment)", "-" if plan.min_coverage is None else f"{plan.min_coverage:.2f}x"],
        [f"Net savings after the loan is repaid (years {terms.years + 1}-{len(plan.net_by_year)})", _bdt(plan.savings_after_loan_bdt)],
    ]
    story.append(base._table(_wrapped(financing, st["body"]), [100 * mm, 70 * mm]))
    story.append(Spacer(1, 3 * mm))
    story.append(Image(io.BytesIO(loan_coverage_chart(plan.net_by_year, plan.repayment_by_year)), width=170 * mm, height=60 * mm))

    # ---- evidence
    story.append(Paragraph("The evidence behind the numbers", st["h1"]))
    elec = [b for b in bills if b.bill_type == "electricity"]
    elec_months = {b.billing_month for b in elec}
    paid = [b.total_amount_bdt for b in elec if b.total_amount_bdt is not None]
    from_photo = sum(1 for b in bills if b.origin == "bill_image")
    evidence = [
        ["Item", "Value"],
        ["Bill history", f"{len(bills)} utility bills, {period}"],
        ["How they were entered", f"{from_photo} read from bill photos and confirmed by the manager, {len(bills) - from_photo} typed or imported"],
        ["Average grid electricity", "-" if not elec_months else f"{sum(b.consumed_units for b in elec) / len(elec_months):,.0f} kWh a month"],
        ["Average electricity bill", "-" if not paid or not elec_months else f"{_bdt(sum(paid) / len(elec_months))} a month"],
        ["Carbon footprint in the period", "-" if carbon.totals.total_t is None else f"{carbon.totals.total_t:,.1f} tCO2e (Scope 1 + 2)"],
    ]
    story.append(base._table(_wrapped(evidence, st["body"]), [70 * mm, 100 * mm]))

    # ---- readiness
    story.append(Paragraph("Readiness checklist", st["h1"]))
    checks: list[list[object]] = [["Check", "Status", "Detail"]]
    for name, ok, detail in readiness(factory, carbon, solar, plan):
        checks.append([name, "Ready" if ok else "To do", Paragraph(escape(detail), st["small"])])
    table = base._table(checks, [75 * mm, 20 * mm, 75 * mm])
    for i, row in enumerate(checks[1:], start=1):
        table.setStyle([("TEXTCOLOR", (1, i), (1, i), colors.HexColor("#047857" if row[1] == "Ready" else "#b45309"))])
    story.append(table)

    story.append(Paragraph("Where to apply", st["h1"]))
    story.append(Paragraph(escape(WHERE_TO_APPLY), st["body"]))
    story.append(Paragraph("Lenders usually ask for", st["h2"]))
    for item in USUALLY_ASKED:
        story.append(Paragraph("&bull; " + escape(item), st["body"]))
    story += [Spacer(1, 4 * mm), Paragraph(escape(DISCLAIMER), st["small"]), Paragraph(escape(solar.disclaimer), st["small"])]

    def on_page(canvas: Canvas, doc: SimpleDocTemplate) -> None:
        canvas.saveState()
        w, h = A4
        if synthetic:
            canvas.setFont(base._FONT_BOLD, 9)
            canvas.setFillColor(colors.HexColor("#b00020"))
            canvas.drawCentredString(w / 2, h - 12 * mm, base.SYNTHETIC_STAMP)
        canvas.setFont(base._FONT, 7)
        canvas.setFillColor(colors.HexColor("#666666"))
        canvas.drawString(15 * mm, 10 * mm, f"{factory.name} - green finance summary")
        canvas.drawRightString(w - 15 * mm, 10 * mm, f"Page {doc.page}")
        canvas.restoreState()

    buf = io.BytesIO()
    doc = SimpleDocTemplate(buf, pagesize=A4, leftMargin=18 * mm, rightMargin=18 * mm, topMargin=20 * mm, bottomMargin=18 * mm, title=f"Green finance summary - {factory.name}", author="BillToGreen")
    doc.build(story, onFirstPage=on_page, onLaterPages=on_page)
    return buf.getvalue()
