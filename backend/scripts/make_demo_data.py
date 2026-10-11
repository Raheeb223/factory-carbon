"""Generate SYNTHETIC demo data: 24 months of bills + production with 2 injected anomalies.

Every number here is made up for demonstration and tests. Nothing describes a real
factory, tariff or emission level.

Usage:
    python scripts/make_demo_data.py                    # print JSON to stdout
    python scripts/make_demo_data.py --out ../app/assets/demo/demo_data.json
"""

from __future__ import annotations

import argparse
import json
import random
from dataclasses import asdict, dataclass, field
from pathlib import Path

START_YEAR, START_MONTH = 2023, 1
N_MONTHS = 24
ANOMALY_INDEXES = {9: 0.25, 19: 0.20}  # month index -> extra kWh fraction


@dataclass
class DemoMonth:
    month: str
    production_units: float
    electricity_kwh: float
    electricity_cost_bdt: float
    diesel_litres: float
    diesel_cost_bdt: float
    gas_m3: float
    gas_cost_bdt: float
    injected_anomaly: bool


@dataclass
class DemoData:
    synthetic: bool = True
    label: str = "SYNTHETIC DEMO DATA - not a real factory"
    seed: int = 42
    production_unit_label: str = "pieces"
    anomaly_months: list[str] = field(default_factory=list)
    months: list[DemoMonth] = field(default_factory=list)


def _month(i: int) -> str:
    y, m = divmod(START_MONTH - 1 + i, 12)
    return f"{START_YEAR + y:04d}-{m + 1:02d}"


def make_demo_data(seed: int = 42) -> DemoData:
    rng = random.Random(seed)
    data = DemoData(seed=seed)
    for i in range(N_MONTHS):
        season = 1.0 + 0.15 * [0, 0.3, 0.6, 0.8, 0.5, 0.0, -0.4, -0.8, -0.5, 0.2, 0.6, 0.4][i % 12]
        production = round(450_000 * season * rng.uniform(0.93, 1.07), -2)
        kwh = (25_000 + 0.32 * production) * rng.uniform(0.97, 1.03)
        anomaly = i in ANOMALY_INDEXES
        if anomaly:
            kwh *= 1.0 + ANOMALY_INDEXES[i]
            data.anomaly_months.append(_month(i))
        kwh = round(kwh)
        diesel = round(rng.uniform(1_500, 3_000))
        gas = round(rng.uniform(20_000, 30_000))
        data.months.append(
            DemoMonth(
                month=_month(i),
                production_units=production,
                electricity_kwh=kwh,
                electricity_cost_bdt=round(kwh * 10.5, 2),
                diesel_litres=diesel,
                diesel_cost_bdt=round(diesel * 106.0, 2),
                gas_m3=gas,
                gas_cost_bdt=round(gas * 30.0, 2),
                injected_anomaly=anomaly,
            )
        )
    return data


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    text = json.dumps(asdict(make_demo_data(args.seed)), indent=2)
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(text + "\n", encoding="utf-8")
        print(f"wrote {args.out}")
    else:
        print(text)


if __name__ == "__main__":
    main()
