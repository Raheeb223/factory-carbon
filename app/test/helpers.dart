import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:factory_carbon/core/api_client.dart';
import 'package:factory_carbon/core/config.dart';
import 'package:factory_carbon/core/l10n/gen/app_localizations.dart';
import 'package:factory_carbon/data/database.dart';
import 'package:factory_carbon/data/providers.dart';
import 'package:factory_carbon/data/settings_store.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

const testConfig = AppConfig(
  apiBaseUrl: 'http://test.local',
  appToken: 'test-token',
  mapTileUrl: 'https://tile.example/{z}/{x}/{y}.png',
  mapTileAttribution: 'test tiles',
  satelliteTileUrl: '',
  satelliteTileAttribution: '',
  userAgentPackageName: 'test',
);

typedef Handler = ResponseBody Function(RequestOptions options);

/// Dio adapter that answers from a handler instead of the network.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);
  Handler handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    if (requestStream != null) await requestStream.drain<void>();
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object body, {int status = 200}) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );

ApiClient fakeApi(FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: testConfig.apiBaseUrl))..httpClientAdapter = adapter;
  return ApiClient(testConfig, dio: dio);
}

AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

FactoryProfile testProfile() => FactoryProfile(
      id: 'factory-1',
      name: 'Test Garments',
      location: 'Gazipur',
      lat: null,
      lon: null,
      productionUnitLabel: 'pieces',
      privacyAcknowledgedAt: DateTime(2026, 1, 1),
    );

Bill testBill({
  String id = 'b1',
  BillType type = BillType.electricity,
  String month = '2024-05',
  double units = 120,
  EnergyUnit? unit,
  double? amount = 684,
  DataOrigin origin = DataOrigin.billImage,
  List<String> edited = const [],
  DateTime? at,
}) {
  final t = at ?? DateTime(2026, 1, 1);
  return Bill(
    id: id,
    billType: type,
    billingMonth: month,
    consumedUnits: units,
    unit: unit ?? type.canonicalUnit!,
    origin: origin,
    confirmedAt: t,
    createdAt: t,
    updatedAt: t,
    totalAmountBdt: amount,
    userEditedFields: edited,
  );
}

List<Override> testOverrides({required AppDatabase db, ApiClient? api, SettingsStore? settings}) => [
      databaseProvider.overrideWithValue(db),
      settingsStoreProvider.overrideWithValue(settings ?? MemorySettingsStore()),
      appConfigProvider.overrideWithValue(testConfig),
      if (api != null) apiClientProvider.overrideWithValue(api),
    ];

/// Wraps [child] in a localized MaterialApp inside a ProviderScope.
Widget testApp(Widget child, {required List<Override> overrides, Locale locale = const Locale('en')}) => ProviderScope(
      overrides: overrides,
      retry: (_, _) => null,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );

/// Health/defaults answers used by most widget tests.
ResponseBody defaultHandler(RequestOptions o) {
  if (o.path.endsWith('/v1/health')) {
    return jsonBody({'status': 'ok', 'gemini_configured': true, 'placeholders': <String>[]});
  }
  return jsonBody({'error': {'code': 'not_found', 'message': 'no fake for ${o.path}'}}, status: 404);
}

/// Pumps (with real-async ticks, which Dio needs) until [finder] matches.
Future<void> waitFor(WidgetTester tester, Finder finder, {int tries = 60}) async {
  for (var i = 0; i < tries; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsWidgets, reason: 'waited for $finder');
}

/// Lets in-flight async work (HTTP via Dio, drift) finish, then pumps frames.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Scrolls the first scrollable until [finder] is built and visible, then taps it.
Future<void> tapScrolled(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 150, scrollable: find.byType(Scrollable).first);
  await tester.pump(const Duration(seconds: 1)); // let any scroll fling come to rest
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(finder);
  await tester.pump();
}

/// Disposes the tree, flushes drift's stream-cleanup timers, then closes the DB.
Future<void> teardownDb(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(db.close);
}
