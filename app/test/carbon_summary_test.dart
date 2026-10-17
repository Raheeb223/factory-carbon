import 'package:factory_carbon/core/format.dart';
import 'package:factory_carbon/core/l10n/gen/app_localizations.dart';
import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/data/settings_store.dart';
import 'package:factory_carbon/domain/api_models.dart';
import 'package:factory_carbon/domain/carbon_summary.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/features/carbon/carbon_screen.dart';
import 'package:factory_carbon/features/carbon/reports_screen.dart';
import 'package:factory_carbon/features/impact/impact_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Two complete months: electricity 40,000 + 50,000 kWh, diesel 300 + 500 litres.
Map<String, dynamic> carbonFixture() {
  Map<String, dynamic> month(String m, double kwh, double litres, double units) {
    final e = kwh * 0.62 / 1000, d = litres * 2.66155 / 1000;
    return {
      'month': m, 'electricity_kwh': kwh, 'diesel_litres': litres, 'gas_m3': null, 'scope2_electricity_t': e,
      'scope1_diesel_t': d, 'scope1_gas_t': null, 'scope1_t': d, 'scope2_t': e, 'total_t': e + d,
      'is_complete': true, 'missing': <String>[], 'production_units': units, 'intensity_t_per_1000_units': (e + d) / units * 1000,
    };
  }

  final months = [month('2025-01', 40000, 300, 100000), month('2025-02', 50000, 500, 120000)];
  double sum(String k) => months.fold(0.0, (a, m) => a + (m[k] as double));
  return {
    'period_start': '2025-01',
    'period_end': '2025-02',
    'months': months,
    'totals': {
      'scope1_t': sum('scope1_t'), 'scope2_t': sum('scope2_t'), 'total_t': sum('total_t'), 'production_units': 220000.0,
      'intensity_t_per_1000_units': sum('total_t') / 220, 'months_in_period': 2, 'months_with_data': 2, 'complete_months': 2,
    },
    'factors': {
      'grid_electricity': {'name': 'grid_electricity', 'value': 0.62, 'unit': 'kg_CO2_per_kWh', 'source': 'DoE', 'year': 2023, 'status': 'verified'},
      'diesel': {'name': 'diesel', 'value': 2.66155, 'unit': 'kg_CO2e_per_litre', 'source': 'DESNZ', 'year': 2024, 'status': 'verified'},
    },
    'placeholders_in_use': <String>[],
    'errors': <dynamic>[],
    'data_quality_notes': <dynamic>[],
    'production_unit_label': 'pieces',
    'methodology': ['x'],
    'energy': {
      'by_source': [
        {'source': 'electricity', 'quantity': 90000.0, 'unit': 'kWh', 'kwh': 90000.0, 'gj': 324.0, 'share': 0.9189},
        {'source': 'diesel', 'quantity': 800.0, 'unit': 'litre', 'kwh': 7943.2, 'gj': 28.596, 'share': 0.0811},
      ],
      'total_kwh': 97943.2,
      'total_gj': 352.596,
      'energy_content': <String, dynamic>{},
      'complete': true,
    },
  };
}

