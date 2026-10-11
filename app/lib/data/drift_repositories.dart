import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'database.dart';
import 'repositories.dart';

const _uuid = Uuid();
String newId() => _uuid.v4();

class DriftFactoryRepository implements FactoryRepository {
  DriftFactoryRepository(this._db);
  final AppDatabase _db;

  FactoryProfile _map(FactoryProfileRow r) => FactoryProfile(
        id: r.id,
        name: r.name,
        location: r.location,
        lat: r.lat,
        lon: r.lon,
        productionUnitLabel: r.productionUnitLabel,
        privacyAcknowledgedAt: r.privacyAcknowledgedAt,
      );

  SimpleSelectStatement<$FactoryProfilesTable, FactoryProfileRow> get _query =>
      (_db.select(_db.factoryProfiles)..where((t) => t.deleted.equals(false))..limit(1));

  @override
  Stream<FactoryProfile?> watch() => _query.watchSingleOrNull().map((r) => r == null ? null : _map(r));

  @override
  Future<FactoryProfile?> get() async {
    final r = await _query.getSingleOrNull();
    return r == null ? null : _map(r);
  }

  @override
  Future<void> save(FactoryProfile p) async {
    final now = DateTime.now();
    final existing = await (_db.select(_db.factoryProfiles)..where((t) => t.id.equals(p.id))).getSingleOrNull();
    await _db.into(_db.factoryProfiles).insertOnConflictUpdate(FactoryProfilesCompanion.insert(
          id: p.id,
          name: p.name,
          location: Value(p.location),
          lat: Value(p.lat),
          lon: Value(p.lon),
          productionUnitLabel: Value(p.productionUnitLabel),
          privacyAcknowledgedAt: p.privacyAcknowledgedAt,
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        ));
  }
}

class DriftBillRepository implements BillRepository {
  DriftBillRepository(this._db);
  final AppDatabase _db;

  static Bill fromRow(BillRow r) => Bill(
        id: r.id,
        billType: BillType.parse(r.billType),
        billingMonth: r.billingMonth,
        consumedUnits: r.consumedUnits,
        unit: EnergyUnit.parse(r.unit) ?? EnergyUnit.kWh,
        origin: DataOrigin.parse(r.origin),
        confirmedAt: r.confirmedAt,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        utilityName: r.utilityName,
        periodStart: r.periodStart,
        periodEnd: r.periodEnd,
        totalAmountBdt: r.totalAmountBdt,
        tariffCode: r.tariffCode,
        sanctionedLoadKw: r.sanctionedLoadKw,
        userEditedFields: (jsonDecode(r.userEditedFields) as List<dynamic>).cast<String>(),
        fieldConfidence: (jsonDecode(r.fieldConfidence) as Map<String, dynamic>).cast<String, String>(),
        extractionNotes: r.extractionNotes,
        extractionModel: r.extractionModel,
        imagePath: r.imagePath,
      );

  static BillsCompanion toCompanion(Bill b) => BillsCompanion.insert(
        id: b.id,
        createdAt: b.createdAt,
        updatedAt: b.updatedAt,
        billType: b.billType.name,
        billingMonth: b.billingMonth,
        consumedUnits: b.consumedUnits,
        unit: b.unit.wire,
        origin: b.origin.wire,
        confirmedAt: b.confirmedAt,
        utilityName: Value(b.utilityName),
        periodStart: Value(b.periodStart),
        periodEnd: Value(b.periodEnd),
        totalAmountBdt: Value(b.totalAmountBdt),
        tariffCode: Value(b.tariffCode),
        sanctionedLoadKw: Value(b.sanctionedLoadKw),
        userEditedFields: Value(jsonEncode(b.userEditedFields)),
        fieldConfidence: Value(jsonEncode(b.fieldConfidence)),
        extractionNotes: Value(b.extractionNotes),
        extractionModel: Value(b.extractionModel),
        imagePath: Value(b.imagePath),
      );

  SimpleSelectStatement<$BillsTable, BillRow> get _active => _db.select(_db.bills)
    ..where((t) => t.deleted.equals(false))
    ..orderBy([(t) => OrderingTerm.desc(t.billingMonth), (t) => OrderingTerm.asc(t.billType)]);

  @override
  Stream<List<Bill>> watchAll() => _active.watch().map((rows) => rows.map(fromRow).toList());

  @override
  Future<List<Bill>> all() async => (await _active.get()).map(fromRow).toList();

  @override
  Future<void> save(Bill bill) => _db.into(_db.bills).insertOnConflictUpdate(toCompanion(bill));

  @override
  Future<void> insertAll(List<Bill> bills) => _db.batch((b) => b.insertAllOnConflictUpdate(_db.bills, bills.map(toCompanion).toList()));

  @override
  Future<void> softDelete(String id) =>
      (_db.update(_db.bills)..where((t) => t.id.equals(id))).write(BillsCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())));

  @override
  Future<void> deleteByOrigin(DataOrigin origin) => (_db.delete(_db.bills)..where((t) => t.origin.equals(origin.wire))).go();
}

class DriftProductionRepository implements ProductionRepository {
  DriftProductionRepository(this._db);
  final AppDatabase _db;

  ProductionEntry _map(ProductionRow r) =>
      ProductionEntry(id: r.id, month: r.month, unitsProduced: r.unitsProduced, origin: DataOrigin.parse(r.origin), updatedAt: r.updatedAt);

  SimpleSelectStatement<$ProductionEntriesTable, ProductionRow> get _active =>
      _db.select(_db.productionEntries)..where((t) => t.deleted.equals(false))..orderBy([(t) => OrderingTerm.desc(t.month)]);

