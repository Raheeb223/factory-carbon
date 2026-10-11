"""Rooftop solar pre-feasibility model (spec 6.4).

annual kWh = kWp x peak sun hours x days x performance ratio, month by month.
kWp = roof area x usable fraction / m2 per kWp.
Without net metering, energy the factory cannot use in a month is not counted.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass

from app.carbon.factors import factor_info
from app.schemas import (
    CashFlowYear,
    ConsumptionMonth,
    FactorInfo,
    LatLon,
    SolarEstimateResponse,
    SolarFinancials,
    SolarParamOverrides,
    SolarParamUsed,
    SolarWarning,
)
from app.settings import ConfigValue, EmissionFactors, SolarDefaults

DISCLAIMER = "Pre-feasibility estimate. Structural load, shading and electrical design need a professional assessment."
DAYS_IN_MONTH = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)


@dataclass(frozen=True)
class ResolvedParams:
    usable_roof_fraction: float
    m2_per_kwp: float
    performance_ratio: float
    degradation_per_year: float
    capex_bdt_per_kwp: float | None
    om_fraction_of_capex_per_year: float | None
    electricity_price_bdt_per_kwh: float | None
    export_price_bdt_per_kwh: float | None
    net_metering: bool
    analysis_years: int
    used: list[SolarParamUsed]


def _pick(name: str, override: float | None, cv: ConfigValue) -> tuple[float | None, SolarParamUsed]:
    if override is not None:
        return override, SolarParamUsed(name=name, value=override, unit=cv.unit, origin="override", status=None, source="entered by user")
    return cv.value, SolarParamUsed(name=name, value=cv.value, unit=cv.unit, origin="default", status=cv.status, source=cv.source)


def average_price(consumption: list[ConsumptionMonth]) -> float | None:
    paired = [(c.kwh, c.cost_bdt) for c in consumption if c.cost_bdt is not None and c.kwh > 0]
    kwh = sum(k for k, _ in paired)
    return sum(c for _, c in paired) / kwh if kwh > 0 else None


def resolve_params(o: SolarParamOverrides, d: SolarDefaults, consumption: list[ConsumptionMonth]) -> ResolvedParams:
    used: list[SolarParamUsed] = []

    def pick(name: str, override: float | None, cv: ConfigValue) -> float | None:
        value, info = _pick(name, override, cv)
        used.append(info)
        return value

    usable = pick("usable_roof_fraction", o.usable_roof_fraction, d.usable_roof_fraction)
    m2 = pick("m2_per_kwp", o.m2_per_kwp, d.m2_per_kwp)
    pr = pick("performance_ratio", o.performance_ratio, d.performance_ratio)
    deg = pick("degradation_per_year", o.degradation_per_year, d.degradation_per_year)
    capex = pick("capex_bdt_per_kwp", o.capex_bdt_per_kwp, d.capex_bdt_per_kwp)
    om = pick("om_fraction_of_capex_per_year", o.om_fraction_of_capex_per_year, d.om_fraction_of_capex_per_year)
    export = pick("export_price_bdt_per_kwh", o.export_price_bdt_per_kwh, d.export_price_bdt_per_kwh)
    years = pick("analysis_years", float(o.analysis_years) if o.analysis_years is not None else None, d.analysis_years)

    if o.electricity_price_bdt_per_kwh is not None:
        price: float | None = o.electricity_price_bdt_per_kwh
        used.append(SolarParamUsed(name="electricity_price_bdt_per_kwh", value=price, unit="BDT_per_kWh", origin="override", status=None, source="entered by user"))
    else:
        price = average_price(consumption)
        used.append(SolarParamUsed(name="electricity_price_bdt_per_kwh", value=None if price is None else round(price, 4), unit="BDT_per_kWh", origin="derived", status=None, source="average of the factory's bills (total BDT / total kWh)"))

    net = o.net_metering if o.net_metering is not None else d.net_metering
    used.append(SolarParamUsed(name="net_metering", value=net, unit="bool", origin="override" if o.net_metering is not None else "default", status=None, source="entered by user" if o.net_metering is not None else "solar_defaults.yaml"))

    if usable is None or m2 is None or pr is None or deg is None or years is None:
        raise ValueError("solar defaults are incomplete")
    return ResolvedParams(usable, m2, pr, deg, capex, om, price, export, net, int(years), used)


def _w(code: str, message: str, value: float | None = None) -> SolarWarning:
    return SolarWarning(code=code, message=message, value=value)


def typical_year_consumption(consumption: list[ConsumptionMonth]) -> tuple[list[float] | None, list[SolarWarning]]:
    """Average kWh per calendar month. Missing calendar months use the overall monthly mean."""
    if not consumption:
        return None, []
    by_cal: dict[int, list[float]] = defaultdict(list)
    for c in consumption:
        by_cal[int(c.month[5:7])].append(c.kwh)
    mean_all = sum(c.kwh for c in consumption) / len(consumption)
    warnings: list[SolarWarning] = []
    missing = [m for m in range(1, 13) if m not in by_cal]
    if missing:
        covered = 12 - len(missing)
        warnings.append(_w("consumption_partial_year", f"Consumption history covers {covered} of 12 calendar months; the others use the average month.", covered))
    return [sum(by_cal[m]) / len(by_cal[m]) if m in by_cal else mean_all for m in range(1, 13)], warnings


def estimate(
    *,
    area_m2: float,
    centroid: LatLon,
    psh_monthly: list[float],
    irradiance_source: str,
    params: ResolvedParams,
    consumption: list[ConsumptionMonth],
    factors: EmissionFactors,
) -> SolarEstimateResponse:
    warnings: list[SolarWarning] = []
    usable_area = area_m2 * params.usable_roof_fraction
    kwp = usable_area / params.m2_per_kwp
    gen = [kwp * psh * days * params.performance_ratio for psh, days in zip(psh_monthly, DAYS_IN_MONTH, strict=True)]
    annual_gen = sum(gen)

    cons, cons_warnings = typical_year_consumption(consumption)
    warnings += cons_warnings

    def split(year_gen: list[float]) -> tuple[float, float]:
        assert cons is not None
        self_c = sum(min(g, c) for g, c in zip(year_gen, cons, strict=True))
        exported = sum(year_gen) - self_c if params.net_metering else 0.0
        return self_c, exported

    annual_cons = sum(cons) if cons else None
    self_c: float | None = None
    exported: float | None = None
    offset: float | None = None
    if cons is not None:
        self_c, exported = split(gen)
        offset = self_c / annual_cons if annual_cons else None
        if not params.net_metering and annual_gen - self_c > 1e-6:
            warnings.append(_w("excess_not_counted", f"About {annual_gen - self_c:,.0f} kWh/year exceeds monthly consumption and is not counted (no net metering).", round(annual_gen - self_c)))
    else:
        warnings.append(_w("no_consumption", "No consumption history provided, so the share of consumption offset and savings cannot be estimated."))

    grid_name = "grid_electricity"
    grid = factors.grid_electricity
    co2: float | None = None
    displaced = (self_c or 0.0) + (exported or 0.0) if cons is not None else (annual_gen if params.net_metering else None)
    if grid.value is None:
        warnings.append(_w("grid_factor_not_set", "Grid emission factor is not set in the backend configuration, so CO2 avoided cannot be calculated."))
    elif displaced is None:
        warnings.append(_w("co2_needs_consumption", "CO2 avoided needs consumption history (or net metering) to know how much grid electricity is displaced."))
    else:
        co2 = displaced * grid.value / 1000.0
        if grid.status == "PLACEHOLDER":
            warnings.append(_w("grid_factor_placeholder", "CO2 avoided uses an unverified (PLACEHOLDER) grid emission factor."))

    financials = _financials(kwp, gen, cons, params, warnings)
    factor_map: dict[str, FactorInfo] = {grid_name: factor_info(grid_name, grid)}
    return SolarEstimateResponse(
        roof_area_m2=round(area_m2, 2),
        usable_area_m2=round(usable_area, 2),
        kwp=round(kwp, 3),
        centroid=centroid,
        peak_sun_hours_monthly=[round(v, 4) for v in psh_monthly],
        peak_sun_hours_annual_avg=round(sum(p * d for p, d in zip(psh_monthly, DAYS_IN_MONTH, strict=True)) / 365, 4),
        irradiance_source=irradiance_source,  # type: ignore[arg-type]
        monthly_generation_kwh=[round(g, 1) for g in gen],
        annual_generation_kwh=round(annual_gen, 1),
        annual_consumption_kwh=None if annual_cons is None else round(annual_cons, 1),
        self_consumed_kwh=None if self_c is None else round(self_c, 1),
        exported_kwh=None if exported is None else round(exported, 1),
        offset_share=None if offset is None else round(offset, 4),
        co2_avoided_t_per_year=None if co2 is None else round(co2, 3),
        financials=financials,
        params_used=params.used,
        factors=factor_map,
        warnings=warnings,
        disclaimer=DISCLAIMER,
    )


def _financials(
    kwp: float, gen1: list[float], cons: list[float] | None, p: ResolvedParams, warnings: list[SolarWarning]
) -> SolarFinancials | None:
    if p.capex_bdt_per_kwp is None:
        return None
    if p.electricity_price_bdt_per_kwh is None:
        warnings.append(_w("price_missing", "Financials need an electricity price: enter one, or add bills with amounts."))
        return None
    if cons is None and not p.net_metering:
        warnings.append(_w("financials_need_consumption", "Financials need consumption history when there is no net metering."))
        return None
    om_frac = p.om_fraction_of_capex_per_year
    if om_frac is None:
        warnings.append(_w("om_not_included", "O&M cost is not included (no O&M rate set)."))
        om_frac = 0.0
    export_price = p.export_price_bdt_per_kwh
    if p.net_metering and export_price is None:
        warnings.append(_w("export_price_missing", "Net metering is on but no export price is set; exported energy is valued at zero."))
        export_price = 0.0
    warnings.append(_w("financial_assumptions", "Financials assume a constant electricity price (no tariff escalation) and no financing cost."))

    capex = kwp * p.capex_bdt_per_kwp
    om = capex * om_frac
    rows = [CashFlowYear(year=0, generation_kwh=0.0, savings_bdt=0.0, om_bdt=0.0, net_bdt=round(-capex, 0), cumulative_bdt=round(-capex, 0))]
    cumulative = -capex
    year1_savings = year1_net = 0.0
    for year in range(1, p.analysis_years + 1):
        factor = (1.0 - p.degradation_per_year) ** (year - 1)
        gen = [g * factor for g in gen1]
        if cons is not None:
            self_c = sum(min(g, c) for g, c in zip(gen, cons, strict=True))
        else:
            self_c = 0.0
        exported = (sum(gen) - self_c) if p.net_metering else 0.0
        savings = self_c * p.electricity_price_bdt_per_kwh + exported * (export_price or 0.0)
        net = savings - om
        cumulative += net
        if year == 1:
            year1_savings, year1_net = savings, net
        rows.append(CashFlowYear(year=year, generation_kwh=round(sum(gen), 1), savings_bdt=round(savings, 0), om_bdt=round(om, 0), net_bdt=round(net, 0), cumulative_bdt=round(cumulative, 0)))
    payback = capex / year1_net if year1_net > 0 else None
    if payback is None:
        warnings.append(_w("no_payback", "Yearly savings do not cover O&M, so there is no payback."))
    return SolarFinancials(
        capex_bdt=round(capex, 0),
        electricity_price_bdt_per_kwh=round(p.electricity_price_bdt_per_kwh, 4),
        year1_savings_bdt=round(year1_savings, 0),
        year1_om_bdt=round(om, 0),
        year1_net_bdt=round(year1_net, 0),
        simple_payback_years=None if payback is None else round(payback, 2),
        cashflow=rows,
    )
