/// Repository interfaces. The UI depends only on these; the local SQLite (drift)
/// implementation is the only one today, a remote/sync one can be added later.
library;

import '../domain/models.dart';

abstract interface class FactoryRepository {
  Stream<FactoryProfile?> watch();
  Future<FactoryProfile?> get();
  Future<void> save(FactoryProfile profile);
}

abstract interface class BillRepository {
  Stream<List<Bill>> watchAll();
  Future<List<Bill>> all();
  Future<void> save(Bill bill);
  Future<void> insertAll(List<Bill> bills);
  Future<void> softDelete(String id);
  Future<void> deleteByOrigin(DataOrigin origin);
}

abstract interface class ProductionRepository {
  Stream<List<ProductionEntry>> watchAll();
  Future<List<ProductionEntry>> all();

  /// One active entry per month: replaces any existing entry for [month].
  Future<void> upsertMonth(String month, double unitsProduced, DataOrigin origin);
  Future<void> softDelete(String id);
  Future<void> deleteByOrigin(DataOrigin origin);
}

abstract interface class SolarPlanRepository {
  Stream<List<SolarPlan>> watchAll();
  Future<void> save(SolarPlan plan);
  Future<void> softDelete(String id);
}

class CachedResult {
  const CachedResult(this.json, this.updatedAt);
  final Map<String, dynamic> json;
  final DateTime updatedAt;
}

abstract interface class ResultCacheRepository {
  Stream<CachedResult?> watch(String key);
  Future<void> put(String key, Map<String, dynamic> json);
  Future<void> clear();
}
