"""Emission factor lookup and metadata (values come only from config/emission_factors.yaml)."""

from __future__ import annotations

from app.schemas import FactorInfo, SourceType
from app.settings import ConfigValue, EmissionFactors

FACTOR_FOR_SOURCE: dict[SourceType, str] = {
    "electricity": "grid_electricity",
    "diesel": "diesel",
    "gas": "natural_gas",
}


def factor_info(name: str, cv: ConfigValue) -> FactorInfo:
    return FactorInfo(
        name=name,
        value=cv.value,
        unit=cv.unit,
        source=cv.source,
        year=cv.year,
        status=cv.status,
        notes=cv.notes,
        gases=cv.gases,
    )


def all_factor_info(factors: EmissionFactors) -> dict[str, FactorInfo]:
    return {name: factor_info(name, cv) for name, cv in factors.as_dict().items()}


def factor_for(factors: EmissionFactors, source: SourceType) -> tuple[str, ConfigValue]:
    name = FACTOR_FOR_SOURCE[source]
    return name, factors.as_dict()[name]
