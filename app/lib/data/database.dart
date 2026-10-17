import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Common columns: UUID text PK, timestamps and soft delete, so a sync layer can be
/// added later without changing the UI (spec section 2).
mixin SyncColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
}

@DataClassName('FactoryProfileRow')
class FactoryProfiles extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get location => text().withDefault(const Constant(''))();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  TextColumn get productionUnitLabel => text().withDefault(const Constant('pieces'))();
  DateTimeColumn get privacyAcknowledgedAt => dateTime()();

  // v3: facility details. Nullable, so older rows and backups stay valid.
  TextColumn get facilityType => text().nullable()();
  TextColumn get district => text().nullable()();
  IntColumn get workers => integer().nullable()();
  IntColumn get shiftsPerDay => integer().nullable()();

  /// JSON list of energy sources used; null = not answered.
  TextColumn get energySources => text().nullable()();
  TextColumn get reportingYear => text().nullable()();

  /// Reduction target: 'intensity' (per 1,000 units) or 'total', percent, years.
  TextColumn get targetMetric => text().nullable()();
  RealColumn get targetPct => real().nullable()();
  IntColumn get targetBaselineYear => integer().nullable()();
  IntColumn get targetYear => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BillRow')
class Bills extends Table with SyncColumns {
  TextColumn get billType => text()();
  TextColumn get billingMonth => text()();
  RealColumn get consumedUnits => real()();
  TextColumn get unit => text()();
  TextColumn get origin => text()();
  DateTimeColumn get confirmedAt => dateTime()();
  TextColumn get utilityName => text().nullable()();
  DateTimeColumn get periodStart => dateTime().nullable()();
  DateTimeColumn get periodEnd => dateTime().nullable()();
  RealColumn get totalAmountBdt => real().nullable()();
  TextColumn get tariffCode => text().nullable()();
  RealColumn get sanctionedLoadKw => real().nullable()();

  /// JSON list of field names the user changed (vs. extracted or vs. previous save).
  TextColumn get userEditedFields => text().withDefault(const Constant('[]'))();

  /// JSON map field -> high|medium|low from extraction.
  TextColumn get fieldConfidence => text().withDefault(const Constant('{}'))();
  TextColumn get extractionNotes => text().nullable()();
  TextColumn get extractionModel => text().nullable()();

  /// Local path to the kept bill image; null unless the "keep images" setting is on.
  TextColumn get imagePath => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProductionRow')
class ProductionEntries extends Table with SyncColumns {
  TextColumn get month => text()();
  RealColumn get unitsProduced => real()();
  TextColumn get origin => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SolarPlanRow')
class SolarPlans extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get polygonJson => text()();
  TextColumn get paramsJson => text()();
  TextColumn get resultJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Action plan entries (planned or done energy-saving actions).
@DataClassName('EnergyActionRow')
class EnergyActions extends Table with SyncColumns {
  TextColumn get code => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get doneMonth => text().nullable()();
  RealColumn get costBdt => real().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get origin => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Last successful API results (carbon, waste) for offline viewing.
@DataClassName('CachedResultRow')
class CachedResults extends Table {
  TextColumn get key => text()();
  TextColumn get json => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [FactoryProfiles, Bills, ProductionEntries, SolarPlans, CachedResults, EnergyActions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'factory_carbon'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(energyActions); // v2: action plan
          if (from < 3) {
            // v3: facility details on the factory profile
            for (final c in [
              factoryProfiles.facilityType,
              factoryProfiles.district,
              factoryProfiles.workers,
              factoryProfiles.shiftsPerDay,
              factoryProfiles.energySources,
              factoryProfiles.reportingYear,
              factoryProfiles.targetMetric,
              factoryProfiles.targetPct,
              factoryProfiles.targetBaselineYear,
              factoryProfiles.targetYear,
            ]) {
              await m.addColumn(factoryProfiles, c);
            }
          }
        },
      );

  /// "Delete all my data": wipes every table.
  Future<void> wipeAll() => transaction(() async {
        for (final table in allTables) {
          await delete(table).go();
        }
      });
}
