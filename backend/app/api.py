"""/v1 routes."""

from __future__ import annotations

import logging
from datetime import date
from dataclasses import dataclass, field
from typing import Annotated

from fastapi import APIRouter, Depends, File, Header, Query, Request, UploadFile
from fastapi.concurrency import run_in_threadpool
from fastapi.responses import PlainTextResponse, Response

from app.carbon.calculator import calculate
from app.extraction.gemini_client import ExtractionFailed, GeminiExtractor
from app.extraction.prompts import PROMPT_VERSION
from app.extraction.upload import read_limited, validate_image
from app.extraction.validate import validate_bill
from app.report import loan, passport
from app.report.pdf import build_pdf
from app.schemas import (
    BuildingOutline,
    BuildingsResponse,
    CarbonCalculateRequest,
    CarbonCalculateResponse,
    ErrorResponse,
    ExtractBillResponse,
    HealthFactorStatus,
    HealthResponse,
    LatLon,
    LoanPdfRequest,
    PassportResponse,
    ReportPdfRequest,
    SolarDefaultsResponse,
    SolarEstimateRequest,
    SolarEstimateResponse,
    SolarParamOverrides,
    WasteAnalyzeRequest,
    WasteAnalyzeResponse,
)
from app.security import ApiError, DailyCap, RateLimiter, check_app_token, client_ip
from app.settings import API_VERSION, APP_VERSION, AppConfig, Settings
from app.solar.buildings import ATTRIBUTION, BuildingFootprints
from app.solar.geometry import roof_geometry
from app.solar.model import DISCLAIMER, estimate, resolve_params
from app.solar.nasa_power import NasaPowerClient
from app.waste.detector import analyze

logger = logging.getLogger(__name__)


@dataclass
class Services:
    settings: Settings
    config: AppConfig
    rate_limiter: RateLimiter
    extract_rate_limiter: RateLimiter
    daily_cap: DailyCap
    nasa: NasaPowerClient
    buildings: BuildingFootprints
    extractor: GeminiExtractor | None = None
    history_template: str = field(default="")
    passport_key: bytes = field(default=b"")


def services(request: Request) -> Services:
    return request.app.state.services  # type: ignore[no-any-return]


ServicesDep = Annotated[Services, Depends(services)]


def guard(request: Request, svc: ServicesDep, x_app_token: Annotated[str | None, Header()] = None) -> None:
    check_app_token(svc.settings, x_app_token)
    retry = svc.rate_limiter.hit(client_ip(request, svc.settings.trust_proxy_headers))
    if retry is not None:
        raise ApiError(429, "rate_limited", "Too many requests. Please wait a moment.", {"Retry-After": str(int(retry) + 1)})


ERRORS: dict[int | str, dict[str, object]] = {
    s: {"model": ErrorResponse} for s in (400, 401, 413, 415, 422, 429, 500, 502, 503, 504)
}
router = APIRouter(prefix=f"/{API_VERSION}", dependencies=[Depends(guard)], responses=ERRORS)


@router.get("/health", response_model=HealthResponse, tags=["meta"])
def health(svc: ServicesDep) -> HealthResponse:
    return HealthResponse(
        status="ok",
        app_version=APP_VERSION,
        api_version=API_VERSION,
        gemini_configured=svc.extractor is not None,
        gemini_model=svc.settings.gemini_model,
        emission_factors={
            k: HealthFactorStatus(status=v.status, has_value=v.value is not None)
            for k, v in svc.config.emission_factors.as_dict().items()
        },
        placeholders=svc.config.placeholder_names(),
    )


@router.post("/extract-bill", response_model=ExtractBillResponse, tags=["extraction"])
async def extract_bill(
    request: Request,
    svc: ServicesDep,
    file: Annotated[UploadFile, File(description="Bill image (PNG/JPEG) or single-page PDF")],
) -> ExtractBillResponse:
    retry = svc.extract_rate_limiter.hit(client_ip(request, svc.settings.trust_proxy_headers))
    if retry is not None:
        raise ApiError(429, "rate_limited", "Too many bill uploads. Please wait a moment.", {"Retry-After": str(int(retry) + 1)})
    if svc.extractor is None:
        raise ApiError(503, "extraction_unavailable", "Bill reading is not configured on the server. Enter the bill manually.")
    data = await read_limited(file, svc.settings.max_upload_bytes)
    mime = validate_image(data, file.content_type)
    extractor = svc.extractor
    try:
        bill = await run_in_threadpool(extractor.extract, data, mime)
    except ExtractionFailed as e:
        logger.warning("extraction_failed reason=%s", e)
        raise ApiError(502, "extraction_failed", "Could not read the bill. Try a clearer photo, or enter the values manually.") from e
    finally:
        del data  # image is never written anywhere; drop the reference promptly
    return ExtractBillResponse(
        bill=bill,
        warnings=validate_bill(bill, svc.config.validation_rules),
        model=extractor.model,
        prompt_version=PROMPT_VERSION,
    )


@router.post("/carbon/calculate", response_model=CarbonCalculateResponse, tags=["carbon"])
def carbon_calculate(req: CarbonCalculateRequest, svc: ServicesDep) -> CarbonCalculateResponse:
    return calculate(req, svc.config.emission_factors, svc.config.energy_content)


@router.post("/waste/analyze", response_model=WasteAnalyzeResponse, tags=["waste"])
def waste_analyze(req: WasteAnalyzeRequest) -> WasteAnalyzeResponse:
    return analyze(req)


