"""FastAPI application factory, middleware and error handling.

The backend is stateless: no database, no files written for user data, and request
bodies are never logged.
"""

from __future__ import annotations

import asyncio
import logging
from collections.abc import Awaitable, Callable

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse, Response
from pydantic import ValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.api import Services, router
from app.extraction.gemini_client import GeminiExtractor, build_genai_client
from app.security import ApiError, DailyCap, RateLimiter
from app.settings import API_VERSION, APP_VERSION, Settings, get_settings, load_app_config
from app.solar.nasa_power import NasaPowerClient

logger = logging.getLogger("app")

JSON_BODY_LIMIT = 2 * 1024 * 1024


def _error(status: int, code: str, message: str, headers: dict[str, str] | None = None) -> JSONResponse:
    return JSONResponse(status_code=status, content={"error": {"code": code, "message": message}}, headers=headers)


def build_services(settings: Settings, extractor: GeminiExtractor | None = None, nasa: NasaPowerClient | None = None) -> Services:
    config = load_app_config(settings.config_dir)
    daily_cap = DailyCap(settings.daily_gemini_cap)
    if extractor is None and settings.gemini_configured:
        assert settings.gemini_api_key is not None and settings.gemini_model is not None
        client = build_genai_client(settings.gemini_api_key.get_secret_value(), settings.gemini_call_timeout_s)
        extractor = GeminiExtractor(client, settings.gemini_model, daily_cap)
    template_path = settings.config_dir / "history_template.csv"
    return Services(
        settings=settings,
        config=config,
        rate_limiter=RateLimiter(settings.rate_limit_per_minute),
        extract_rate_limiter=RateLimiter(settings.extract_rate_limit_per_minute),
        daily_cap=daily_cap,
        nasa=nasa or NasaPowerClient(settings.nasa_power_timeout_s, settings.nasa_cache_dir),
        extractor=extractor,
        history_template=template_path.read_text(encoding="utf-8"),
    )


def create_app(services: Services | None = None) -> FastAPI:
    svc = services or build_services(get_settings())
    app = FastAPI(
        title="Factory Energy & Carbon API",
        version=APP_VERSION,
        description="Stateless backend for the Factory Energy & Carbon mobile app. Every /v1 request needs the X-App-Token header.",
        docs_url="/docs",
        redoc_url=None,
        openapi_url="/openapi.json",
    )
    app.state.services = svc
    settings = svc.settings

    @app.middleware("http")
    async def limits(request: Request, call_next: Callable[[Request], Awaitable[Response]]) -> Response:
        is_upload = request.url.path == f"/{API_VERSION}/extract-bill"
        limit = settings.max_upload_bytes + 64 * 1024 if is_upload else JSON_BODY_LIMIT
        length = request.headers.get("content-length")
        if length is not None:
            try:
                if int(length) > limit:
                    return _error(413, "request_too_large", "Request body is too large.")
            except ValueError:
                return _error(400, "bad_request", "Invalid Content-Length header.")
        timeout = settings.extract_timeout_s if is_upload else settings.request_timeout_s
        try:
            return await asyncio.wait_for(call_next(request), timeout=timeout)
        except TimeoutError:
            logger.warning("request_timeout path=%s", request.url.path)
            return _error(504, "timeout", "The request took too long. Please try again.")

    @app.exception_handler(ApiError)
    async def api_error(_: Request, exc: ApiError) -> JSONResponse:
        return _error(exc.status_code, exc.code, exc.message, exc.headers)

    @app.exception_handler(RequestValidationError)
    async def validation_error(_: Request, exc: RequestValidationError) -> JSONResponse:
        # Never echo submitted values back (they may contain personal data).
        parts = []
        for err in exc.errors()[:10]:
            loc = ".".join(str(x) for x in err.get("loc", ()) if x != "body")
            parts.append(f"{loc}: {err.get('msg', 'invalid')}")
        return _error(422, "invalid_request", "Invalid request. " + "; ".join(parts))

    @app.exception_handler(StarletteHTTPException)
    async def http_error(_: Request, exc: StarletteHTTPException) -> JSONResponse:
        message = exc.detail if isinstance(exc.detail, str) else "Request failed."
        return _error(exc.status_code, f"http_{exc.status_code}", message)

    @app.exception_handler(Exception)
    async def unhandled(_: Request, exc: Exception) -> JSONResponse:
        logger.error("unhandled_error type=%s", type(exc).__name__)
        return _error(500, "internal_error", "Something went wrong on the server.")

    app.include_router(router)

    @app.get("/livez", include_in_schema=False)
    def livez() -> dict[str, str]:
        """Unauthenticated liveness probe for container hosts. Reveals nothing."""
        return {"status": "ok"}

    return app


def create_default_app() -> FastAPI:
    """Entry point: `uvicorn --factory app.main:create_default_app`."""
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s %(message)s")
    try:
        settings = get_settings()
    except ValidationError as e:
        # Name the bad env vars but never echo their values (they may be secrets).
        bad = ", ".join(str(err["loc"][0]).upper() for err in e.errors() if err.get("loc"))
        logger.error("Invalid environment variable(s): %s. Check their values in the host's settings.", bad)
        raise SystemExit(1) from None
    logger.info("Starting: gemini_configured=%s app_token_set=%s", settings.gemini_configured, bool(settings.app_token and settings.app_token.get_secret_value()))
    return create_app()
