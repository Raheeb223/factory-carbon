import 'package:factory_carbon/core/api_client.dart';
import 'package:factory_carbon/core/config.dart';
import 'package:factory_carbon/core/format.dart';
import 'package:factory_carbon/core/l10n/gen/app_localizations.dart';
import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/data/providers.dart';
import 'package:factory_carbon/data/settings_store.dart';
import 'package:factory_carbon/domain/api_models.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/domain/solar_summary.dart';
import 'package:factory_carbon/features/bills/bills_screen.dart';
import 'package:factory_carbon/features/carbon/reports_screen.dart';
import 'package:factory_carbon/features/home/home_shell.dart';
import 'package:factory_carbon/features/settings/server_screen.dart';
import 'package:factory_carbon/features/settings/settings_screen.dart';
import 'package:factory_carbon/features/solar/solar_params_screen.dart';
import 'package:factory_carbon/features/solar/solar_result_screen.dart';
import 'package:factory_carbon/features/solar/solar_screen.dart';
import 'package:factory_carbon/widgets/month_picker.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'domain_test.dart' show carbonJsonFixture;
import 'helpers.dart';

void main() {
  group('server address', () {
    test('normalizeServerUrl accepts host:port and full URLs', () {
      expect(normalizeServerUrl('192.168.1.20:8000'), 'http://192.168.1.20:8000');
      expect(normalizeServerUrl(' https://api.example.com/ '), 'https://api.example.com');
      expect(normalizeServerUrl(''), isNull);
      expect(normalizeServerUrl('ftp://x.y'), isNull);
      expect(normalizeServerUrl('http://'), isNull);
    });

    test('settings override replaces the build-time server', () async {
      final settings = MemorySettingsStore();
      final container = ProviderContainer(overrides: testOverrides(db: memoryDb(), settings: settings));
      expect(container.read(serverConfigProvider).apiBaseUrl, testConfig.apiBaseUrl);
      await container.read(serverConfigProvider.notifier).save('http://10.1.1.1:8000', 'tok');
      expect(container.read(serverConfigProvider).apiBaseUrl, 'http://10.1.1.1:8000');
      expect(container.read(serverConfigProvider).appToken, 'tok');
      expect(settings.serverUrl, 'http://10.1.1.1:8000');
      await container.read(serverConfigProvider.notifier).save(null, null);
      expect(container.read(serverConfigProvider).apiBaseUrl, testConfig.apiBaseUrl);
      container.dispose();
    });
  });

  group('localized messages', () {
    test('error codes are localized in Bangla and English', () async {
      final bn = await AppLocalizations.delegate.load(const Locale('bn'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      const polygon = ApiException(ApiErrorKind.client, 'invalid_polygon', 'Edges cross: Self-intersection[1 2]');
      expect(errorText(bn, polygon), bn.errInvalidPolygon);
      expect(errorText(en, polygon), en.errInvalidPolygon);
      const other = ApiException(ApiErrorKind.client, 'something_new', 'Specific English text');
      expect(errorText(en, other), 'Specific English text');
      expect(errorText(bn, other), bn.errorGeneric);
      expect(errorText(bn, const ApiException(ApiErrorKind.network, 'network', 'x')), bn.errorNetwork);
    });

    test('solar warnings are localized with their numbers', () async {
      final bn = await AppLocalizations.delegate.load(const Locale('bn'));
      final text = solarWarningText(bn, Fmt('bn'), const SolarWarning(code: 'consumption_partial_year', message: 'x', value: 9));
      expect(text, contains('৯'));
      expect(solarWarningText(bn, Fmt('bn'), const SolarWarning(code: 'unknown', message: 'fallback')), 'fallback');
    });
  });

  testWidgets('server screen: test connection shows result, save stores override', (tester) async {
    final db = memoryDb();
    final settings = MemorySettingsStore();
    final adapter = FakeAdapter(defaultHandler);
    await tester.pumpWidget(testApp(
      ServerScreen(clientFactory: (c) => fakeApi(adapter)),
      overrides: testOverrides(db: db, settings: settings),
    ));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('server-url')), 'not a url ::');
    await tester.tap(find.byKey(const Key('server-test')));
    await settle(tester);
    expect(find.text('Enter a valid address, e.g. 192.168.1.20:8000'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('server-url')), '192.168.1.20:8000');
    await tester.enterText(find.byKey(const Key('server-token')), 'abc');
    await tester.tap(find.byKey(const Key('server-test')));
    await waitFor(tester, find.byKey(const Key('server-result')));
    expect(find.text('Connected to the server.'), findsOneWidget);

    await tapScrolled(tester, find.byKey(const Key('server-save')));
    await settle(tester);
    expect(settings.serverUrl, 'http://192.168.1.20:8000');
    expect(settings.serverToken, 'abc');
    await teardownDb(tester, db);
  });

  testWidgets('month picker returns YYYY-MM and blocks future months', (tester) async {
    String? picked;
    await tester.pumpWidget(testApp(
      Builder(builder: (context) => Scaffold(body: Center(child: TextButton(onPressed: () async => picked = await showMonthPicker(context, initial: '2024-05'), child: const Text('open'))))),
      overrides: testOverrides(db: memoryDb()),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('2024'), findsOneWidget);
    await tester.tap(find.byKey(const Key('month-2024-08')));
    await tester.pumpAndSettle();
    expect(picked, '2024-08');

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);
    if (nextMonth.year == now.year) {
      // navigate to the current year and check next month is disabled
      for (var y = 2024; y < now.year; y++) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();
      }
      final key = Key('month-${monthOf(nextMonth)}');
      expect(tester.widget<OutlinedButton>(find.byKey(key)).onPressed, isNull);
    }
  });

  testWidgets('home shows the getting-started checklist and progress', (tester) async {
    final db = memoryDb();
    await tester.runAsync(() async {
      await DriftFactoryRepository(db).save(testProfile());
      await DriftBillRepository(db).save(testBill());
    });
    await tester.pumpWidget(testApp(const HomeShell(), overrides: testOverrides(db: db, api: fakeApi(FakeAdapter(defaultHandler)))));
    await waitFor(tester, find.text('1/4'));
    expect(find.byKey(const Key('getting-started')), findsOneWidget);
    expect(find.text('Enter monthly production'), findsOneWidget);
    await teardownDb(tester, db);
  });

  testWidgets('solar details: plain answers and percents become API fractions', (tester) async {
    final db = memoryDb();
    Map<String, dynamic>? sent;
    final adapter = FakeAdapter((o) {
      if (o.path.endsWith('/v1/solar/defaults')) {
        return jsonBody({
          'params': [
            {'name': 'usable_roof_fraction', 'value': 0.6, 'unit': 'fraction', 'origin': 'default', 'status': 'verified', 'source': 's'},
            {'name': 'performance_ratio', 'value': 0.78, 'unit': 'fraction', 'origin': 'default', 'status': 'verified', 'source': 's'},
          ],
          'net_metering': false,
          'disclaimer': 'd',
        });
      }
      if (o.path.endsWith('/v1/solar/estimate')) {
        sent = o.data is String ? jsonDecode(o.data as String) as Map<String, dynamic> : o.data as Map<String, dynamic>;
        return jsonBody({'error': {'code': 'invalid_polygon', 'message': 'x'}}, status: 422);
      }
      return defaultHandler(o);
    });
    await tester.pumpWidget(testApp(
      const SolarParamsScreen(polygon: [LatLon(23.8, 90.4), LatLon(23.8, 90.401), LatLon(23.801, 90.401)]),
      overrides: testOverrides(db: db, api: fakeApi(adapter)),
    ));
    await settle(tester);
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.byKey(const Key('param-export_price_bdt_per_kwh')), findsNothing);

    // "Not sure" about shade sends nothing, so the result can warn that shading was not assessed
    await tester.tap(find.byKey(const Key('solar-estimate')));
    await settle(tester);
    expect(sent!['params'], isNot(contains('shading_loss')));

    await tester.tap(find.byKey(const Key('shade-some')));
    await tester.enterText(find.byKey(const Key('param-capex_bdt_per_kwp')), '60,000');
    await tapScrolled(tester, find.byKey(const Key('net-metering')));
    await tapScrolled(tester, find.text(en.paramsAdvanced));
    await settle(tester);
    expect(find.textContaining(en.paramDefault('60%')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('param-usable_roof_fraction')), '70');
    await tester.enterText(find.byKey(const Key('param-export_price_bdt_per_kwh')), '5');
    await tester.tap(find.byKey(const Key('solar-estimate')));
    await settle(tester);
    final params = sent!['params'] as Map<String, dynamic>;
    expect(params['shading_loss'], 0.1);
    expect(params['capex_bdt_per_kwp'], 60000);
    expect(params['usable_roof_fraction'], closeTo(0.7, 1e-9));
    expect(params['net_metering'], true);
    expect(params['export_price_bdt_per_kwh'], 5);

    await tester.enterText(find.byKey(const Key('param-usable_roof_fraction')), '170');
    await tester.tap(find.byKey(const Key('solar-estimate')));
    await settle(tester);
    expect(find.text(en.invalidPercent), findsOneWidget);
    await teardownDb(tester, db);
  });

  test('panel count rounds down so the panels fit', () {
    expect(panelCount(308.571, 550), 561);
    expect(panelCount(5.5, 550), 10);
    expect(panelCount(1, 0), 0);
  });

  test('solar result in plain words and a step chain an engineer can check', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final fmt = Fmt('en');
    final r = SolarResult.fromJson(solarResultFixture());
    final s = SolarSummary(r, panelWatt: 550);
    final words = plainWords(en, fmt, s);
    expect(words.first, en.solarSay1('561', '550', '309'));
    expect(words[2], contains('covers about'));
    expect(words.last, en.solarSayNoPrice);

    final steps = workedSteps(en, fmt, s);
    expect(steps.map((e) => e.$2), [
      en.valueM2('3,600'),
      en.valueM2('2,160'),
      en.valueKwp('308.6'),
      en.solarPanelsCount('561'),
      en.valueHoursDay(fmt.number(r.peakSunHoursAnnualAvg, decimals: 2)),
      en.valueKwhYear(fmt.number(r.annualGenerationKwh)),
      en.tonnesCo2(fmt.tonnes(r.co2AvoidedT)),
    ]);
    expect(steps[1].$1, contains('60%'));
    // the chain multiplies out to the backend's yearly output
    expect(308.571 * r.peakSunHoursAnnualAvg * 365 * 0.78, closeTo(r.annualGenerationKwh, 1));
    // a panel size chosen by the user changes only the count
    expect(SolarSummary(r, panelWatt: 600).panels, 514);
  });

  // Every main screen, both languages, on a small phone (360x640): no overflow or exceptions.
  for (final locale in const [Locale('en'), Locale('bn')]) {
    final screens = <String, Widget>{
      'home': const HomeShell(),
      'bills': const BillsScreen(),
      'reports': const ReportsScreen(),
      'solar': const SolarScreen(),
      'settings': const SettingsScreen(),
      'solar details': const SolarParamsScreen(polygon: [LatLon(23.8, 90.4), LatLon(23.8, 90.401), LatLon(23.801, 90.401)]),
      'solar result': SolarResultScreen(result: SolarResult.fromJson(solarResultFixture()), polygon: const [LatLon(23.8, 90.4)], params: const {'panel_watt': 550}),
    };
    for (final entry in screens.entries) {
      testWidgets('${entry.key} renders in ${locale.languageCode} on a small phone', (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        final db = memoryDb();
        await tester.runAsync(() async {
          await DriftFactoryRepository(db).save(testProfile());
          await DriftBillRepository(db).save(testBill(origin: DataOrigin.demo));
          await DriftBillRepository(db).save(testBill(id: 'b2', type: BillType.diesel, units: 300, amount: 31800));
          await DriftResultCacheRepository(db).put('carbon', {'input_hash': 'x', 'response': carbonJsonFixture()});
        });
        final settings = MemorySettingsStore()..localeCode = locale.languageCode;
        await tester.pumpWidget(testApp(entry.value, locale: locale, overrides: testOverrides(db: db, settings: settings, api: fakeApi(FakeAdapter(defaultHandler)))));
        await settle(tester);
        expect(tester.takeException(), isNull);
        // scroll through the page to lay out everything
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -2000));
          await settle(tester);
          expect(tester.takeException(), isNull);
        }
        await teardownDb(tester, db);
      });
    }
  }
}

