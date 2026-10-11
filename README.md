# BillToGreen

From utility bills to a greener factory (formerly "Factory Energy & Carbon").

A mobile app for Bangladeshi garment factories. Photograph utility bills and get:

1. **Structured bill data** read by Gemini, with a **mandatory human review** before anything is used. Printed names and addresses are found on the phone (ML Kit, offline) and covered with black boxes before the photo is sent.
2. A **traceable draft emissions report** (Scope 1 direct + Scope 2 purchased electricity, location-based): reporting period, sources included, factors with source, year and gases covered, and an audit trail of every bill and how it was entered. PDF or CSV.
3. **Unusual electricity use (anomalies)**: months that used more electricity than expected *for the units produced*, with kWh per unit, an estimated extra cost and an ordered inspection checklist. An anomaly is not called waste until normal causes are ruled out.
4. A **rooftop solar estimate**. Find the factory by place search, pasted coordinates or GPS, then tap the roof: the building outline comes from OpenStreetMap, or the user taps the corners. The calculation then accounts for shading, roof strength, installation cost, tariff and self-consumption, and the output is labelled an estimate.
5. **Actions and measured savings**: an action plan, and savings measured afterwards from the factory's own bills (production-adjusted), in Tk, kWh and CO2, with payback and the benefit to the wider community.

For people who find reading hard: a picture tutorial with a **Listen** button (Bangla/English text-to-speech), one-tap choices instead of typing, and the CO2 figure explained in plain words (kg, trees, what Scope 1 and 2 mean).

The app is fully bilingual: **English and বাংলা**. Switch at any time from the first screen, the Home app bar, Settings, or Android 13+ "App languages".

**Run it on your phone:** follow [docs/ANDROID_SETUP.md](docs/ANDROID_SETUP.md) (English + বাংলা). In short: run `start_backend.ps1`, open `app/` in Android Studio, run **Factory Carbon (dev)**, then enter the printed address and token in *Settings → Server connection*.

It is a competition prototype built to grow into a pilot. The rule throughout: **never show a number the app cannot justify**. Missing data is shown as empty, never as zero. Every emission factor carries its source and status. Unverified factors are badged in the app and stamp the PDF "DRAFT".

```
Flutter app  ──HTTPS──▶  FastAPI backend (stateless)  ──▶ Gemini API (bill reading)
 │                         │                           ──▶ NASA POWER (solar irradiance)
 └─ on-device SQLite       └─ calculations, PDF, config (emission factors, solar defaults)
    (all user data)
```

- **App** (`app/`): Flutter, Riverpod 3 for state, drift (SQLite) for all user data on the phone, dio for HTTP. The UI talks only to repository interfaces (`lib/data/repositories.dart`). Records use UUIDs, `created_at`/`updated_at` and soft-delete flags, so a sync backend can be added later.
- **Backend** (`backend/`): Python 3.11 and FastAPI. It is **stateless**: no database, no images written to disk, no request bodies logged. The API contract is [`docs/openapi.json`](docs/openapi.json), also served at `/openapi.json`. CI fails if the two drift apart.

## Repository layout

```
factory-carbon/
├── SPEC.md                     project specification
├── docs/openapi.json           API contract (generated: python -m scripts.export_openapi)
├── docs/DEMO_SCRIPT.md         3-minute demo
├── .github/workflows/ci.yml    backend pytest, flutter analyze/test, app<->backend contract test
├── backend/
│   ├── app/                    main.py, api.py, settings.py, security.py, schemas.py
│   │   ├── extraction/         gemini_client.py, prompts.py, validate.py, upload.py, ground_truth.py
│   │   ├── carbon/             factors.py, calculator.py
│   │   ├── waste/              detector.py
│   │   ├── solar/              geometry.py, nasa_power.py, model.py
│   │   └── report/             charts.py, pdf.py
│   ├── config/                 emission_factors.yaml, solar_defaults.yaml, validation_rules.yaml, history_template.csv
│   ├── data/sample_bills/      redacted bill images (add yours)   data/ground_truth/  expected JSON per bill
│   ├── scripts/                eval_extraction.py, make_demo_data.py, export_openapi.py
│   └── tests/                  74 tests
├── start_backend.ps1           one-click backend for phone testing (prints address + token)
└── app/
    ├── env/dev.json            local --dart-define values (gitignored; see dev.json.example)
    ├── .run/                   Android Studio run configuration "Factory Carbon (dev)"
    ├── lib/core/               api client, config (--dart-define), theme, formatting, l10n (ARB en + bn)
    ├── lib/data/               drift database, repositories, providers, settings
    ├── lib/domain/             models, API DTOs, request builders, CSV import/export, demo data, image prep
    ├── lib/features/           onboarding, home, add_bill, bills, production, import_history, carbon,
    │                           waste, solar, export, settings
    └── test/                   54 unit/widget tests (incl. every main screen in en + bn on a small phone)
                                + 7 contract tests against a live backend
```

