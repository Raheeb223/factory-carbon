# 3-minute demo script

**Before you start:**
- Backend deployed or running locally.
- App installed and built with the right `API_BASE_URL` and `APP_TOKEN`.
- If the backend is on Render's free tier, open the app about a minute early to wake it.
- Have one **redacted** electricity bill photo ready on the phone.

| Time | Show | Say |
|---|---|---|
| 0:00 | Onboarding: enter factory name, tick the privacy notice | "Garment factories must report carbon to buyers but have no tools. Everything stays on this phone. Only the cropped bill goes to our stateless server and Gemini." |
| 0:20 | Settings → **Load demo data (synthetic)** | "24 months of synthetic data. Note the red SYNTHETIC banner: the app never hides that." |
| 0:35 | Home → **Add bill** → photo → crop | "The crop step reminds you to cut out names and meter numbers." |
| 0:50 | **Review screen**: pinch-zoom the image, point at the amber low-confidence field and an inline warning, tick "I have checked", Save | "Nothing is used until a person confirms it. We read the printed consumed units, never present minus previous, because a multiplying factor may apply." |
| 1:20 | Reports → **Carbon** → Update report | "Scope 1 and 2 by month. The grid factor is deliberately not set, so Scope 2 says 'not calculated' instead of guessing. Every factor shows its source and an 'Unverified' badge." |
| 1:45 | Export **PDF** → open it | "Ready to send. It is stamped DRAFT until the factors are verified." |
| 2:05 | Reports → **Electricity waste check** → Check now | "A regression of kWh against production flags October 2023 and August 2024, the two anomalies we injected, with kWh and Taka estimates. 'How this works' explains the limits." |
| 2:30 | Solar → New plan → tap 4 roof corners → Estimate (enter capex) | "NASA POWER sunlight for this location gives kWp, yearly kWh, the share of the factory's use it covers, and payback. Always labelled pre-feasibility." |
| 2:50 | Settings → Known limitations / Remove demo data | "Built to grow into a pilot: on-device data with sync-ready IDs, and an OpenAPI contract with tests on both sides." |
