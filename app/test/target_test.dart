import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/domain/api_models.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/domain/target.dart';
import 'package:factory_carbon/features/target/target_card.dart';
import 'package:factory_carbon/features/target/target_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'domain_test.dart' show carbonJsonFixture;
import 'helpers.dart';

CarbonResult _result({double? total, double? intensity, int months = 12}) {
  final j = carbonJsonFixture();
  j['totals'] = {
    ...(j['totals'] as Map<String, dynamic>),
    'total_t': total,
    'intensity_t_per_1000_units': intensity,
    'months_in_period': 12,
    'months_with_data': months,
  };
  return CarbonResult.fromJson(j);
}

const _target = ReductionTarget(metric: 'intensity', pct: 20, baselineYear: 2024, year: 2029);

void main() {
  test('on track when the reduction so far is at least the straight-line share', () {
    // End of 2026 is 2 of 5 years: 8% needed. 10% achieved.
    final p = targetProgress(_target, baseline: _result(intensity: 1.0), current: _result(intensity: 0.9), currentMonths: (start: '2026-01', end: '2026-12'));
    expect(p.status, TargetStatus.onTrack);
    expect(p.achievedPct, closeTo(10, 1e-9));
    expect(p.neededNowPct, closeTo(8, 1e-9));
    expect(p.incompleteData, isFalse);
  });

  test('behind, with incomplete data flagged; total metric uses total CO2', () {
    const t = ReductionTarget(metric: 'total', pct: 20, baselineYear: 2024, year: 2029);
    final p = targetProgress(t, baseline: _result(total: 100), current: _result(total: 97, months: 10), currentMonths: (start: '2026-01', end: '2026-12'));
    expect(p.status, TargetStatus.behind);
    expect(p.achievedPct, closeTo(3, 1e-9));
    expect(p.incompleteData, isTrue);
  });

  test('not enough data when values are missing or the latest 12 months are not after the baseline', () {
    expect(targetProgress(_target, baseline: _result(), current: _result(intensity: 1), currentMonths: (start: '2025-01', end: '2025-12')).status, TargetStatus.notEnoughData);
    expect(targetProgress(_target, baseline: _result(intensity: 1), current: _result(intensity: 1), currentMonths: (start: '2024-01', end: '2024-12')).status, TargetStatus.notEnoughData);
  });

  test('science-based pace and spans', () {
    expect(sbtiPct(2024, 2030), closeTo(25.2, 1e-9));
    expect(baselineSpan(_target), (start: '2024-01', end: '2024-12'));
    expect(currentSpan('2026-08'), (start: '2025-09', end: '2026-08'));
    expect(baselineYears(['2024-05', '2025-01', '2024-07']), [2025, 2024]);
  });

  test('requests cover the baseline year and the latest 12 months', () {
    final req = targetRequests(target: _target, bills: [testBill(month: '2026-08')], production: const [], productionUnitLabel: null)!;
    expect(req.baseline['period_start'], '2024-01');
    expect(req.baseline['period_end'], '2024-12');
    expect(req.current['period_start'], '2025-09');
    expect(req.current['period_end'], '2026-08');
    expect(targetRequests(target: null, bills: [testBill()], production: const [], productionUnitLabel: null), isNull);
  });

  testWidgets('set a target, then the card calculates progress by itself', (tester) async {
    final db = memoryDb();
    await tester.runAsync(() async {
      await DriftFactoryRepository(db).save(testProfile());
      await DriftBillRepository(db).save(testBill(id: 'a', month: '2024-05'));
      await DriftBillRepository(db).save(testBill(id: 'b', month: '2025-05'));
    });
    final adapter = FakeAdapter((o) => o.path == '/v1/carbon/calculate' ? jsonBody(carbonJsonFixture()) : defaultHandler(o));
    await tester.pumpWidget(testApp(const Scaffold(body: SingleChildScrollView(child: TargetCard())), overrides: testOverrides(db: db, api: fakeApi(adapter))));
    await settle(tester);
    expect(find.text('Set a CO₂ reduction target'), findsOneWidget);

    await tester.tap(find.byKey(const Key('target-set')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('target-pct-20')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('target-save')));
    await settle(tester);

    final saved = (await tester.runAsync(() => DriftFactoryRepository(db).get()))!.target!;
    expect(saved.pct, 20);
    expect(saved.baselineYear, 2024, reason: 'defaults to the year before the latest one');
    expect(saved.metric, 'total', reason: 'no production entered, so total CO2');
    await waitFor(tester, find.byKey(const Key('target-status')));
    final periods = [for (final r in adapter.requests.where((r) => r.path == '/v1/carbon/calculate')) (r.data as Map<String, dynamic>)['period_start']];
    expect(periods, ['2024-01', '2024-06']);
    expect(find.text('Not enough data yet'), findsOneWidget, reason: 'the fixture has no totals');
    await teardownDb(tester, db);
  });
}
