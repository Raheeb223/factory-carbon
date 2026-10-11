import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/drift_repositories.dart';
import '../../data/providers.dart';
import '../../domain/demo_data.dart';
import '../../domain/models.dart';
import '../add_bill/image_service.dart';

enum DemoLoadResult { loaded, notEmpty }

/// Demo data and "delete all my data" operations (spec 8.8, 8.9).
class DataAdmin {
  DataAdmin(this._ref);
  final Ref _ref;

  /// Demo data only goes into an app without real data, so it can never be mixed
  /// into (or later wipe) a real factory's records.
  Future<DemoLoadResult> loadDemo({String? jsonText}) async {
    final bills = await _ref.read(billRepositoryProvider).all();
    final production = await _ref.read(productionRepositoryProvider).all();
    if (bills.any((b) => !b.isSynthetic) || production.any((p) => !p.isSynthetic)) return DemoLoadResult.notEmpty;
    await removeDemo();
    final text = jsonText ?? await rootBundle.loadString('assets/demo/demo_data.json');
    final demo = parseDemoData(text, newId: newId);
    await _ref.read(billRepositoryProvider).insertAll(demo.bills);
    final prodRepo = _ref.read(productionRepositoryProvider);
    for (final (month, units) in demo.production) {
      await prodRepo.upsertMonth(month, units, DataOrigin.demo);
    }
    await _ref.read(resultCacheRepositoryProvider).clear();
    return DemoLoadResult.loaded;
  }

  Future<void> removeDemo() async {
    await _ref.read(billRepositoryProvider).deleteByOrigin(DataOrigin.demo);
    await _ref.read(productionRepositoryProvider).deleteByOrigin(DataOrigin.demo);
    await _ref.read(resultCacheRepositoryProvider).clear();
  }

  /// Wipes the local database, kept images and preferences.
  Future<void> deleteAll() async {
    await _ref.read(databaseProvider).wipeAll();
    try {
      await _ref.read(imageServiceProvider).deleteAllKept();
    } catch (_) {
      // No kept images directory: nothing to delete.
    }
    await _ref.read(settingsStoreProvider).clear();
    _ref.invalidate(localeProvider);
    _ref.invalidate(keepImagesProvider);
  }
}

final dataAdminProvider = Provider<DataAdmin>(DataAdmin.new);
