import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/config.dart';
import '../domain/api_models.dart';
import '../domain/models.dart';
import 'database.dart';
import 'drift_repositories.dart';
import 'repositories.dart';
import 'settings_store.dart';

/// Overridden in main() / tests.
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('databaseProvider must be overridden'));
final settingsStoreProvider = Provider<SettingsStore>((ref) => throw UnimplementedError('settingsStoreProvider must be overridden'));

/// Build-time configuration (--dart-define).
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

/// Server address/token: the Settings override if set, else the build-time default.
class ServerConfigNotifier extends Notifier<AppConfig> {
  @override
  AppConfig build() {
    final base = ref.watch(appConfigProvider);
    final s = ref.watch(settingsStoreProvider);
    return base.withServer(apiBaseUrl: s.serverUrl, appToken: s.serverToken);
  }

  Future<void> save(String? url, String? token) async {
    await ref.read(settingsStoreProvider).setServer(url, token);
    ref.invalidateSelf();
  }
}

final serverConfigProvider = NotifierProvider<ServerConfigNotifier, AppConfig>(ServerConfigNotifier.new);
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(serverConfigProvider)));

final factoryRepositoryProvider = Provider<FactoryRepository>((ref) => DriftFactoryRepository(ref.watch(databaseProvider)));
final billRepositoryProvider = Provider<BillRepository>((ref) => DriftBillRepository(ref.watch(databaseProvider)));
final productionRepositoryProvider = Provider<ProductionRepository>((ref) => DriftProductionRepository(ref.watch(databaseProvider)));
final solarPlanRepositoryProvider = Provider<SolarPlanRepository>((ref) => DriftSolarPlanRepository(ref.watch(databaseProvider)));
final actionRepositoryProvider = Provider<ActionRepository>((ref) => DriftActionRepository(ref.watch(databaseProvider)));
final resultCacheRepositoryProvider = Provider<ResultCacheRepository>((ref) => DriftResultCacheRepository(ref.watch(databaseProvider)));

final factoryProvider = StreamProvider<FactoryProfile?>((ref) => ref.watch(factoryRepositoryProvider).watch());
final billsProvider = StreamProvider<List<Bill>>((ref) => ref.watch(billRepositoryProvider).watchAll());
final productionProvider = StreamProvider<List<ProductionEntry>>((ref) => ref.watch(productionRepositoryProvider).watchAll());
final actionsProvider = StreamProvider<List<EnergyAction>>((ref) => ref.watch(actionRepositoryProvider).watchAll());
final solarPlansProvider = StreamProvider<List<SolarPlan>>((ref) => ref.watch(solarPlanRepositoryProvider).watchAll());

const carbonCacheKey = 'carbon';
const wasteCacheKey = 'waste';

final carbonCacheProvider = StreamProvider<CachedResult?>((ref) => ref.watch(resultCacheRepositoryProvider).watch(carbonCacheKey));
final wasteCacheProvider = StreamProvider<CachedResult?>((ref) => ref.watch(resultCacheRepositoryProvider).watch(wasteCacheKey));

/// True when any synthetic (demo) record exists: drives the "synthetic" banner everywhere.
final containsSyntheticProvider = Provider<bool>((ref) {
  final bills = ref.watch(billsProvider).value ?? const [];
  final production = ref.watch(productionProvider).value ?? const [];
  final actions = ref.watch(actionsProvider).value ?? const [];
  return bills.any((b) => b.isSynthetic) || production.any((p) => p.isSynthetic) || actions.any((a) => a.isSynthetic);
});

/// Keeps retrying while the free server wakes up (up to ~90 s); other errors show at once.
final healthProvider = FutureProvider<HealthInfo>((ref) async {
  final api = ref.watch(apiClientProvider);
  final deadline = DateTime.now().add(const Duration(seconds: 90));
  for (var attempt = 0;; attempt++) {
    try {
      return await api.health();
    } on ApiException catch (e) {
      final waking = e.kind == ApiErrorKind.timeout ||
          e.kind == ApiErrorKind.network ||
          e.kind == ApiErrorKind.unavailable ||
          e.statusCode == 502 ||
          e.statusCode == 504;
      if (!waking || DateTime.now().isAfter(deadline)) rethrow;
      await Future<void>.delayed(Duration(seconds: attempt < 3 ? 2 : 4));
    }
  }
});

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.watch(settingsStoreProvider).localeCode;
    return code == null ? null : Locale(code);
  }

  Future<void> set(String? code) async {
    await ref.read(settingsStoreProvider).setLocaleCode(code);
    state = code == null ? null : Locale(code);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

class KeepImagesNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsStoreProvider).keepImages;

  Future<void> set(bool v) async {
    await ref.read(settingsStoreProvider).setKeepImages(v);
    state = v;
  }
}

final keepImagesProvider = NotifierProvider<KeepImagesNotifier, bool>(KeepImagesNotifier.new);