@router.get("/solar/defaults", response_model=SolarDefaultsResponse, tags=["solar"])
def solar_defaults(svc: ServicesDep) -> SolarDefaultsResponse:
    d = svc.config.solar_defaults
    params = resolve_params(SolarParamOverrides(), d, []).used
    return SolarDefaultsResponse(params=params, net_metering=d.net_metering, disclaimer=DISCLAIMER)


@router.get("/solar/buildings", response_model=BuildingsResponse, tags=["solar"])
def solar_buildings(
    svc: ServicesDep,
    lat: Annotated[float, Query(ge=-90, le=90)],
    lon: Annotated[float, Query(ge=-180, le=180)],
    radius_m: Annotated[float, Query(ge=10, le=300)] = 150,
) -> BuildingsResponse:
    """Building outlines around a point, to suggest the roof on the solar map."""
    found = svc.buildings.near(lat, lon, radius_m)
    return BuildingsResponse(
        buildings=[
            BuildingOutline(
                polygon=[LatLon(lat=y, lon=x) for x, y in b.ring],
                area_m2=round(b.area_m2, 1),
                distance_m=round(b.distance_m, 1),
                source=b.source,
            )
            for b in found[:30]
        ],
        attribution=ATTRIBUTION,
    )


@router.post("/solar/estimate", response_model=SolarEstimateResponse, tags=["solar"])
def solar_estimate(req: SolarEstimateRequest, svc: ServicesDep) -> SolarEstimateResponse:
    d = svc.config.solar_defaults
    geom = roof_geometry(req.polygon, d.min_polygon_area_m2, d.max_polygon_area_m2)
    params = resolve_params(req.params, d, req.consumption)
    if req.manual_peak_sun_hours_monthly is not None:
        psh, source = list(req.manual_peak_sun_hours_monthly), "manual"
        if any(v <= 0 or v > 12 for v in psh):
            raise ApiError(422, "invalid_peak_sun_hours", "Monthly peak sun hours must be between 0 and 12.")
    elif req.manual_peak_sun_hours is not None:
        psh, source = [req.manual_peak_sun_hours] * 12, "manual"
    else:
        psh, source = svc.nasa.monthly_peak_sun_hours(geom.centroid.lat, geom.centroid.lon), "nasa_power"
    return estimate(
        area_m2=geom.area_m2,
        centroid=geom.centroid,
        psh_monthly=psh,
        irradiance_source=source,
        params=params,
        consumption=req.consumption,
        factors=svc.config.emission_factors,
    )


@router.post(
    "/report/pdf",
    response_class=Response,
    tags=["report"],
    responses={200: {"content": {"application/pdf": {}}, "description": "PDF report"}},
)
def report_pdf(req: ReportPdfRequest, svc: ServicesDep) -> Response:
    carbon = calculate(req.carbon, svc.config.emission_factors, svc.config.energy_content)
    pdf = build_pdf(req.factory, carbon, req.solar, synthetic=req.contains_synthetic_data, bills=req.carbon.bills)
    return Response(content=pdf, media_type="application/pdf", headers={"Content-Disposition": 'attachment; filename="ghg-report.pdf"'})


@router.post(
    "/report/loan-pdf",
    response_class=Response,
    tags=["report"],
    responses={200: {"content": {"application/pdf": {}}, "description": "Green finance readiness summary"}},
)
def report_loan_pdf(req: LoanPdfRequest, svc: ServicesDep) -> Response:
    """One-page summary for a bank: can the solar plan's savings repay a loan for it?"""
    plan = loan.plan_loan(req.solar, req.loan)
    if plan is None:
        raise ApiError(422, "solar_financials_missing", "The solar plan has no savings estimate. Add bills with amounts, then estimate again.")
    carbon = calculate(req.carbon, svc.config.emission_factors, svc.config.energy_content)
    pdf = loan.build_loan_pdf(req.factory, carbon, req.solar, req.loan, plan, synthetic=req.contains_synthetic_data, bills=req.carbon.bills)
    return Response(content=pdf, media_type="application/pdf", headers={"Content-Disposition": 'attachment; filename="green-loan-summary.pdf"'})


def public_base_url(request: Request, trust_proxy_headers: bool) -> str:
    """Scheme + host the phone used to reach us (Render terminates TLS in front of the app)."""
    base = str(request.base_url).rstrip("/")
    proto = request.headers.get("x-forwarded-proto", "").split(",")[0].strip()
    if trust_proxy_headers and proto in ("http", "https"):
        base = proto + base[base.index("://"):]
    return base


@router.post("/passport", response_model=PassportResponse, tags=["report"])
def create_passport(req: ReportPdfRequest, request: Request, svc: ServicesDep) -> PassportResponse:
    """Sign a one-page carbon summary and return a public link to it (for a QR code)."""
    carbon = calculate(req.carbon, svc.config.emission_factors, svc.config.energy_content)
    issued = date.today()
    summary = passport.build_summary(
        req.factory, carbon, req.solar, synthetic=req.contains_synthetic_data, bill_count=len(req.carbon.bills), issued=issued
    )
    token = passport.encode(summary, svc.passport_key)
    return PassportResponse(url=f"{public_base_url(request, svc.settings.trust_proxy_headers)}/p/{token}", issued_on=issued, total_t=carbon.totals.total_t)


@router.get(
    "/templates/history.csv",
    response_class=PlainTextResponse,
    tags=["templates"],
    responses={200: {"content": {"text/csv": {}}}},
)
def history_template(svc: ServicesDep) -> PlainTextResponse:
    return PlainTextResponse(
        svc.history_template,
        media_type="text/csv",
        headers={"Content-Disposition": 'attachment; filename="history_template.csv"'},
    )