  @override
  Stream<List<ProductionEntry>> watchAll() => _active.watch().map((rows) => rows.map(_map).toList());

  @override
  Future<List<ProductionEntry>> all() async => (await _active.get()).map(_map).toList();

  @override
  Future<void> upsertMonth(String month, double unitsProduced, DataOrigin origin) => _db.transaction(() async {
        final now = DateTime.now();
        final existing = await (_db.select(_db.productionEntries)..where((t) => t.month.equals(month) & t.deleted.equals(false))).get();
        if (existing.isNotEmpty) {
          final first = existing.first;
          await (_db.update(_db.productionEntries)..where((t) => t.id.equals(first.id))).write(ProductionEntriesCompanion(
            unitsProduced: Value(unitsProduced),
            origin: Value(origin.wire),
            updatedAt: Value(now),
          ));
          for (final extra in existing.skip(1)) {
            await softDelete(extra.id);
          }
        } else {
          await _db.into(_db.productionEntries).insert(ProductionEntriesCompanion.insert(
                id: newId(),
                createdAt: now,
                updatedAt: now,
                month: month,
                unitsProduced: unitsProduced,
                origin: origin.wire,
              ));
        }
      });

  @override
  Future<void> softDelete(String id) => (_db.update(_db.productionEntries)..where((t) => t.id.equals(id)))
      .write(ProductionEntriesCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())));

  @override
  Future<void> deleteByOrigin(DataOrigin origin) => (_db.delete(_db.productionEntries)..where((t) => t.origin.equals(origin.wire))).go();
}

class DriftActionRepository implements ActionRepository {
  DriftActionRepository(this._db);
  final AppDatabase _db;

  EnergyAction _map(EnergyActionRow r) => EnergyAction(
        id: r.id,
        code: r.code,
        title: r.title,
        doneMonth: r.doneMonth,
        costBdt: r.costBdt,
        note: r.note,
        origin: DataOrigin.parse(r.origin),
        updatedAt: r.updatedAt,
      );

  SimpleSelectStatement<$EnergyActionsTable, EnergyActionRow> get _active =>
      _db.select(_db.energyActions)..where((t) => t.deleted.equals(false))..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);

  @override
  Stream<List<EnergyAction>> watchAll() => _active.watch().map((rows) => rows.map(_map).toList());

  @override
  Future<List<EnergyAction>> all() async => (await _active.get()).map(_map).toList();

  @override
  Future<void> save(EnergyAction a) async {
    final now = DateTime.now();
    final existing = await (_db.select(_db.energyActions)..where((t) => t.id.equals(a.id))).getSingleOrNull();
    await _db.into(_db.energyActions).insertOnConflictUpdate(EnergyActionsCompanion.insert(
          id: a.id,
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
          code: a.code,
          title: Value(a.title),
          doneMonth: Value(a.doneMonth),
          costBdt: Value(a.costBdt),
          note: Value(a.note),
          origin: a.origin.wire,
        ));
  }

  @override
  Future<void> softDelete(String id) => (_db.update(_db.energyActions)..where((t) => t.id.equals(id)))
      .write(EnergyActionsCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())));

  @override
  Future<void> deleteByOrigin(DataOrigin origin) => (_db.delete(_db.energyActions)..where((t) => t.origin.equals(origin.wire))).go();
}

class DriftSolarPlanRepository implements SolarPlanRepository {
  DriftSolarPlanRepository(this._db);
  final AppDatabase _db;

  SolarPlan _map(SolarPlanRow r) => SolarPlan(
        id: r.id,
        name: r.name,
        polygon: (jsonDecode(r.polygonJson) as List<dynamic>).map((e) => LatLon.fromJson(e as Map<String, dynamic>)).toList(),
        params: jsonDecode(r.paramsJson) as Map<String, dynamic>,
        resultJson: r.resultJson == null ? null : jsonDecode(r.resultJson!) as Map<String, dynamic>,
        updatedAt: r.updatedAt,
      );

  @override
  Stream<List<SolarPlan>> watchAll() => (_db.select(_db.solarPlans)
        ..where((t) => t.deleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
      .watch()
      .map((rows) => rows.map(_map).toList());

  @override
  Future<void> save(SolarPlan plan) async {
    final now = DateTime.now();
    final existing = await (_db.select(_db.solarPlans)..where((t) => t.id.equals(plan.id))).getSingleOrNull();
    await _db.into(_db.solarPlans).insertOnConflictUpdate(SolarPlansCompanion.insert(
          id: plan.id,
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
          name: plan.name,
          polygonJson: jsonEncode(plan.polygon.map((p) => p.toJson()).toList()),
          paramsJson: jsonEncode(plan.params),
          resultJson: Value(plan.resultJson == null ? null : jsonEncode(plan.resultJson)),
        ));
  }

  @override
  Future<void> softDelete(String id) =>
      (_db.update(_db.solarPlans)..where((t) => t.id.equals(id))).write(SolarPlansCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())));
}

class DriftResultCacheRepository implements ResultCacheRepository {
  DriftResultCacheRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<CachedResult?> watch(String key) => (_db.select(_db.cachedResults)..where((t) => t.key.equals(key)))
      .watchSingleOrNull()
      .map((r) => r == null ? null : CachedResult(jsonDecode(r.json) as Map<String, dynamic>, r.updatedAt));

  @override
  Future<void> put(String key, Map<String, dynamic> json) => _db
      .into(_db.cachedResults)
      .insertOnConflictUpdate(CachedResultsCompanion.insert(key: key, json: jsonEncode(json), updatedAt: DateTime.now()));

  @override
  Future<void> clear() => _db.delete(_db.cachedResults).go();
}
