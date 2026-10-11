"""Pydantic request/response models. The generated OpenAPI is the app<->backend contract."""

from __future__ import annotations

from datetime import date
from typing import Annotated, Literal

from pydantic import BaseModel, ConfigDict, Field

MONTH_PATTERN = r"^\d{4}-(0[1-9]|1[0-2])$"
Month = Annotated[str, Field(pattern=MONTH_PATTERN, examples=["2024-05"])]

BillType = Literal["electricity", "gas", "diesel", "unknown"]
SourceType = Literal["electricity", "gas", "diesel"]
UnitType = Literal["kWh", "m3", "litre"]
Confidence = Literal["high", "medium", "low"]
FactorStatus = Literal["verified", "PLACEHOLDER"]
DataOrigin = Literal["bill_image", "manual", "imported", "demo"]

CANONICAL_UNIT: dict[str, str] = {"electricity": "kWh", "gas": "m3", "diesel": "litre"}

EXTRACTED_FIELDS: tuple[str, ...] = (
    "bill_type",
    "utility_name",
    "billing_month",
    "period_start",
    "period_end",
    "consumed_units",
    "unit",
    "total_amount_bdt",
    "tariff_code",
    "sanctioned_load_kw",
)


class StrictModel(BaseModel):
    model_config = ConfigDict(extra="forbid")


# ---------------------------------------------------------------- errors / common


class ErrorBody(BaseModel):
    code: str
    message: str


class ErrorResponse(BaseModel):
    error: ErrorBody


class FactorInfo(BaseModel):
    """Metadata of a configured constant, returned wherever it is used."""

    name: str
    value: float | None
    unit: str
    source: str
    year: int | None
    status: FactorStatus
    notes: str | None = None
    gases: str | None = None


class DataQualityNote(BaseModel):
    code: str
    message: str
    months: list[str] = Field(default_factory=list)


# ---------------------------------------------------------------- health


class HealthFactorStatus(BaseModel):
    status: FactorStatus
    has_value: bool


class HealthResponse(BaseModel):
    status: Literal["ok"]
    app_version: str
    api_version: str
    gemini_configured: bool
    gemini_model: str | None
    emission_factors: dict[str, HealthFactorStatus]
    placeholders: list[str]


# ---------------------------------------------------------------- extraction


class ExtractedBill(BaseModel):
    """Structured data read from a bill. All fields nullable except bill_type."""

    bill_type: BillType
    utility_name: str | None = None
    billing_month: str | None = Field(default=None, pattern=MONTH_PATTERN)
    period_start: date | None = None
    period_end: date | None = None
    consumed_units: float | None = None
    unit: UnitType | None = None
    total_amount_bdt: float | None = None
    tariff_code: str | None = None
    sanctioned_load_kw: float | None = None
    field_confidence: dict[str, Confidence] = Field(default_factory=dict)
    notes: str | None = None


class ExtractionWarning(BaseModel):
    field: str | None
    code: str
    message: str


class ExtractBillResponse(BaseModel):
    bill: ExtractedBill
    warnings: list[ExtractionWarning]
    model: str
    prompt_version: str


# ---------------------------------------------------------------- carbon


class ConfirmedBillInput(StrictModel):
    """A bill the user has reviewed and confirmed on the device."""

    billing_month: Month
    bill_type: SourceType
    consumed_units: float = Field(ge=0)
    unit: UnitType
    total_amount_bdt: float | None = Field(default=None, ge=0)
    origin: DataOrigin = "bill_image"
    user_edited_fields: list[str] = Field(default_factory=list)
    # When the manager confirmed it (ISO date), listed in the report's audit trail.
    confirmed_at: str | None = Field(default=None, max_length=40)


class ProductionInput(StrictModel):
    month: Month
    units_produced: float = Field(ge=0)
    origin: DataOrigin = "manual"


class CarbonCalculateRequest(StrictModel):
    bills: list[ConfirmedBillInput] = Field(max_length=2000)
    production: list[ProductionInput] = Field(default_factory=list, max_length=600)
    production_unit_label: str | None = Field(default=None, max_length=40)
    period_start: Month | None = None
    period_end: Month | None = None


class MonthEmissions(BaseModel):
    month: str
    electricity_kwh: float | None
    diesel_litres: float | None
    gas_m3: float | None
    scope2_electricity_t: float | None
    scope1_diesel_t: float | None
    scope1_gas_t: float | None
    scope1_t: float | None
    scope2_t: float | None
    total_t: float | None
    is_complete: bool
    missing: list[str]
    production_units: float | None
    intensity_t_per_1000_units: float | None


class CarbonTotals(BaseModel):
    scope1_t: float | None
    scope2_t: float | None
    total_t: float | None
    production_units: float | None
    intensity_t_per_1000_units: float | None
    months_in_period: int
    months_with_data: int
    complete_months: int


class CalculationError(BaseModel):
    code: str
    factor: str
    message: str


class CarbonCalculateResponse(BaseModel):
    period_start: str | None
    period_end: str | None
    months: list[MonthEmissions]
    totals: CarbonTotals
    factors: dict[str, FactorInfo]
    placeholders_in_use: list[str]
    errors: list[CalculationError]
    data_quality_notes: list[DataQualityNote]
    production_unit_label: str | None
    methodology: list[str]


# ---------------------------------------------------------------- waste


