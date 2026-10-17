from __future__ import annotations

from datetime import date

from fastapi.testclient import TestClient

from app.security import DailyCap, RateLimiter
from tests.conftest import AUTH, make_client


def test_health_ok(client: TestClient) -> None:
    r = client.get("/v1/health", headers=AUTH)
    assert r.status_code == 200
    body = r.json()
    assert body["status"] == "ok"
    assert body["api_version"] == "v1"
    assert body["emission_factors"]["grid_electricity"] == {"status": "verified", "has_value": True}
    assert not any(p.startswith("emission_factors.") for p in body["placeholders"])


def test_missing_or_wrong_token_rejected(client: TestClient) -> None:
    assert client.get("/v1/health").status_code == 401
    r = client.get("/v1/health", headers={"X-App-Token": "nope"})
    assert r.status_code == 401
    assert r.json()["error"]["code"] == "invalid_app_token"


def test_no_app_token_configured_is_503() -> None:
    c, _ = make_client(app_token=None)
    r = c.get("/v1/health", headers=AUTH)
    assert r.status_code == 503


def test_livez_needs_no_token(client: TestClient) -> None:
    assert client.get("/livez").json() == {"status": "ok"}


def test_openapi_lists_all_endpoints(client: TestClient) -> None:
    paths = client.get("/openapi.json").json()["paths"]
    for p in [
        "/v1/health",
        "/v1/extract-bill",
        "/v1/carbon/calculate",
        "/v1/waste/analyze",
        "/v1/solar/estimate",
        "/v1/solar/defaults",
        "/v1/report/pdf",
        "/v1/templates/history.csv",
    ]:
        assert p in paths


def test_rate_limit_per_ip() -> None:
    c, _ = make_client(rate_limit_per_minute=3)
    codes = [c.get("/v1/health", headers=AUTH).status_code for _ in range(5)]
    assert codes == [200, 200, 200, 429, 429]
    r = c.get("/v1/health", headers=AUTH)
    assert r.json()["error"]["code"] == "rate_limited"
    assert "Retry-After" in r.headers


def test_rate_limiter_window_slides() -> None:
    now = [0.0]
    rl = RateLimiter(limit=2, window_s=60, clock=lambda: now[0])
    assert rl.hit("a") is None
    assert rl.hit("a") is None
    assert rl.hit("a") is not None
    assert rl.hit("b") is None  # other IPs unaffected
    now[0] = 61
    assert rl.hit("a") is None


def test_daily_cap_resets_next_day() -> None:
    day = [date(2026, 1, 1)]
    cap = DailyCap(2, today=lambda: day[0])
    assert cap.try_acquire() and cap.try_acquire()
    assert not cap.try_acquire()
    day[0] = date(2026, 1, 2)
    assert cap.try_acquire()
    assert cap.used_today == 1


def test_oversized_json_body_rejected(client: TestClient) -> None:
    r = client.post("/v1/carbon/calculate", headers={**AUTH, "content-type": "application/json"}, content=b"{" + b" " * (3 * 1024 * 1024) + b"}")
    assert r.status_code == 413


def test_validation_error_does_not_echo_input(client: TestClient) -> None:
    secret = "CONSUMER-123456789"
    r = client.post("/v1/carbon/calculate", headers=AUTH, json={"bills": [{"billing_month": secret}]})
    assert r.status_code == 422
    assert secret not in r.text
    assert r.json()["error"]["code"] == "invalid_request"


def test_history_template(client: TestClient) -> None:
    r = client.get("/v1/templates/history.csv", headers=AUTH)
    assert r.status_code == 200
    assert r.text.splitlines()[0] == "month,electricity_kwh,diesel_litres,gas_m3,production_units,electricity_cost_bdt,lpg_kg,furnace_oil_litres"
