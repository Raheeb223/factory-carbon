"""Environment settings and YAML config loading.

All runtime configuration comes from environment variables (see `.env.example`).
Domain constants (emission factors, solar defaults, validation bands) come from
YAML files in `backend/config/`, never from code.
"""

from __future__ import annotations

from functools import lru_cache
from pathlib import Path
from typing import Any, Literal

import yaml
from pydantic import BaseModel, Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

BACKEND_DIR = Path(__file__).resolve().parent.parent
DEFAULT_CONFIG_DIR = BACKEND_DIR / "config"

API_VERSION = "v1"
APP_VERSION = "0.1.0"


class Settings(BaseSettings):
    """Process settings, read from env vars (and `backend/.env` in local runs)."""

    model_config = SettingsConfigDict(
        env_file=BACKEND_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    gemini_api_key: SecretStr | None = None
    gemini_model: str | None = None
    app_token: SecretStr | None = None
    daily_gemini_cap: int = Field(default=200, ge=0)
    max_upload_mb: float = Field(default=8.0, gt=0, le=50)

    rate_limit_per_minute: int = Field(default=60, ge=1)
    extract_rate_limit_per_minute: int = Field(default=10, ge=1)
    request_timeout_s: float = Field(default=30.0, gt=0)
    extract_timeout_s: float = Field(default=120.0, gt=0)
    gemini_call_timeout_s: float = Field(default=45.0, gt=0)
    trust_proxy_headers: bool = False
    nasa_power_timeout_s: float = Field(default=20.0, gt=0)
    nasa_cache_dir: Path | None = None
    config_dir: Path = DEFAULT_CONFIG_DIR

    @field_validator("gemini_model", mode="before")
    @classmethod
    def _blank_model_is_none(cls, v: Any) -> Any:
        if isinstance(v, str) and not v.strip():
            return None
        return v

    @property
    def max_upload_bytes(self) -> int:
        return int(self.max_upload_mb * 1024 * 1024)

    @property
    def gemini_configured(self) -> bool:
        return bool(self.gemini_api_key and self.gemini_api_key.get_secret_value() and self.gemini_model)


FactorStatus = Literal["verified", "PLACEHOLDER"]


class ConfigValue(BaseModel):
    """A configured constant with provenance. `value` may be null when not yet set."""

    value: float | None
    unit: str
    source: str = ""
    year: int | None = None
    status: FactorStatus
    notes: str | None = None
    # Which gases the factor covers, e.g. "CO2 only" or "CO2e (CO2 + CH4 + N2O)".
    gases: str | None = None

    @property
    def is_set(self) -> bool:
        return self.value is not None


class EmissionFactors(BaseModel):
    grid_electricity: ConfigValue
    diesel: ConfigValue
    natural_gas: ConfigValue
    lpg: ConfigValue
    furnace_oil: ConfigValue

    def as_dict(self) -> dict[str, ConfigValue]:
        return {
            "grid_electricity": self.grid_electricity,
            "diesel": self.diesel,
            "natural_gas": self.natural_gas,
            "lpg": self.lpg,
            "furnace_oil": self.furnace_oil,
        }


class EnergyContent(BaseModel):
    """Net calorific value per unit of each fuel (kWh per litre, m3 or kg)."""

    diesel: ConfigValue
    natural_gas: ConfigValue
    lpg: ConfigValue
    furnace_oil: ConfigValue


class SolarDefaults(BaseModel):
    usable_roof_fraction: ConfigValue
    m2_per_kwp: ConfigValue
    performance_ratio: ConfigValue
    shading_loss: ConfigValue
    degradation_per_year: ConfigValue
    capex_bdt_per_kwp: ConfigValue
    om_fraction_of_capex_per_year: ConfigValue
    export_price_bdt_per_kwh: ConfigValue
    analysis_years: ConfigValue
    net_metering: bool = False
    min_polygon_area_m2: float = 20.0
    max_polygon_area_m2: float = 500_000.0

    def numeric_params(self) -> dict[str, ConfigValue]:
        return {
            "usable_roof_fraction": self.usable_roof_fraction,
            "m2_per_kwp": self.m2_per_kwp,
            "performance_ratio": self.performance_ratio,
            "shading_loss": self.shading_loss,
            "degradation_per_year": self.degradation_per_year,
            "capex_bdt_per_kwp": self.capex_bdt_per_kwp,
            "om_fraction_of_capex_per_year": self.om_fraction_of_capex_per_year,
            "export_price_bdt_per_kwh": self.export_price_bdt_per_kwh,
            "analysis_years": self.analysis_years,
        }


class Band(BaseModel):
    min: float
    max: float


class ValidationRules(BaseModel):
    """Sanity bands used to warn (never block) on extracted bill values."""

    period_days: Band
    units_ceiling: dict[str, float]
    bdt_per_unit: dict[str, Band]
    notes: str | None = None


class AppConfig(BaseModel):
    emission_factors: EmissionFactors
    solar_defaults: SolarDefaults
    validation_rules: ValidationRules
    energy_content: EnergyContent | None = None

    def placeholder_names(self) -> list[str]:
        names = [f"emission_factors.{k}" for k, v in self.emission_factors.as_dict().items() if v.status == "PLACEHOLDER"]
        names += [f"solar_defaults.{k}" for k, v in self.solar_defaults.numeric_params().items() if v.status == "PLACEHOLDER"]
        return names


def _read_yaml(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict):
        raise ValueError(f"{path.name} must contain a mapping")
    return data


def load_app_config(config_dir: Path) -> AppConfig:
    return AppConfig(
        emission_factors=EmissionFactors.model_validate(_read_yaml(config_dir / "emission_factors.yaml")),
        solar_defaults=SolarDefaults.model_validate(_read_yaml(config_dir / "solar_defaults.yaml")),
        validation_rules=ValidationRules.model_validate(_read_yaml(config_dir / "validation_rules.yaml")),
        energy_content=EnergyContent.model_validate(_read_yaml(config_dir / "energy_content.yaml")) if (config_dir / "energy_content.yaml").exists() else None,
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