## Quick start (local)

### Backend

```bash
cd backend
python -m venv .venv
.venv/Scripts/activate            # Windows (Git Bash: source .venv/Scripts/activate); macOS/Linux: source .venv/bin/activate
pip install -r requirements-dev.txt
cp .env.example .env              # then set GEMINI_API_KEY, GEMINI_MODEL, APP_TOKEN
python -m pytest                  # 74 tests
uvicorn --factory app.main:create_default_app --reload --port 8000
```

Open http://localhost:8000/docs. Every `/v1` call needs the header `X-App-Token: <APP_TOKEN>`. Without `GEMINI_API_KEY`, everything works except `/v1/extract-bill`, which returns `503 extraction_unavailable`. The app then suggests manual entry.

### App

You need the Flutter SDK, stable channel (developed with 3.47.7 / Dart 3.13). A device build also needs the Android SDK or Xcode.

```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift code (already committed)
flutter gen-l10n                                            # localizations (already committed)
flutter analyze && flutter test                             # 54 tests
flutter run --dart-define-from-file=env/dev.json           # or the Android Studio run config
```

`10.0.2.2` is the Android emulator's address for your computer.

### Testing from a phone on the same Wi-Fi

1. Run `.\start_backend.ps1`. It listens on all interfaces and prints your LAN address and the app token.
2. Allow Python through the Windows firewall (Private networks) when asked.
3. In the app: **Settings → Server connection** → enter the address and token → **Test connection** → **Save**. No rebuild is needed; the setting is stored on the phone.

Debug builds allow plain HTTP for this (`android/app/src/debug/AndroidManifest.xml`). Release builds require HTTPS.

### Contract tests (app ↔ live backend)

```bash
# terminal 1
cd backend && APP_TOKEN=dev uvicorn --factory app.main:create_default_app --port 8765
# terminal 2
cd app && BACKEND_URL=http://127.0.0.1:8765 APP_TOKEN=dev flutter test test/contract
```

### Build-time app configuration (`--dart-define`)

