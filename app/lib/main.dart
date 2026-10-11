import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/database.dart';
import 'data/providers.dart';
import 'data/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await PrefsSettingsStore.open();
  final db = AppDatabase();
  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      settingsStoreProvider.overrideWithValue(settings),
    ],
    // Network calls are retried explicitly by the user ("Try again"), never silently.
    retry: (retryCount, error) => null,
    child: const FactoryCarbonApp(),
  ));
}
