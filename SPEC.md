# SPEC: Factory Energy & Carbon (mobile app + backend)

You are building this project step by step. Read this whole file first, then work **one milestone at a time** (see "Milestones"). After each milestone: run all tests, tell me what works, what doesn't and what you assumed, then wait for my go-ahead.

Before choosing any package, SDK call or model ID, check the current official documentation. Do not rely on memory for versions, API shapes or model names.

## 1. Product

A mobile app for Bangladeshi garment factories. The user photographs utility bills and gets:

1. Structured data extracted from each bill (with a mandatory human review screen).
2. A monthly CO2e report (Scope 1 + Scope 2) exportable as PDF/CSV to send to buyers.
3. Warnings when electricity use is high for the production level.
4. A rooftop solar pre-feasibility estimate.

Users: compliance or sustainability managers at small and mid-size factories. UI language: English now, Bangla-ready (see 8.8).

This is a competition prototype that must be built so it can grow into a pilot. Correctness and honesty come before polish: never display a number the app cannot justify.

## 2. Architecture (decided)

```
Flutter app  ──HTTPS──▶  FastAPI backend (stateless)  ──▶ Gemini API
 │                         │                           ──▶ NASA POWER API
 └─ on-device SQLite       └─ calculations, PDF, config (emission factors, solar defaults)
    (all user data)
```

- **App:** Flutter (Dart). All user data (factory profile, bills, production, solar plans, cached results) is stored **on the device** in SQLite via `drift`.
- **Backend:** Python 3.11+, FastAPI. **Stateless**: it stores no user data, no images, and logs no request bodies. It exists to (a) keep the Gemini key off the phone, (b) run the Python calculations in one place, (c) generate PDFs.
- The app sends whatever data a calculation needs in each request (monthly history is small).
- Repository pattern in the app: UI talks to `BillRepository`, `ProductionRepository`, `SolarPlanRepository` interfaces; the local SQLite implementation is the only one now. Use UUID primary keys, `created_at`, `updated_at` and soft-delete flags so a remote/sync implementation can be added later without rewriting the UI.

## 3. Hard rules