class WasteMonthInput(StrictModel):
    month: Month
    kwh: float | None = Field(default=None, ge=0)
    production: float | None = Field(default=None, ge=0)
    cost_bdt: float | None = Field(default=None, ge=0)


class WasteAnalyzeRequest(StrictModel):
    months: list[WasteMonthInput] = Field(max_length=600)
    production_unit_label: str | None = Field(default=None, max_length=40)


class WasteMonthResult(BaseModel):
    month: str
    actual_kwh: float
    production: float | None
    expected_kwh: float | None
    lower_kwh: float | None
    upper_kwh: float | None
    flagged: bool
    excess_kwh: float | None
    excess_pct: float | None
    excess_cost_bdt: float | None
    kwh_per_unit: float | None = None
    expected_kwh_per_unit: float | None = None


class Inspection(BaseModel):
    """A practical check for a flagged month. `code` lets the app localize; text is English."""

    code: str
    title: str
    detail: str


class WasteAnalyzeResponse(BaseModel):
    status: Literal["ok", "insufficient_data"]
    method: Literal["ols_production", "median_mad"] | None
    confidence_label: str | None
    month_count: int
    required_months: int
    months: list[WasteMonthResult]
    flagged_months: list[str]
    avg_bdt_per_kwh: float | None
    messages: list[str]
    limitations: list[str]
    model_summary: dict[str, float | None]
    baseline_kwh_per_unit: float | None = None
    inspections: list[Inspection] = Field(default_factory=list)


# ---------------------------------------------------------------- solar


class LatLon(StrictModel):
    lat: float = Field(ge=-90, le=90)
    lon: float = Field(ge=-180, le=180)


class SolarParamOverrides(StrictModel):
    usable_roof_fraction: float | None = Field(default=None, gt=0, le=1)
    m2_per_kwp: float | None = Field(default=None, gt=0, le=50)
    performance_ratio: float | None = Field(default=None, gt=0, le=1)
    shading_loss: float | None = Field(default=None, ge=0, lt=0.9)
    degradation_per_year: float | None = Field(default=None, ge=0, lt=0.1)
    capex_bdt_per_kwp: float | None = Field(default=None, gt=0)
    om_fraction_of_capex_per_year: float | None = Field(default=None, ge=0, lt=0.5)
    electricity_price_bdt_per_kwh: float | None = Field(default=None, gt=0)
    export_price_bdt_per_kwh: float | None = Field(default=None, ge=0)
    net_metering: bool | None = None
    analysis_years: int | None = Field(default=None, ge=1, le=40)
    # Has an engineer checked the roof can carry panels? Only changes the warnings.
    roof_structure: Literal["unknown", "ok", "needs_work"] | None = None


class ConsumptionMonth(StrictModel):
    month: Month
    kwh: float = Field(ge=0)
    cost_bdt: float | None = Field(default=None, ge=0)


class SolarEstimateRequest(StrictModel):
    polygon: list[LatLon] = Field(min_length=3, max_length=200)
    params: SolarParamOverrides = Field(default_factory=SolarParamOverrides)
    consumption: list[ConsumptionMonth] = Field(default_factory=list, max_length=600)
    manual_peak_sun_hours: float | None = Field(default=None, gt=0, le=12)
    manual_peak_sun_hours_monthly: list[float] | None = Field(default=None, min_length=12, max_length=12)


class SolarParamUsed(BaseModel):
    name: str
    value: float | bool | None
    unit: str
    origin: Literal["default", "override", "derived"]
    status: FactorStatus | None
    source: str


class SolarWarning(BaseModel):
    """Machine-readable note so the app can localize it; `message` is English."""

    code: str
    message: str
    value: float | None = None


class CashFlowYear(BaseModel):
    year: int
    generation_kwh: float
    savings_bdt: float
    om_bdt: float
    net_bdt: float
    cumulative_bdt: float


class SolarFinancials(BaseModel):
    capex_bdt: float
    electricity_price_bdt_per_kwh: float
    year1_savings_bdt: float
    year1_om_bdt: float
    year1_net_bdt: float
    simple_payback_years: float | None
    cashflow: list[CashFlowYear]


class SolarEstimateResponse(BaseModel):
    roof_area_m2: float
    usable_area_m2: float
    kwp: float
    centroid: LatLon
    peak_sun_hours_monthly: list[float]
    peak_sun_hours_annual_avg: float
    irradiance_source: Literal["nasa_power", "manual"]
    monthly_generation_kwh: list[float]
    annual_generation_kwh: float
    annual_consumption_kwh: float | None
    self_consumed_kwh: float | None
    exported_kwh: float | None
    offset_share: float | None
    co2_avoided_t_per_year: float | None
    financials: SolarFinancials | None
    params_used: list[SolarParamUsed]
    factors: dict[str, FactorInfo]
    warnings: list[SolarWarning]
    disclaimer: str


class SolarDefaultsResponse(BaseModel):
    params: list[SolarParamUsed]
    net_metering: bool
    disclaimer: str


# ---------------------------------------------------------------- report


class FactoryInfo(StrictModel):
    name: str = Field(min_length=1, max_length=120)
    location: str | None = Field(default=None, max_length=200)


class ReportPdfRequest(StrictModel):
    factory: FactoryInfo
    carbon: CarbonCalculateRequest
    solar: SolarEstimateResponse | None = None
    contains_synthetic_data: bool = False