/// A backend-shaped solar estimate for a 3,600 m² roof in Dhaka (no capex, so no financials).
Map<String, dynamic> solarResultFixture() {
  const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  const psh = [4.2, 4.9, 5.6, 5.8, 5.4, 4.4, 4.0, 4.1, 4.0, 4.3, 4.3, 4.0];
  const kwp = 3600 * 0.6 / 7;
  final gen = [for (var i = 0; i < 12; i++) kwp * psh[i] * days[i] * 0.78];
  final annual = gen.reduce((a, b) => a + b);
  var avg = 0.0;
  for (var i = 0; i < 12; i++) {
    avg += psh[i] * days[i] / 365;
  }
  const use = 1200000.0;
  return {
    'roof_area_m2': 3600.0,
    'usable_area_m2': 2160.0,
    'kwp': kwp,
    'centroid': {'lat': 23.8, 'lon': 90.4},
    'peak_sun_hours_monthly': psh,
    'peak_sun_hours_annual_avg': avg,
    'irradiance_source': 'nasa_power',
    'monthly_generation_kwh': gen,
    'annual_generation_kwh': annual,
    'annual_consumption_kwh': use,
    'self_consumed_kwh': annual,
    'exported_kwh': 0.0,
    'offset_share': annual / use,
    'co2_avoided_t_per_year': annual * 0.62 / 1000,
    'financials': null,
    'params_used': [
      for (final (n, v) in [('usable_roof_fraction', 0.6), ('m2_per_kwp', 7), ('performance_ratio', 0.78), ('shading_loss', 0)])
        {'name': n, 'value': v, 'unit': 'x', 'origin': 'default', 'status': 'verified', 'source': 's'},
    ],
    'factors': {
      'grid_electricity': {'name': 'grid_electricity', 'value': 0.62, 'unit': 'kgCO2_per_kWh', 'source': 'DoE', 'year': 2023, 'status': 'verified'},
    },
    'warnings': [
      {'code': 'shading_not_assessed', 'message': 'x'},
    ],
    'disclaimer': 'Estimate only.',
  };
}