- **No secrets in the app.** The Gemini key exists only on the backend (`GEMINI_API_KEY` env var). Provide `.env.example`; `.env` is gitignored.
- **Never invent constants.** Emission factors, tariffs, costs and similar values live in backend config files, each with `value`, `unit`, `source`, `year`, `status` (`verified` or `PLACEHOLDER`). Ship everything I haven't confirmed as `PLACEHOLDER`. API responses include the factor metadata, and the app shows an "unverified factor" badge wherever a placeholder is used.
- **Never guess on extraction.** Unclear fields come back `null`, and the user fills them in.
- **Human review is mandatory.** Extracted data is never used downstream until the user confirms it.
- **Privacy.** Bills contain names, addresses, consumer and meter numbers. The app must: show a notice before the first upload (data is sent to the backend and to Google's Gemini API); offer a crop step before upload so users can cut out personal details; never log or store consumer numbers/names; not keep uploaded images on the device by default (delete after extraction; optional setting to keep). The backend never writes images to disk or logs bodies.
- **Backend abuse controls.** Max upload size, image MIME validation, per-IP rate limiting, a configurable daily cap on Gemini calls, request timeouts, no stack traces in responses.
- Label all synthetic/demo data as synthetic in the UI.
- Type hints / strong typing everywhere, small modules, tests for all logic.

## 4. Repo layout (monorepo)

```
factory-carbon/
├── SPEC.md                    # this file
├── README.md
├── .github/workflows/ci.yml   # backend pytest + flutter test
├── backend/
│   ├── pyproject.toml / requirements.txt
│   ├── Dockerfile
│   ├── .env.example
│   ├── app/
│   │   ├── main.py            # FastAPI app, routers, middleware
│   │   ├── settings.py        # env + config loading
│   │   ├── security.py        # app token check, rate limit
│   │   ├── schemas.py         # pydantic request/response models
│   │   ├── extraction/        # gemini_client.py, prompts.py, validate.py
│   │   ├── carbon/            # factors.py, calculator.py
│   │   ├── waste/             # detector.py
│   │   ├── solar/             # geometry.py, nasa_power.py, model.py
│   │   └── report/            # charts.py, pdf.py
│   ├── config/
│   │   ├── emission_factors.yaml
│   │   └── solar_defaults.yaml
│   ├── data/
│   │   ├── sample_bills/      # redacted images only
│   │   └── ground_truth/      # expected JSON per sample bill
│   ├── scripts/
│   │   ├── eval_extraction.py
│   │   └── make_demo_data.py
│   └── tests/
└── app/                       # Flutter project
    ├── lib/
    │   ├── main.dart
    │   ├── core/              # api client, config, theme, l10n
    │   ├── data/              # drift database, DAOs, repositories
    │   ├── domain/            # models
    │   └── features/
    │       ├── onboarding/
    │       ├── home/
    │       ├── add_bill/      # capture, crop, upload, review
    │       ├── bills/
    │       ├── production/
    │       ├── import_history/
    │       ├── carbon/
    │       ├── waste/
    │       ├── solar/
    │       ├── export/
    │       └── settings/
    └── test/
```

## 5. Backend API (v1, all JSON except upload and PDF)

Every request carries header `X-App-Token` (value from a build-time define in the app, checked on the backend). This is a weak protection because the token can be extracted from the app; document that in the README, and rely on the rate limits and the daily Gemini cap. Auth is replaced by real user tokens in a later phase.

| Endpoint | Purpose |
|---|---|
| `GET /v1/health` | liveness, and the config/factor status summary |
| `POST /v1/extract-bill` | multipart image (png/jpg/pdf page) → `ExtractedBill` + validation warnings |
| `POST /v1/carbon/calculate` | confirmed bills + production → monthly emissions table, factor metadata, data-quality notes |
| `POST /v1/waste/analyze` | monthly kWh + production → expected value, band, flags, messages |
| `POST /v1/solar/estimate` | polygon coordinates + params + factory consumption history → energy, CO2, financials (if capex provided) |
| `POST /v1/report/pdf` | carbon (and optional solar) summary → PDF bytes |
| `GET /v1/templates/history.csv` | the bulk-import CSV template |

Expose OpenAPI at `/openapi.json`; treat it as the contract between app and backend. Version the API under `/v1`.

## 6. Backend feature specs

### 6.1 Bill extraction (Gemini)

Use the official Google Gen AI Python SDK. Send the image bytes with a prompt; request JSON constrained to a response schema (pydantic model). `temperature=0`. Retry 3 times with exponential backoff. The model ID comes from `GEMINI_MODEL`; check the Gemini docs for a current model that supports image input and structured output, and don't hardcode one you haven't confirmed.

`ExtractedBill` fields (all nullable except `bill_type`):
- `bill_type`: electricity | gas | diesel | unknown
- `utility_name`
- `billing_month` (`YYYY-MM`), `period_start`, `period_end` (ISO dates)
- `consumed_units`, `unit` (kWh | m3 | litre)
- `total_amount_bdt` (current-month payable)
- `tariff_code`, `sanctioned_load_kw`
- `field_confidence`: map of field → high | medium | low
- `notes`

Prompt rules (in `prompts.py`, version-controlled):
1. Read only the top (customer's copy) section. If lower copies disagree, ignore them and mention it in `notes`.
2. Use the printed "consumed units" value directly. Do NOT compute it from present minus previous meter readings; a multiplying factor may apply.
3. Convert Bangla digits to Western digits.
4. Dates are day/month/year; output ISO.
5. Unclear value → null. Never guess.
6. Do not output names, addresses, meter numbers or consumer numbers.

Server-side validation (`validate.py`, returns warnings, doesn't block): period end ≥ start; monthly period ~25–35 days; units > 0 and under a configured sanity ceiling; `billing_month` consistent with `period_end`; BDT-per-unit within a configured plausible band; low-confidence fields flagged.

Sample ground truth for the BPDB bill I will place in `data/sample_bills/` (file `bpdb_may24.json`): electricity, billing_month 2024-05, period 2024-05-01 to 2024-05-30, consumed_units 120 kWh (printed value; meter readings 4650→4750 differ by 100 because of a 1.2 multiplying factor, which is why the printed value must be used), tariff LT-B, sanctioned load 2.0 kW, total payable 684.00 (bill-month total printed as 683.74; accept either in tests and record which).

`scripts/eval_extraction.py`: run over every image in `data/sample_bills/`, compare with `data/ground_truth/*.json`, print per-field accuracy and mismatches. I will add more bills over time.

### 6.2 Carbon calculator

`config/emission_factors.yaml`, all `PLACEHOLDER` until I verify:

```yaml
grid_electricity: {value: null, unit: kg_CO2e_per_kWh, source: "", year: null, status: PLACEHOLDER}
diesel:           {value: null, unit: kg_CO2e_per_litre, source: "", year: null, status: PLACEHOLDER}
natural_gas:      {value: null, unit: kg_CO2e_per_m3, source: "", year: null, status: PLACEHOLDER}
```

You may pre-fill `diesel` and `natural_gas` with IPCC-based values only if you document the derivation and source in the yaml; keep them `PLACEHOLDER`. Leave `grid_electricity` null; Scope 2 requests return a clear "factor not set" error until it is configured.

Calculation: Scope 2 (location-based) = kWh × grid factor. Scope 1 = litres × diesel factor + m³ × gas factor. Response: per month, per source, total tCO2e; intensity per 1,000 units produced when production exists; months without data are `null`, never zero; factor metadata; data-quality notes (missing months, user-edited fields, placeholders in use).

### 6.3 Waste / anomaly detector

- 6+ months of electricity **and** production: OLS `kWh ~ production` (`statsmodels`), leave-one-out 95% prediction interval for each month; flag months above the upper bound.
- No production data: median/MAD fallback, labelled "lower confidence, no production data".
- Fewer than 6 months: return `insufficient_data` with the month count.
- Excess kWh = actual − expected for flagged months; cost estimate = excess × average BDT/kWh from the factory's bills.
- Return plain-language messages ("April used about 18% more electricity than expected for the units produced; about X kWh, about Tk Y. Check compressors, idle machines and generator changeover.").
- Do not build Isolation Forest unless I ask.
- Tests use `scripts/make_demo_data.py` (24 months synthetic, 2 injected anomalies): the detector must find the injected months and flag few normal ones.

### 6.4 Solar estimate

Input: polygon as lat/lon coordinates, parameter overrides, consumption history. Geometry: area in m² via `pyproj.Geod.geometry_area_perimeter`; reject invalid/self-intersecting/tiny polygons with a clear error; centroid for irradiance.

Irradiance: NASA POWER monthly climatology of all-sky surface shortwave downward irradiance (kWh/m²/day = peak sun hours) for the centroid. Check the current NASA POWER docs for endpoint, parameter and community values. Cache by rounded lat/lon (in-memory + optional disk cache); handle timeouts; allow the caller to supply a manual value.

`config/solar_defaults.yaml` (all overridable per request):
- `usable_roof_fraction` 0.6 (factory roofs have tanks, HVAC, skylights, shading; 0.7 is optimistic)
- `m2_per_kwp` 7
- `performance_ratio` 0.78
- `degradation_per_year` 0.005
- `capex_bdt_per_kwp`: null (PLACEHOLDER)
- `om_fraction_of_capex_per_year`: null (PLACEHOLDER)
- `electricity_price_bdt_per_kwh`: default to the average from supplied bills
- `net_metering`: false; if false, self-consumption is capped at actual consumption; if true, the export assumption is a PLACEHOLDER
- `analysis_years` 25

Outputs: usable area, kWp, monthly and annual kWh, share of consumption offset, CO2 avoided (same grid factor as 6.2), and, only if capex is provided, savings, simple payback and a 25-year cumulative cash-flow series. Always include the disclaimer: "Pre-feasibility estimate. Structural load, shading and electrical design need a professional assessment."

Test with this example: 1,000 m² roof, 70% usable, 7 m²/kWp → 100 kWp; 4.5 peak sun hours, PR 0.8 → 100 × 4.5 × 365 × 0.8 = 131,400 kWh/year.

### 6.5 Report PDF

reportlab + matplotlib. Sections: cover (factory name, period, generated date), summary table (Scope 1, Scope 2, total, intensity), monthly chart, methodology (formulas, factor table with source/year/status), data-quality notes, optional solar summary. If any factor is `PLACEHOLDER`, stamp every page "DRAFT: contains unverified emission factors". Also provide CSV generation in the app from local data.

## 7. Backend deployment

- Provide a `Dockerfile` and a README section for deploying to a container host (for example Google Cloud Run or Render; check current free-tier limits and cold-start behaviour yourself). Configuration only through env vars: `GEMINI_API_KEY`, `GEMINI_MODEL`, `APP_TOKEN`, `DAILY_GEMINI_CAP`, `MAX_UPLOAD_MB`.
- Include a local run mode (`uvicorn`) and instructions for testing from a phone on the same Wi-Fi.
- Stateless means it can run on a platform with no persistent disk.

## 8. App feature specs (Flutter)

Use null-safe Dart, a clear state-management choice (Riverpod preferred; state your choice), `dio` for HTTP, `drift` for SQLite, `camera`/`image_picker` and an image cropper, `file_picker` for CSV import, `share_plus` for exporting. Check current package docs and versions before use. The base URL and app token come from build-time `--dart-define`s.

### 8.1 Onboarding / factory profile
Factory name, location text, optional lat/lon, units label for production (for example "pieces"). Privacy notice with explicit acknowledgement.

### 8.2 Add bill
Flow: capture or pick image → crop screen with a reminder to hide personal details → resize client-side (long edge about 1600 px, JPEG) → upload to `/v1/extract-bill` with a progress state → **Review screen**: image on top (pinch-zoom), editable form below prefilled with extracted values, warnings inline next to the relevant fields, low-confidence fields highlighted. The user must tick "I have checked these values" before Save. Record which fields were user-edited. Manual entry without an image must also work (diesel receipts, unmetered gas). On network failure: clear message and retry; keep the cropped image in memory until the flow ends. Delete the image after extraction unless the "keep images" setting is on.

### 8.3 Bills list and production
List and edit confirmed bills (edits recorded). Production entry per month. Duplicate detection: warn if a bill for the same month and type already exists.

### 8.4 History import
Download the CSV template from the backend (or bundled copy), user fills 12–24 months (month, kWh, litres diesel, m³ gas, production), imports via file picker, preview and validation before saving. Imported rows are marked "imported (not from a bill image)" and show in the data-quality notes.

### 8.5 Carbon report
Calls `/v1/carbon/calculate` with local confirmed data; caches the result in the DB. Stacked monthly chart by source, totals, intensity if production exists, factor table with source/year/status badges, a data-quality panel. Works offline from the cached result with a "last updated" label.

### 8.6 Waste alerts
Calls `/v1/waste/analyze`. Chart of actual vs expected with the band, flagged months highlighted, plain-language messages, and a "how this works and its limits" sheet (small sample, no sub-metering, cannot identify the cause). Show the insufficient-data state with a prompt to import history.

### 8.7 Solar planner
Map screen with polygon drawing (use `flutter_map` or `google_maps_flutter`; check licensing and key requirements for satellite imagery, and keep the tile source configurable; do not use a tile source whose terms forbid this use). Parameter sheet (defaults from the backend config, editable), results screen with energy, offset share, CO2 avoided and, if capex is entered, savings, payback and a cash-flow chart. Persist plans locally. Show the pre-feasibility disclaimer.

### 8.8 Settings, export, localisation
Language switch (English complete; Bangla via ARB files with all keys present and translated where you can, marked for my review). PDF export through `/v1/report/pdf` and share sheet; CSV export from local data. "Delete all my data" (wipes the local DB). Data-handling page explaining what is stored on the phone, what is sent to the backend, and what is sent to Google.

### 8.9 Demo data
A Settings option "Load demo data (synthetic)" that fills 24 months of synthetic bills/production with injected anomalies, clearly labelled as synthetic everywhere, and a "Remove demo data" option.

## 9. Milestones (stop after each)

- **M0 Scaffold:** monorepo, backend skeleton with `/v1/health`, Flutter skeleton, CI running both test suites, READMEs, `.env.example`, `.gitignore`.
- **M1 Backend extraction:** 6.1, eval script, mocked-Gemini tests, `/v1/extract-bill`.
- **M2 App: add-bill flow:** onboarding, drift database and repositories, capture → crop → upload → review → save, bills list. Against the real backend or a mock server.
- **M3 Carbon:** 6.2, 6.5 PDF, `/v1/carbon/calculate` and `/v1/report/pdf`; app carbon report screen and export.
- **M4 History import and production entry:** 8.3, 8.4, template endpoint.
- **M5 Solar:** 6.4 and 8.7.
- **M6 Waste detector:** 6.3, demo data script, 8.6, 8.9.
- **M7 Polish and deploy:** error/empty states, Bangla scaffolding review, deployment docs, a 3-minute demo script, known-limitations screen/README.

If time is short, M0–M3 is a complete, demonstrable product.

## 10. Later phase (do NOT build now; keep the design compatible)

Real user accounts and per-factory data isolation, a hosted Postgres database with sync from the app, stored (encrypted) bill images with a retention policy, an offline upload queue, audit trail for edits, monitoring and alerts, paid Gemini tier with per-user limits, privacy policy and terms, methodology review by a sustainability professional. The UUID/timestamp/soft-delete choices in section 2 exist for this.

## 11. Known limitations to state in the README and the app

- Scope 1 and 2 from utility bills only; no Scope 3; no coal, biomass or captive-generator fuel unless entered manually.
- Extraction accuracy is measured only on the bills in `data/sample_bills/`.
- The waste detector flags statistical outliers against production and cannot identify causes.
- Solar results are pre-feasibility only.
- Emission factors marked PLACEHOLDER must be verified before any real submission.
- The app token is a weak protection, adequate for a demo only.
