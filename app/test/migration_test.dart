import 'dart:io';

import 'package:drift/native.dart';
import 'package:factory_carbon/data/database.dart';
import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Columns added in schema v3 (facility details and the reduction target).
const _v3Columns = [
  'facility_type',
  'district',
  'workers',
  'shifts_per_day',
  'energy_sources',
  'reporting_year',
  'target_metric',
  'target_pct',
  'target_baseline_year',
  'target_year',
];

void main() {
  test('a v2 database (as on phones before this update) upgrades without losing data', () async {
    final dir = await Directory.systemTemp.createTemp('fc_migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/app.sqlite');

    // Build a database, then turn it back into the v2 layout.
    final v2 = AppDatabase(NativeDatabase(file));
    await DriftFactoryRepository(v2).save(testProfile());
    await DriftBillRepository(v2).save(testBill(id: 'kept', month: '2024-05'));
    for (final c in _v3Columns) {
      await v2.customStatement('ALTER TABLE factory_profiles DROP COLUMN $c');
    }
    await v2.customStatement('PRAGMA user_version = 2');
    await v2.close();

    // Opening with the current app runs the v2 -> v3 migration.
    final db = AppDatabase(NativeDatabase(file));
    final profile = (await DriftFactoryRepository(db).get())!;
    expect(profile.name, 'Test Garments');
    expect(profile.energySources, isNull);
    expect(profile.target, isNull);
    expect((await DriftBillRepository(db).all()).single.id, 'kept');

    // The new columns work after the upgrade.
    await DriftFactoryRepository(db).save(profile.withTarget(const ReductionTarget(metric: 'total', pct: 25, baselineYear: 2024, year: 2030)));
    expect((await DriftFactoryRepository(db).get())!.target!.pct, 25);
    await db.close();
  });
}
