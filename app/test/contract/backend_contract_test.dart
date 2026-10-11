/// Contract test: the app's ApiClient + DTOs against a REAL running backend.
/// Skipped unless BACKEND_URL is set, e.g.
///   BACKEND_URL=http://127.0.0.1:8765 APP_TOKEN=dev flutter test test/contract
@Tags(['contract'])
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:factory_carbon/core/api_client.dart';
import 'package:factory_carbon/core/config.dart';
import 'package:factory_carbon/domain/api_models.dart';
import 'package:factory_carbon/domain/demo_data.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/domain/requests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final url = Platform.environment['BACKEND_URL'];
  final skip = url == null ? 'BACKEND_URL not set' : null;
  late ApiClient api;
  late DemoDataset demo;

  setUpAll(() {
    if (url == null) return;
    // flutter_test blocks real HTTP by default; this test intentionally talks to a local server.
    HttpOverrides.global = null;
    api = ApiClient(
      AppConfig(
        apiBaseUrl: url,
        appToken: Platform.environment['APP_TOKEN'] ?? 'dev',
        mapTileUrl: '',
        mapTileAttribution: '',
        satelliteTileUrl: '',
        satelliteTileAttribution: '',
        userAgentPackageName: 'test',
      ),
      dio: Dio(BaseOptions(baseUrl: url)),
    );
    var n = 0;
    demo = parseDemoData(File('assets/demo/demo_data.json').readAsStringSync(), newId: () => 'id${n++}');
  });

  List<ProductionEntry> production() => [
        for (final (m, u) in demo.production) ProductionEntry(id: m, month: m, unitsProduced: u, origin: DataOrigin.demo, updatedAt: DateTime(2026)),
      ];

  test('health', () async {
    final h = await api.health();
    expect(h.placeholders, isNot(contains('emission_factors.grid_electricity')));
  }, skip: skip);

  test('carbon/calculate: verified factors give Scope 1 + 2, intensity, synthetic note', () async {
    final json = await api.calculateCarbonRaw(carbonRequest(bills: demo.bills, production: production(), productionUnitLabel: 'pieces'));
    final r = CarbonResult.fromJson(json);
    expect(r.months, hasLength(24));
    expect(r.errors, isEmpty);
    expect(r.placeholdersInUse, isEmpty);
    expect(r.totals.scope1T, greaterThan(0));
    expect(r.totals.scope2T, greaterThan(0));
    expect(r.totals.intensity, isNotNull);
    expect(r.factors['grid_electricity']?.value, 0.62);
    expect(r.notes.map((n) => n.code), contains('synthetic_data'));
  }, skip: skip);

  test('waste/analyze flags the injected anomalies', () async {
    final json = await api.analyzeWasteRaw(wasteRequest(bills: demo.bills, production: production()));
    final r = WasteResult.fromJson(json);
    expect(r.usesProduction, isTrue);
    expect(r.flaggedMonths, containsAll(demo.anomalyMonths));
  }, skip: skip);

  test('solar defaults + estimate (manual sun hours, no network to NASA)', () async {
    final d = await api.solarDefaults();
    expect(d.param('m2_per_kwp')?.number, 7);
    final r = await api.solarEstimate({
      'polygon': [
        {'lat': 23.81, 'lon': 90.41},
        {'lat': 23.81, 'lon': 90.4104},
        {'lat': 23.8104, 'lon': 90.4104},
        {'lat': 23.8104, 'lon': 90.41},
      ],
      'params': {'capex_bdt_per_kwp': 55000},
      'consumption': solarConsumption(demo.bills),
      'manual_peak_sun_hours': 4.5,
    });
    expect(r.kwp, greaterThan(0));
    expect(r.financials?.cashflow, hasLength(26));
    expect(r.disclaimer, contains('professional assessment'));
    expect(r.co2AvoidedT, greaterThan(0));
  }, skip: skip);

  test('report/pdf returns a PDF', () async {
    final bytes = await api.reportPdf({
      'factory': {'name': 'Contract Test Ltd'},
      'carbon': carbonRequest(bills: demo.bills, production: production()),
      'contains_synthetic_data': true,
    });
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  }, skip: skip);

  test('history template', () async {
    expect((await api.historyTemplate()).split('\n').first.trim(), startsWith('month,electricity_kwh'));
  }, skip: skip);

  test('bad token is rejected with a typed error', () async {
    final bad = ApiClient(
      AppConfig(apiBaseUrl: url!, appToken: 'wrong', mapTileUrl: '', mapTileAttribution: '', satelliteTileUrl: '', satelliteTileAttribution: '', userAgentPackageName: 't'),
      dio: Dio(BaseOptions(baseUrl: url)),
    );
    await expectLater(bad.health(), throwsA(isA<ApiException>().having((e) => e.code, 'code', 'invalid_app_token')));
  }, skip: skip);
}
