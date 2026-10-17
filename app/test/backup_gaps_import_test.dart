import 'package:factory_carbon/data/backup.dart';
import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/domain/data_gaps.dart';
import 'package:factory_carbon/domain/history_csv.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/features/import_history/import_screen.dart';
import 'package:factory_carbon/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

ProductionEntry _prod(String month, double units, {DataOrigin origin = DataOrigin.manual}) =>
    ProductionEntry(id: 'p-$month', month: month, unitsProduced: units, origin: origin, updatedAt: DateTime(2026));

void main() {
  group('import plan', () {
    final rows = parseHistoryCsv('month,electricity_kwh,diesel_litres,gas_m3,production_units\n'
            '2024-05,1000,50,,2000\n'
            '2024-06,1100,,,2100\n')
        .rows;
    var n = 0;
    String id() => 'new-${n++}';

    test('keeps bills from photos or typed in and skips the file value', () {
      final plan = planImport(rows, existingBills: [testBill(id: 'real', month: '2024-05')], existingProduction: [_prod('2024-06', 9)], newId: id);
      expect(plan.skipped, containsAll([(month: '2024-05', kind: 'electricity'), (month: '2024-06', kind: 'production')]));
      expect(plan.bills.where((b) => b.billType == BillType.electricity).map((b) => b.billingMonth), ['2024-06']);
      expect(plan.bills.where((b) => b.billType == BillType.diesel), hasLength(1));
      expect(plan.production.map((p) => p.$1), ['2024-05']);
      expect(plan.replaceBillIds, isEmpty);
    });

    test('importing the same file twice replaces instead of doubling', () {
      final first = planImport(rows, existingBills: const [], existingProduction: const [], newId: id);
      final second = planImport(
        rows,
        existingBills: first.bills,
        existingProduction: [for (final (m, u) in first.production) _prod(m, u, origin: DataOrigin.imported)],
        newId: id,
      );
      expect(second.skipped, isEmpty);
      expect(second.replaceBillIds.toSet(), first.bills.map((b) => b.id).toSet());
      expect(second.bills, hasLength(first.bills.length));
    });
  });

  group('missing months', () {
    final now = DateTime(2024, 9, 15);

    test('lists months without electricity or production since data started, up to last month', () {
      final gaps = findGaps(
        [testBill(id: 'a', month: '2024-05'), testBill(id: 'b', month: '2024-07'), testBill(id: 'c', month: '2024-09')],
        [_prod('2024-06', 10)],
        now: now,
      );
      expect(gaps.electricity, ['2024-06', '2024-08']);
      expect(gaps.production, ['2024-07', '2024-08']);
    });

    test('only checks the last 12 months and ignores demo data and other bill types', () {
      final gaps = findGaps(
        [
          testBill(id: 'old', month: '2020-01'),
          for (var m = 1; m <= 8; m++) testBill(id: 'd$m', month: '2024-0$m', origin: DataOrigin.demo),
          testBill(id: 'gas', type: BillType.gas, month: '2024-08'),
        ],
        const [],
        now: now,
      );
      expect(gaps.electricity, hasLength(gapWindowMonths));
      expect(gaps.electricity.first, '2023-09');
      expect(gaps.production, isEmpty);
    });

    test('nothing to report without data', () => expect(findGaps(const [], const [], now: now).isEmpty, isTrue));

    test('new production entries start on the latest month with a bill but no production', () {
      final bills = [testBill(id: 'a', month: '2024-05'), testBill(id: 'b', month: '2024-06'), testBill(id: 'c', month: '2024-07')];
      expect(suggestedProductionMonth(bills, [_prod('2024-07', 1)], now: now), '2024-06');
      expect(suggestedProductionMonth(bills, [for (final m in ['2024-05', '2024-06', '2024-07']) _prod(m, 1)], now: now), '2024-08', reason: 'all done: last month');
      expect(suggestedProductionMonth(const [], const [], now: now), '2024-08');
    });
  });

  group('backup', () {
    test('round trip restores every record and drops photos and deleted rows', () async {
      final src = memoryDb();
      await DriftFactoryRepository(src).save(testProfile());
      final bills = DriftBillRepository(src);
      await bills.save(testBill(id: 'b1', month: '2024-05', edited: const ['consumed_units']));
      await bills.save(testBill(id: 'b2', month: '2024-06').copyWith(imagePath: '/data/kept/b2.jpg'));
      await bills.save(testBill(id: 'gone', month: '2024-07'));
      await bills.softDelete('gone');
      await DriftProductionRepository(src).upsertMonth('2024-05', 2000, DataOrigin.manual);
      await DriftActionRepository(src).save(
        EnergyAction(id: 'a1', code: 'fix_air_leaks', doneMonth: '2024-06', costBdt: 5000, origin: DataOrigin.manual, updatedAt: DateTime(2026)),
      );
      final json = await buildBackup(src);
      await src.close();

      final parsed = parseBackup(json);
      expect(parsed.factoryName, 'Test Garments');
      expect(parsed.bills, hasLength(2));
      expect(parsed.billMonths, 2);

      final dst = memoryDb();
      await DriftBillRepository(dst).save(testBill(id: 'other', month: '2023-01'));
      await restoreBackup(dst, parsed);
      final restored = await DriftBillRepository(dst).all();
      expect(restored.map((b) => b.id).toSet(), {'b1', 'b2'});
      expect(restored.every((b) => b.imagePath == null), isTrue);
      expect(restored.firstWhere((b) => b.id == 'b1').userEditedFields, ['consumed_units']);
      expect((await DriftProductionRepository(dst).all()).single.unitsProduced, 2000);
      expect((await DriftActionRepository(dst).all()).single.costBdt, 5000);
      expect((await DriftFactoryRepository(dst).get())?.name, 'Test Garments');
      await dst.close();
    });

    test('rejects other files, newer versions and damaged backups', () {
      Matcher fails(BackupError e) => throwsA(isA<BackupException>().having((x) => x.error, 'error', e));
      expect(() => parseBackup('month,kwh\n2024-05,1'), fails(BackupError.notABackup));
      expect(() => parseBackup('{"format":"other"}'), fails(BackupError.notABackup));
      expect(() => parseBackup('{"format":"$backupFormat","version":${backupVersion + 1}}'), fails(BackupError.newerVersion));
      expect(() => parseBackup('{"format":"$backupFormat","version":1,"created_at":"x","bills":[{"id":1}]}'), fails(BackupError.damaged));
    });
  });

  testWidgets('import screen warns about months already on the phone', (tester) async {
    final db = memoryDb();
    await tester.runAsync(() => DriftBillRepository(db).save(testBill(id: 'real', month: '2024-05')));
    final key = GlobalKey();
    await tester.pumpWidget(testApp(ImportScreen(key: key), overrides: testOverrides(db: db)));
    await settle(tester);
    (key.currentState! as dynamic).previewText('month,electricity_kwh,diesel_litres,gas_m3,production_units\n2024-05,1000,,,\n');
    await settle(tester);
    expect(find.byKey(const Key('import-skipped')), findsOneWidget);
    expect(find.byKey(const Key('import-nothing-new')), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('import-confirm'))).onPressed, isNull);
    await teardownDb(tester, db);
  });

  testWidgets('restore asks first, then replaces the data', (tester) async {
    final src = memoryDb();
    final json = await tester.runAsync(() async {
      await DriftBillRepository(src).save(testBill(id: 'from-backup', month: '2024-03'));
      final j = await buildBackup(src);
      await src.close();
      return j;
    });
    final db = memoryDb();
    await tester.runAsync(() => DriftBillRepository(db).save(testBill(id: 'current', month: '2024-05')));
    await tester.pumpWidget(testApp(
      Scaffold(
        body: Consumer(
          builder: (context, ref, _) => TextButton(onPressed: () => restoreFromFile(context, ref, readFile: () async => json), child: const Text('go')),
        ),
      ),
      overrides: testOverrides(db: db),
    ));
    await tester.tap(find.text('go'));
    await settle(tester);
    expect(find.text('Replace all data on this phone?'), findsOneWidget);
    await tester.tap(find.text('Restore from backup'));
    await settle(tester);
    expect((await tester.runAsync(() => DriftBillRepository(db).all()))!.map((b) => b.id), ['from-backup']);
    expect(find.text('Backup restored.'), findsOneWidget);
    await teardownDb(tester, db);
  });
}