| Define | Default | Purpose |
|---|---|---|
| `API_BASE_URL` | `http://10.0.2.2:8000` | Default backend URL (can be changed in Settings → Server connection) |
| `APP_TOKEN` | empty | Default shared token sent as `X-App-Token` (also editable in Settings) |
| `MAP_TILE_URL` | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` | Street map tiles |
| `MAP_TILE_ATTRIBUTION` | `© OpenStreetMap contributors` | Shown on the map |
| `SATELLITE_TILE_URL` | empty (off) | Optional satellite layer |
| `SATELLITE_TILE_ATTRIBUTION` | empty | Required if satellite is set |

**Map tiles.** The default is OpenStreetMap's standard tiles. Their [tile usage policy](https://operations.osmfoundation.org/policies/tiles/) allows light use with an identifying User-Agent (set) and visible attribution (shown). It forbids bulk or offline downloading (not done) and gives no service guarantee. Building outlines are visible at high zoom, which is enough to trace a roof.

**Place search and roof outlines.** Search uses OpenStreetMap's [Nominatim](https://operations.osmfoundation.org/policies/nominatim/): limited to Bangladesh, one request per press of the search button (no search-as-you-type, as the policy requires), with an identifying User-Agent. Typed or pasted coordinates (including a Google Maps link) skip the search. Tapping the roof asks the [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API) for building footprints within 150 m and uses the smallest one containing the tap. When no building is mapped there, or the service is down, the user taps the corners. The GPS button asks for location permission only when it is pressed. Like the tiles, these are free community services with no guarantee; a pilot should use a paid or self-hosted geocoder. A **satellite layer is off by default**: I could not confirm a free satellite source whose terms allow this use. Enable it only with a provider whose terms you have accepted, typically with an API key in the URL. Before a pilot, switch to a commercial or self-hosted tile provider.

## Configuration (backend, env vars only)

| Variable | Default | Notes |
|---|---|---|
| `GEMINI_API_KEY` | – | Only on the backend, never in the app |
| `GEMINI_MODEL` | – | Required for extraction. Checked 2026-10-10: `gemini-3.8-flash` and `gemini-3.5-flash-lite` are stable and support image/PDF input and structured output |
| `APP_TOKEN` | – | Required; requests are refused without it |
| `DAILY_GEMINI_CAP` | 200 | Gemini calls per UTC day, **each retry counts**, per instance |
| `MAX_UPLOAD_MB` | 8 | Upload limit |
| `RATE_LIMIT_PER_MINUTE` / `EXTRACT_RATE_LIMIT_PER_MINUTE` | 60 / 10 | Per client IP |
| `REQUEST_TIMEOUT_S` / `EXTRACT_TIMEOUT_S` / `GEMINI_CALL_TIMEOUT_S` | 30 / 120 / 45 | |
| `TRUST_PROXY_HEADERS` | false | Set true behind Cloud Run / Render so rate limits use the real client IP |
| `NASA_CACHE_DIR` | unset | Optional disk cache for NASA POWER climatology (not user data) |

Domain constants live in `backend/config/*.yaml`. Each has a `value`, `unit`, `source`, `year` and `status` (`verified` or `PLACEHOLDER`).

## Security and privacy

- **App token is weak.** It can be extracted from the APK, so it is **adequate for a demo only**. Abuse is limited by per-IP rate limits, a daily Gemini cap, upload size and MIME (magic bytes) checks, request timeouts, body-size limits, and generic error messages with no stack traces. Real per-user auth comes in a later phase.
- **Rate limits and the daily cap are in memory, per instance.** Deploy with a single instance (Cloud Run `--max-instances=1`, Render free is single-instance) for the cap to hold.
- **No stored user data on the server.** Images are read into memory, sent to Gemini and dropped. Request bodies are never logged; access logs contain method, path and status only. Validation errors never echo submitted values.
- **On the phone:** bill images are deleted after reading unless the user enables "Keep bill images". Images are re-encoded before upload, which strips EXIF metadata including GPS. `android:allowBackup="false"` keeps the local DB out of cloud backups. "Delete all my data" wipes the DB, kept images and preferences.
- **Gemini data terms matter.** Under Google's [Gemini API terms](https://ai.google.dev/gemini-api/terms), on the **free (unpaid) tier** Google may use submitted content to improve its products, and human reviewers may read it. The terms say not to submit personal information to unpaid services, and apps serving users in the EEA, Switzerland or UK must use paid services. **Use a billing-enabled (paid) Gemini project for real bills.** Use the free tier only for demos with redacted or synthetic bills. The in-app privacy notices say this.
- The prompt forbids returning names, addresses and meter or consumer numbers. The response schema has no such fields. The backend also redacts long digit runs from free-text fields.

## Deployment (container host)

The backend needs no persistent disk. Build and run:

```bash
cd backend
docker build -t factory-carbon-api .
docker run -p 8080:8080 -e APP_TOKEN=... -e GEMINI_API_KEY=... -e GEMINI_MODEL=gemini-3.8-flash factory-carbon-api
```

**Google Cloud Run**

```bash
gcloud run deploy factory-carbon-api --source backend --region asia-south1 \
  --allow-unauthenticated --max-instances 1 --memory 1Gi --timeout 150 \
  --set-env-vars GEMINI_MODEL=gemini-3.8-flash,DAILY_GEMINI_CAP=200,TRUST_PROXY_HEADERS=true \
  --set-secrets GEMINI_API_KEY=gemini-key:latest,APP_TOKEN=app-token:latest
```

- Free tier for request-based billing, per third-party summaries of Google's pricing page: 2 million requests, 180,000 vCPU-seconds and 360,000 GiB-seconds per month. Free-tier allowances vary by region group; check [cloud.google.com/run/pricing](https://cloud.google.com/run/pricing) for your region.
- Instances scale to zero, so the first request after idle has a **cold start of a few seconds**. Importing matplotlib, statsmodels and pyproj is the slow part. `--min-instances 1` removes it but is billed.

**Render** (free web service, recommended for the demo)

1. Push this repository to GitHub (private is fine).
2. In the Render dashboard: **New → Blueprint** → choose the repository. Render reads [`render.yaml`](render.yaml), which defines a Docker web service in the Singapore region.
3. Paste your Gemini key when asked. `APP_TOKEN` is generated automatically; copy it from the service's **Environment** tab.
4. In the app: **Settings → Server connection** → `https://<your-service>.onrender.com` plus the token → **Test connection** → **Save**.
- Per [Render's docs](https://render.com/docs/free): free services **spin down after 15 minutes without traffic** and take **about a minute** to wake. There are 750 free instance hours per workspace per month, a single instance and no persistent disk. Fine for a demo; open the app a minute before presenting.

After deploying, build the app with `--dart-define=API_BASE_URL=https://<your-host>`.

## How each part works

- **Extraction (spec 6.1).** The Google Gen AI SDK (`google-genai`) calls `generate_content` with the image and a version-controlled prompt (`prompts.py`). Settings: `temperature=0`, JSON output constrained by a flat JSON Schema (only keywords the Gemini docs list as supported). Up to 3 retries with exponential backoff, no retry on 4xx. Anything unparseable becomes `null`. Server-side checks return warnings and never block. Run `python -m scripts.eval_extraction` for per-field accuracy against `data/ground_truth/*.json`.
- **Carbon (6.2).** Scope 2 = kWh × grid factor; Scope 1 = litres × diesel factor + m³ × gas factor. Months without data are `null`. A source whose factor is not set returns an explicit `factor_not_set` error and `null` values; the other sources are still calculated.
- **Unusual use / anomalies (6.3).** A transparent baseline, not a black-box model: monthly data is too sparse for ML.
  - With 6+ months of electricity and production: OLS of `kWh ~ production` (statsmodels), i.e. expected kWh = a + b × units produced, with a leave-one-out 95% prediction interval. A factory making 20% more garments is expected to use more electricity and is not flagged for it (tested).
  - Each month also reports kWh per unit and the expected kWh per unit; flagged months get an estimated extra cost (excess kWh × average price) and an ordered checklist: rule out production, hours and weather first, then compressed air, idle machines, boiler/steam, generator.
  - To stop one anomaly hiding another (masking), up to 3 passes refit without months already flagged.
  - Without production data: a leave-one-out median/MAD fallback (robust z > 3), labelled lower confidence.
  - On 200 synthetic datasets it found both injected anomalies every time, with about 0.3 false flags per 24 months.
- **Solar (6.4).**
  - Geodesic area via `pyproj.Geod`; shapely rejects self-intersecting and tiny polygons.
  - Irradiance: NASA POWER `ALLSKY_SFC_SW_DWN` monthly climatology (community `RE`). Cached by location rounded to 0.01°, with an optional disk cache. A manual value can override it.
  - Without net metering, self-consumption is capped at each month's consumption. Financials appear only when capex is given.
  - The spec example (1,000 m², 70%, 7 m²/kWp, 4.5 PSH, PR 0.8) gives exactly 131,400 kWh/year, and 81.5 t CO2/year avoided at 0.62 kg/kWh when all of it displaces grid electricity (both tested).
  - Shading loss and an engineer's roof-strength check are inputs; without them the result carries a warning. When the price comes from the bills' average (which includes demand charge and VAT), a warning says real savings may be lower.
- **Measured savings (Feature 4, on the phone).** Baseline = kWh per unit over up to 12 months before the first completed action; each later month saves baseline × units − actual kWh (the action month is left out). Results under 3 months are labelled early. Tk uses the average bill price; CO2 uses the grid factor from the carbon report. This is a whole-factory comparison (similar to IPMVP Option C), so other changes can also contribute; the app says so.
- **PDF (6.5).** reportlab + matplotlib: titled "Draft Greenhouse Gas Emissions Report" with a note that method and format still need validating against the buyer's requirements. Cover, summary (period, sources included, Scope 1 direct vs Scope 2 purchased electricity), monthly chart and table, methodology (including how AI-read values are confirmed), factor table with source/year/status/gases (grid factor is CO2 only; fuels are CO2e), data-quality notes, an audit trail of every bill (how it was entered and when it was confirmed), and an optional solar page. Every page is stamped "DRAFT: contains unverified emission factors" while any factor is `PLACEHOLDER`, and "SYNTHETIC DEMO DATA" when demo data is included.

## Emission factors (verified against primary sources, 2026-10-11)

`backend/config/emission_factors.yaml`:

| Factor | Value | Source |
|---|---|---|
| `grid_electricity` | 0.62 kg CO2/kWh | Department of Environment, Govt. of Bangladesh (Article 6 DNA), letter Ref. 22.02.0000.063.61.009.23-37, 23 Jan 2025: 0.62 tCO2/MWh for FY 2020-21 and 2021-22 |
| `diesel` | 2.66155 kg CO2e/L | UK DESNZ GHG Conversion Factors 2025, "Diesel (100% mineral diesel)" (Bangladesh diesel has no biofuel blend) |
| `natural_gas` | 2.06672 kg CO2e/m³ | UK DESNZ GHG Conversion Factors 2025, "Natural gas" |

Each value was checked against the original document or spreadsheet; the YAML `notes` give the exact reference and cross-checks.
- The grid factor is CO2-only and is the national factor published for carbon-market use.
- The gas factor reflects UK gas composition. An IPCC-default derivation for Bangladesh gas is 5–8% lower.
- Replace these when newer editions are published, or if a buyer prescribes a different dataset.

The solar rules of thumb (usable fraction 0.6, 7 m²/kWp, PR 0.78, degradation 0.5%/yr) are the values set in `SPEC.md` 6.4. Capex and O&M have no default and must come from a supplier quote.

## What we claim, and what we do not

| Instead of | We say |
|---|---|
| "The factory produced 95 t of CO2." | "Draft: 95 tCO2e for Jan 2023 to Dec 2024, from grid electricity (Scope 2, purchased) and diesel and gas (Scope 1, direct), using the factors, sources and years listed." |
| "Usage rose 20%, so Tk 1.5 lakh was wasted." | "An anomaly: about X kWh more than expected for the units produced, estimated extra cost Tk Y. Check production, working hours and other causes first." |
| "AI learns normal usage from monthly bills." | "A transparent, production-adjusted baseline (kWh = a + b × units). AI is used only to read bills, and a person confirms every value." |
| "The solar calculator gives your savings." | "An estimate that accounts for usable roof, shading, roof strength, installation cost, tariff and how much solar power the factory can use." |
| "A buyer-ready compliance report." | "A draft emissions report, until its method and format are validated against the buyer's requirements." |
| "This action will save 10%." | "Since the action, electricity per unit fell X%, measured from your own bills: Tk Y, Z kWh, W kg CO2." |

## Known limitations

- Scope 1 and 2 from utility bills only. No Scope 3; no coal, biomass or captive-generator fuel unless entered manually.
- Extraction accuracy is measured only on the bills in `backend/data/sample_bills/`. The BPDB sample image is not in the repo yet, so the eval script has not been run against Gemini.
- The anomaly detector flags statistical outliers against production and cannot identify causes.
- Measured savings compare the whole factory before and after; weather, product mix or other changes can also contribute.
- Automatic name hiding reads printed Latin text only; handwritten or Bangla-script names must be covered by hand (the screen asks the user to check).
- Solar results are pre-feasibility only.
- Emission factors are published government values (see above). Re-check them each year and against the buyer's reporting rules.
- The app token is weak protection, adequate for a demo only.
- Rate limits and the daily Gemini cap are per instance and in memory.
- Bangla strings are AI-drafted and marked for native-speaker review (`app/lib/core/l10n/app_bn.arb`, key `@@x-review-status`). Server messages are localized by error/warning code. The PDF report stays in English (it is meant for buyers, and reportlab cannot shape Bengali script correctly).
- OSM tiles are best-effort with no SLA; there is no satellite imagery by default.

The same list appears in the app (Settings → Known limitations).

## Decisions and assumptions

- **State management:** Riverpod 3 with hand-written providers (no code generation). Automatic provider retry is off; the user retries explicitly.
- **`factor_not_set`:** returned as a structured error inside a 200 response, so Scope 1 still works while the grid factor is missing.
- **Partial months:** totals add what can be computed, and every month carries `is_complete` and `missing`. The app and PDF mark partial months.
- **Extra endpoints:** `GET /v1/solar/defaults` (the app's parameter sheet needs the configured defaults) and an unauthenticated `GET /livez` liveness probe that reveals nothing.
- **History CSV:** has an optional `electricity_cost_bdt` column so the waste check can estimate cost from imported history.
- **Demo data:** only loads into an app with no real records, so it can never mix with or later delete real data.
- **Staleness:** the cached carbon report stores a hash of its inputs, so the app notices both edits and deletions.

See `SPEC.md` for the full specification and the later-phase roadmap (accounts, sync, audit trail).
