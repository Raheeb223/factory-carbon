import 'dart:math' as math;

import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/domain/api_models.dart';
import 'package:factory_carbon/domain/geo.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/domain/panel_layout.dart';
import 'package:factory_carbon/domain/solar_scenario.dart';
import 'package:factory_carbon/features/solar/solar_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';
import 'loan_test.dart' show loanFinancialsFixture;
import 'ux_test.dart' show solarResultFixture;

const _k = 6371008.8 * math.pi / 180;

/// A w x h metre rectangle near Gazipur, turned by [deg] degrees.
List<LatLon> _roof(double w, double h, {double deg = 0}) {
  const lat0 = 24.0, lon0 = 90.33;
  final a = deg * math.pi / 180;
  final kx = _k * math.cos(lat0 * math.pi / 180);
  return [
    for (final (x, y) in [(0.0, 0.0), (w, 0.0), (w, h), (0.0, h)])
      LatLon(lat0 + (x * math.sin(a) + y * math.cos(a)) / _k, lon0 + (x * math.cos(a) - y * math.sin(a)) / kx),
  ];
}

Bill _elec(String month, double kwh, double cost) => testBill(id: month, month: month, units: kwh, amount: cost);

void main() {
  setUpAll(mockTileCache);

  group('panel layout', () {
    test('fills a plain roof in rows, inside the edge clearance', () {
      final roof = _roof(40, 20);
      final panels = panelLayout(roof, maxPanels: 10000);
      // 38 m usable width / 1.16 m per column = 32; 18 m usable depth / 2.78 m per row = 6
      expect(panels.length, 32 * 6);
      for (final p in panels) {
        expect(p, hasLength(4));
        for (final c in p) {
          expect(containsPoint(roof, c), isTrue);
        }
        expect(polygonAreaM2(p), closeTo(panelWidthM * panelLengthM, 0.05));
      }
    });

    test('keeps the panel count of the estimate and works on a turned roof', () {
      expect(panelLayout(_roof(40, 20), maxPanels: 50), hasLength(50));
      // the test's projection differs slightly from the layout's, which can cost the edge column
      expect(panelLayout(_roof(40, 20, deg: 33), maxPanels: 10000).length, inInclusiveRange(31 * 6, 32 * 6));
      expect(panelLayout(_roof(1.5, 1.5), maxPanels: 10), isEmpty);
      expect(panelLayout(const [], maxPanels: 10), isEmpty);
    });
  });

  group('scenario', () {
    final r = SolarResult.fromJson({...solarResultFixture(), 'financials': loanFinancialsFixture()});

    test('splits each month into solar and grid and prices the saving', () {
      // 14 months of bills: only the latest 12 are compared
      final bills = [for (var i = 0; i < 14; i++) _elec('${2023 + (i + 10) ~/ 12}-${((i + 10) % 12 + 1).toString().padLeft(2, '0')}', 100000, 1000000)];
      final s = SolarScenario.of(r, bills)!;
      expect(s.months, hasLength(12));
      expect(s.months.first.month, '2024-01');
      final jan = s.months.first;
      expect(jan.solarKwh, closeTo(r.monthlyGenerationKwh[0], 1e-6));
      expect(jan.gridAfterKwh, closeTo(100000 - r.monthlyGenerationKwh[0], 1e-6));
      expect(jan.costAfterBdt, closeTo(1000000 - jan.solarKwh * 10, 1e-6));
      expect(s.solarShare, closeTo(s.solarKwh / 1200000, 1e-9));
      expect(s.co2BeforeT! - s.co2AfterT!, closeTo(s.solarKwh * 0.62 / 1000, 1e-6));
    });

    test('solar never counts more than the month used, and no bills means no scenario', () {
      final s = SolarScenario.of(r, [_elec('2024-04', 1000, 9000)])!;
      expect(s.months.single.solarKwh, 1000);
      expect(s.months.single.gridAfterKwh, 0);
      expect(s.months.single.costAfterBdt, 0);
      expect(SolarScenario.of(r, const []), isNull);
    });
  });

  testWidgets('preview toggles the panels and compares before and after', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final db = memoryDb();
    await tester.runAsync(() async {
      for (var m = 1; m <= 12; m++) {
        await DriftBillRepository(db).save(_elec('2024-${m.toString().padLeft(2, '0')}', 300000, 3000000));
      }
    });
    final r = SolarResult.fromJson({...solarResultFixture(), 'financials': loanFinancialsFixture()});
    await tester.pumpWidget(testApp(
      SolarPreviewScreen(result: r, polygon: _roof(60, 60), panelWatt: 550),
      overrides: testOverrides(db: db, api: fakeApi(FakeAdapter(defaultHandler))),
    ));
    await settle(tester);
    expect(find.textContaining('of your electricity would come from your own roof'), findsOneWidget);
    await tester.tap(find.text('Today'));
    await tester.pump();
    await tester.tap(find.text('With solar').first);
    await tester.pump();
    await tester.scrollUntilVisible(find.byKey(const Key('preview-chart')), 200, scrollable: find.byType(Scrollable).last);
    expect(find.text('Electricity bought from the grid'), findsOneWidget);
    expect(find.text('Electricity bill'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await teardownDb(tester, db);
  });
}