void main() {
  setUpAll(() => initializeDateFormatting());
  final r = CarbonResult.fromJson(carbonFixture());

  test('energy summary is read from the result', () {
    final e = r.energy!;
    expect(e.complete, isTrue);
    expect(e.totalKwh, closeTo(97943.2, 1e-6));
    expect(e.lines.map((x) => x.source), [BillType.electricity, BillType.diesel]);
  });

  test('each source line is units × factor and the lines add up to the total', () {
    final s = CarbonSummary(r);
    expect(s.lines.map((l) => l.source), [CarbonSource.electricity, CarbonSource.diesel]);
    final e = s.lines.first, d = s.lines.last;
    expect(e.amount, 90000);
    expect(e.tonnes, closeTo(90000 * 0.62 / 1000, 1e-9));
    expect(d.amount, 800);
    expect(d.tonnes, closeTo(800 * 2.66155 / 1000, 1e-9));
    expect(s.totalT, closeTo(r.totals.totalT!, 1e-9));
    expect(s.biggest!.source, CarbonSource.electricity);
    expect(s.share(e), closeTo(55.8 / (55.8 + 2.12924), 1e-6));
    expect(s.perMonth, closeTo(r.totals.totalT! / 2, 1e-9));
    expect(s.peakMonth!.month, '2025-02');
    final cut = s.tenPercentLessElectricity()!;
    expect(cut.kwh, closeTo(45000 * 12 * 0.1, 1e-6));
    expect(cut.tonnes, closeTo(54000 * 0.62 / 1000, 1e-9));
  });

  test('a report with no calculated months has no lines', () {
    final empty = CarbonSummary(CarbonResult.fromJson({...carbonFixture(), 'months': <dynamic>[]}));
    expect(empty.lines, isEmpty);
    expect(empty.biggest, isNull);
    expect(empty.tenPercentLessElectricity(), isNull);
  });

  test('suggestions put the biggest source first, cheaper actions first', () {
    final codes = ['rooftop_solar', 'steam_leaks', 'generator_hours', 'led_lighting', 'switch_off_idle', 'fix_air_leaks'];
    expect(rankActions(codes, CarbonSummary(r)), ['switch_off_idle', 'fix_air_leaks', 'led_lighting', 'rooftop_solar', 'generator_hours', 'steam_leaks']);
    // without a report: cheapest first, catalog order within a cost level
    expect(rankActions(codes, null), ['generator_hours', 'switch_off_idle', 'steam_leaks', 'fix_air_leaks', 'led_lighting', 'rooftop_solar']);
  });

  test('plain words name the period, the biggest source and the peak month', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final fmt = Fmt('en');
    final s = CarbonSummary(r);
    final words = carbonPlainWords(en, fmt, s, 'pieces');
    expect(words, hasLength(4));
    expect(words[0], en.carbonSay1('Jan 2025', 'Feb 2025', fmt.tonnes(r.totals.totalT), fmt.tonnes(s.perMonth)));
    expect(words[1], en.carbonSay2('Electricity', '96'));
    expect(words[3], contains('February 2025'));
  });

  for (final locale in const [Locale('en'), Locale('bn')]) {
    testWidgets('carbon and savings tabs with a full report render in ${locale.languageCode} on a small phone', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final db = memoryDb();
      await tester.runAsync(() async {
        await DriftFactoryRepository(db).save(testProfile());
        await DriftBillRepository(db).save(testBill(origin: DataOrigin.demo));
        await DriftResultCacheRepository(db).put('carbon', {'input_hash': 'x', 'response': carbonFixture()});
      });
      final settings = MemorySettingsStore()..localeCode = locale.languageCode;
      await tester.pumpWidget(testApp(const ReportsScreen(), locale: locale, overrides: testOverrides(db: db, settings: settings, api: fakeApi(FakeAdapter(defaultHandler)))));
      await settle(tester);
      final list = find.byType(Scrollable).at(1); // the carbon tab (index 0 is the tab pager)
      for (final key in ['carbon-plain', 'carbon-calc', 'carbon-energy', 'carbon-see-actions']) {
        await tester.scrollUntilVisible(find.byKey(Key(key)), 200, scrollable: list);
      }
      await settle(tester);
      expect(tester.takeException(), isNull);

      // "See what to do" opens the savings tab, with the electricity actions marked best
      await tester.tap(find.byKey(const Key('carbon-see-actions')));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100)); // tab slide
      }
      await settle(tester);
      final l = await AppLocalizations.delegate.load(locale);
      await tester.scrollUntilVisible(find.byKey(const Key('suggest-switch_off_idle')), 300, scrollable: find.descendant(of: find.byType(ImpactView), matching: find.byType(Scrollable)).first);
      expect(find.text(l.actionBestForYou), findsWidgets);
      await tester.ensureVisible(find.text(l.actSwitchOffIdle));
      await settle(tester);
      await tester.tap(find.text(l.actSwitchOffIdle));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100)); // expand
      }
      expect(find.text(l.actionHowTo), findsOneWidget);
      expect(tester.takeException(), isNull);
      await teardownDb(tester, db);
    });
  }
}
