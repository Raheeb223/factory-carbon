# Factory Energy & Carbon: Flutter app

See the [root README](../README.md) for setup, configuration (`--dart-define`), privacy and architecture.

```bash
flutter pub get
flutter analyze
flutter test                       # unit + widget tests (contract tests skip without BACKEND_URL)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000 --dart-define=APP_TOKEN=dev
```

- Generated code is committed: `lib/data/database.g.dart` (drift) and `lib/core/l10n/gen/` (localizations). Regenerate with `dart run build_runner build --delete-conflicting-outputs` and `flutter gen-l10n`.
- Strings live in `lib/core/l10n/app_en.arb` (template) and `app_bn.arb`. The Bangla file is an AI draft awaiting native-speaker review.
- The demo data asset comes from `backend/scripts/make_demo_data.py --out ../app/assets/demo/demo_data.json`.
