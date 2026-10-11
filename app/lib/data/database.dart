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

/// Last successful API results (carbon, waste) for offline viewing.
@DataClassName('CachedResultRow')
class CachedResults extends Table {
  TextColumn get key => text()();
  TextColumn get json => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [FactoryProfiles, Bills, ProductionEntries, SolarPlans, CachedResults])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'factory_carbon'));

  @override
  int get schemaVersion => 1;

  /// "Delete all my data": wipes every table.
  Future<void> wipeAll() => transaction(() async {
        for (final table in allTables) {
          await delete(table).go();
        }
      });
}
