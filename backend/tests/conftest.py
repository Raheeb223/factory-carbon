from __future__ import annotations

import shutil
import sys
from collections.abc import Callable
from pathlib import Path
from typing import Any

import pytest
import yaml
from fastapi.testclient import TestClient

BACKEND = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND))
sys.path.insert(0, str(BACKEND / "scripts"))

from app.api import Services  # noqa: E402
from app.main import build_services, create_app  # noqa: E402
from app.schemas import ExtractedBill  # noqa: E402
from app.settings import DEFAULT_CONFIG_DIR, Settings  # noqa: E402
from app.solar.nasa_power import NasaPowerClient  # noqa: E402

TOKEN = "test-token"
AUTH = {"X-App-Token": TOKEN}
PNG_BYTES = b"\x89PNG\r\n\x1a\n" + b"\x00" * 64
JPEG_BYTES = b"\xff\xd8\xff\xe0" + b"\x00" * 64

BPDB_BILL = ExtractedBill(
    bill_type="electricity",
    utility_name="Bangladesh Power Development Board",
    billing_month="2024-05",
    period_start="2024-05-01",  # type: ignore[arg-type]
    period_end="2024-05-30",  # type: ignore[arg-type]
    consumed_units=120,
    unit="kWh",
    total_amount_bdt=684.0,
    tariff_code="LT-B",
    sanctioned_load_kw=2.0,
    field_confidence={"consumed_units": "high", "total_amount_bdt": "medium"},
    notes="Multiplying factor 1.2 printed.",
)


class FakeExtractor:
    model = "fake-model"

    def __init__(self, bill: ExtractedBill = BPDB_BILL, error: Exception | None = None) -> None:
        self.bill = bill
        self.error = error
        self.calls: list[tuple[int, str]] = []

    def extract(self, image: bytes, mime_type: str) -> ExtractedBill:
        self.calls.append((len(image), mime_type))
        if self.error:
            raise self.error
        return self.bill


class FakeNasa(NasaPowerClient):
    def __init__(self, values: list[float] | None = None) -> None:
        super().__init__(timeout_s=1)
        self.values = values or [4.5] * 12
        self.calls = 0

    def monthly_peak_sun_hours(self, lat: float, lon: float) -> list[float]:
        self.calls += 1
        return list(self.values)


def make_settings(config_dir: Path = DEFAULT_CONFIG_DIR, **overrides: Any) -> Settings:
    values: dict[str, Any] = {"app_token": TOKEN, "gemini_api_key": None, "gemini_model": None, "config_dir": config_dir}
    values.update(overrides)
    return Settings(_env_file=None, **values)  # type: ignore[call-arg]


@pytest.fixture
def config_dir_factory(tmp_path: Path) -> Callable[..., Path]:
    """Copy the real config dir and patch emission factor values for a test."""

    def make(statuses: dict[str, str] | None = None, **factor_values: float | None) -> Path:
        d = tmp_path / "config"
        shutil.copytree(DEFAULT_CONFIG_DIR, d, dirs_exist_ok=True)
        path = d / "emission_factors.yaml"
        data = yaml.safe_load(path.read_text(encoding="utf-8"))
        for name, value in factor_values.items():
            data[name]["value"] = value
            if value is None:
                data[name]["status"] = "PLACEHOLDER"
        for name, status in (statuses or {}).items():
            data[name]["status"] = status
        path.write_text(yaml.safe_dump(data), encoding="utf-8")
        return d

    return make


def make_client(
    config_dir: Path = DEFAULT_CONFIG_DIR,
    extractor: Any = None,
    nasa: NasaPowerClient | None = None,
    **settings_overrides: Any,
) -> tuple[TestClient, Services]:
    svc = build_services(make_settings(config_dir, **settings_overrides), extractor=extractor, nasa=nasa or FakeNasa())
    return TestClient(create_app(svc), raise_server_exceptions=False), svc


@pytest.fixture
def client() -> TestClient:
    return make_client(extractor=FakeExtractor())[0]
