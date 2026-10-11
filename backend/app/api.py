"""/v1 routes."""

from __future__ import annotations

import logging
from dataclasses import dataclass, field
from typing import Annotated

from fastapi import APIRouter, Depends, File, Header, Request, UploadFile
from fastapi.concurrency import run_in_threadpool
from fastapi.responses import PlainTextResponse, Response

from app.carbon.calculator import calculate
from app.extraction.gemini_client import ExtractionFailed, GeminiExtractor
from app.extraction.prompts import PROMPT_VERSION
from app.extraction.upload import read_limited, validate_image
from app.extraction.validate import validate_bill
from app.report.pdf import build_pdf
from app.schemas import (
    CarbonCalculateRequest,
    CarbonCalculateResponse,
    ErrorResponse,
    ExtractBillResponse,
    HealthFactorStatus,
    HealthResponse,
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
    extractor: GeminiExtractor | None = None
    history_template: str = field(default="")


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
    return calculate(req, svc.config.emission_factors)


@router.post("/waste/analyze", response_model=WasteAnalyzeResponse, tags=["waste"])
def waste_analyze(req: WasteAnalyzeRequest) -> WasteAnalyzeResponse:
    return analyze(req)


@router.get("/solar/defaults", response_model=SolarDefaultsResponse, tags=["solar"])
def solar_defaults(svc: ServicesDep) -> SolarDefaultsResponse:
    d = svc.config.solar_defaults
    params = resolve_params(SolarParamOverrides(), d, []).used
    return SolarDefaultsResponse(params=params, net_metering=d.net_metering, disclaimer=DISCLAIMER)


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
    carbon = calculate(req.carbon, svc.config.emission_factors)
    pdf = build_pdf(req.factory, carbon, req.solar, synthetic=req.contains_synthetic_data, bills=req.carbon.bills)
    return Response(content=pdf, media_type="application/pdf", headers={"Content-Disposition": 'attachment; filename="ghg-report.pdf"'})


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
