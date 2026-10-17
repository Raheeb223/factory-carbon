import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/data/settings_store.dart';
import 'package:factory_carbon/domain/report_period.dart';
import 'package:factory_carbon/features/carbon/carbon_controller.dart';
import 'package:factory_carbon/features/carbon/carbon_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'domain_test.dart' show carbonJsonFixture;
import 'helpers.dart';

void main() {
  group('report period', () {
    test('calendar and fiscal year spans, keys round-trip', () {
      expect(const ReportPeriod.calendar(2025).fullSpan, (start: '2025-01', end: '2025-12'));
      expect(const ReportPeriod.fiscal(2025).fullSpan, (start: '2025-07', end: '2026-06'));
      expect(const ReportPeriod.all().fullSpan, isNull);
      for (final p in const [ReportPeriod.all(), ReportPeriod.calendar(2024), ReportPeriod.fiscal(2023)]) {
        expect(ReportPeriod.parse(p.key), p);
      }
      expect(ReportPeriod.parse('nonsense'), const ReportPeriod.all());
    });

    test('a year in progress stops at the last data month and compares with the same months a year earlier', () {
      const p = ReportPeriod.calendar(2026);
      expect(p.reportSpan('2026-08'), (start: '2026-01', end: '2026-08'));
      expect(p.isPartial('2026-08'), isTrue);
      expect(p.previousSpan('2026-08'), (start: '2025-01', end: '2025-08'));
      expect(p.isPartial('2027-02'), isFalse);
      expect(const ReportPeriod.fiscal(2025).previousSpan('2026-12'), (start: '2024-07', end: '2025-06'));
    });

    test('offers the years that have data, newest first', () {
      final keys = availablePeriods(['2024-11', '2025-03', '2025-08']).map((p) => p.key);
      expect(keys, ['all', 'cy:2025', 'cy:2024', 'fy:2025', 'fy:2024']);
      expect(availablePeriods(const []).map((p) => p.key), ['all']);
    });

    test('percent change', () {
      expect(percentChange(100, 90), closeTo(-10, 1e-9));
      expect(percentChange(null, 90), isNull);
      expect(percentChange(0, 90), isNull);
    });

    test('previous-year request only when there are bills then', () {
      final bills = [testBill(id: 'a', month: '2025-03'), testBill(id: 'b', month: '2026-03')];
      final withPrev = carbonRequests(bills: bills, production: const [], productionUnitLabel: null, period: const ReportPeriod.calendar(2026));
      expect(withPrev.current['period_start'], '2026-01');
      expect(withPrev.current['period_end'], '2026-03');
      expect(withPrev.previous?['period_start'], '2025-01');
      expect(withPrev.previous?['period_end'], '2025-03');
      final noPrev = carbonRequests(bills: bills, production: const [], productionUnitLabel: null, period: const ReportPeriod.calendar(2025));
      expect(noPrev.previous, isNull);
      final all = carbonRequests(bills: bills, production: const [], productionUnitLabel: null, period: const ReportPeriod.all());
      expect(all.current.containsKey('period_start'), isFalse);
    });
  });

  testWidgets('choosing a year recalculates for that year and compares with the year before', (tester) async {
    final db = memoryDb();
    final settings = MemorySettingsStore();
    await tester.runAsync(() async {
      await DriftFactoryRepository(db).save(testProfile());
      await DriftBillRepository(db).save(testBill(id: 'a', month: '2023-05'));
      await DriftBillRepository(db).save(testBill(id: 'b', month: '2024-05'));
    });
    final adapter = FakeAdapter((o) => o.path == '/v1/carbon/calculate' ? jsonBody(carbonJsonFixture()) : defaultHandler(o));
    await tester.pumpWidget(testApp(const Scaffold(body: CarbonView()), overrides: testOverrides(db: db, api: fakeApi(adapter), settings: settings)));
    await settle(tester);

    await tester.tap(find.byKey(const Key('carbon-period')));
    await settle(tester);
    await tester.tap(find.text('2024 (January–December)').last);
    await settle(tester);

    // First the automatic calculation on opening (all data), then the chosen year and the year before.
    final bodies = [for (final r in adapter.requests.where((r) => r.path == '/v1/carbon/calculate')) r.data as Map<String, dynamic>];
    expect(bodies.map((b) => b['period_start']), [null, '2024-01', '2023-01']);
    expect(bodies.map((b) => b['period_end']), [null, '2024-05', '2023-05']);
    expect(settings.reportPeriod, 'cy:2024');
    await tester.scrollUntilVisible(find.byKey(const Key('carbon-compare')), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Compared with a year earlier'), findsOneWidget);
    expect(find.byKey(const Key('carbon-stale')), findsNothing);
    await teardownDb(tester, db);
  });
}
