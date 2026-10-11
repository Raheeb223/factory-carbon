import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:factory_carbon/app.dart';
import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/data/providers.dart';
import 'package:factory_carbon/data/settings_store.dart';
import 'package:factory_carbon/domain/api_models.dart';
import 'package:factory_carbon/domain/image_prep.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/features/add_bill/redact_screen.dart';
import 'package:factory_carbon/features/add_bill/review_screen.dart';
import 'package:factory_carbon/features/bills/bills_screen.dart';
import 'package:factory_carbon/features/carbon/carbon_screen.dart';
import 'package:factory_carbon/features/settings/data_admin.dart';
import 'package:factory_carbon/features/waste/waste_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'domain_test.dart' show carbonJsonFixture;
import 'helpers.dart';

final _png = img.encodePng(img.Image(width: 40, height: 60));

ExtractBillResult _extraction() => ExtractBillResult(
  bill: ExtractedBill(
    billType: BillType.electricity,
    billingMonth: '2024-05',
    periodStart: DateTime(2024, 5, 1),
    periodEnd: DateTime(2024, 5, 30),
    consumedUnits: 100,
    unit: EnergyUnit.kWh,
    totalAmountBdt: 684,
    tariffCode: 'LT-B',
    fieldConfidence: const {'consumed_units': 'low', 'tariff_code': 'high'},
    notes: 'Multiplying factor 1.2',
  ),
  warnings: const [ExtractionWarning(field: 'total_amount_bdt', code: 'price_per_unit_out_of_band', message: 'Amount per unit is Tk 6.84, check.')],
  model: 'fake',
  promptVersion: 'v1',
);

Finder _scrollable() => find.byType(Scrollable).first;

Future<void> _scrollTo(WidgetTester tester, Finder f, {double delta = 150}) => tester.scrollUntilVisible(f, delta, scrollable: _scrollable());

void main() {
  testWidgets('onboarding requires the privacy acknowledgement before saving', (tester) async {
    final db = memoryDb();
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(db: db, api: fakeApi(FakeAdapter(defaultHandler))),
        retry: (_, _) => null,
        child: const FactoryCarbonApp(),
      ),
    );
    await waitFor(tester, find.byKey(const Key('intro-skip')));
    await tester.tap(find.byKey(const Key('intro-skip')));
    await tester.pump();
    await waitFor(tester, find.text('Set up your factory'));

    await tester.enterText(find.byKey(const Key('factory-name')), 'Rahman Knit');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tapScrolled(tester, find.byKey(const Key('onboarding-save')));
    await settle(tester);
    expect(find.text('Please confirm you have read the privacy notice.'), findsOneWidget);
    expect(await tester.runAsync(() => DriftFactoryRepository(db).get()), isNull);

    await tapScrolled(tester, find.byKey(const Key('privacy-ack')));
    await tapScrolled(tester, find.byKey(const Key('onboarding-save')));
    await waitFor(tester, find.byType(NavigationBar));
    expect((await tester.runAsync(() => DriftFactoryRepository(db).get()))?.name, 'Rahman Knit');
    await teardownDb(tester, db);
  });

  testWidgets('review: low-confidence highlight, inline warnings, confirm gate, edits recorded', (tester) async {
    final db = memoryDb();
    final x = _extraction();
    await tester.pumpWidget(
      testApp(
        ReviewScreen(extraction: x, warnings: x.warnings, imageBytes: _png, extracted: x.bill),
        overrides: testOverrides(db: db),
      ),
    );
    await settle(tester);

    expect(find.byType(InteractiveViewer), findsOneWidget);
    await _scrollTo(tester, find.byKey(const Key('low-consumed_units')));
    expect(find.byKey(const Key('low-tariff_code')), findsNothing);
    await _scrollTo(tester, find.byKey(const Key('warn-total_amount_bdt')));

    await tester.enterText(find.byKey(const Key('input-consumed_units')), '120');
    await tester.testTextInput.receiveAction(TextInputAction.done); // dismiss keyboard
    await tester.pump();
    final save = find.byKey(const Key('review-save'));
    await _scrollTo(tester, save);
    expect(find.text('The photo is deleted from this phone after saving.'), findsOneWidget);
    expect(tester.widget<FilledButton>(save).onPressed, isNull, reason: 'Save is disabled until the user confirms');

    await tapScrolled(tester, find.byKey(const Key('review-confirm')));
    await _scrollTo(tester, save);
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    await tester.tap(save);
    await settle(tester);

    final bills = (await tester.runAsync(() => DriftBillRepository(db).all()))!;
    expect(bills, hasLength(1));
    final b = bills.single;
    expect(b.consumedUnits, 120);
    expect(b.origin, DataOrigin.billImage);
    expect(b.userEditedFields, ['consumed_units']);
    expect(b.extractionModel, 'fake');
    expect(b.imagePath, isNull, reason: 'images are not kept by default');
    await teardownDb(tester, db);
  });

  testWidgets('review: duplicate month+type asks before saving', (tester) async {
    final db = memoryDb();
    await tester.runAsync(() => DriftBillRepository(db).save(testBill(id: 'old', month: '2024-05')));
    final x = _extraction();
    await tester.pumpWidget(
      testApp(
        ReviewScreen(extraction: x, warnings: const [], imageBytes: null, extracted: x.bill),
        overrides: testOverrides(db: db),
      ),
    );
    await settle(tester);
    await tapScrolled(tester, find.byKey(const Key('review-confirm')));
    await tapScrolled(tester, find.byKey(const Key('review-save')));
    await waitFor(tester, find.text('Possible duplicate'));
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(await tester.runAsync(() => DriftBillRepository(db).all()), hasLength(1));
    await teardownDb(tester, db);
  });

  testWidgets('manual entry requires a bill type and valid month', (tester) async {
    final db = memoryDb();
    await tester.pumpWidget(
      testApp(
        const ReviewScreen(extraction: null, warnings: [], imageBytes: null, extracted: ExtractedBill.empty),
        overrides: testOverrides(db: db),
      ),
    );
    await settle(tester);
    expect(find.text('Enter the values from your bill or receipt.'), findsOneWidget);
    await tapScrolled(tester, find.byKey(const Key('review-confirm')));
    await tapScrolled(tester, find.byKey(const Key('review-save')));
    await settle(tester);
    await _scrollTo(tester, find.text('Select the bill type'), delta: -150);
    await _scrollTo(tester, find.text('Select a month'));
    expect(await tester.runAsync(() => DriftBillRepository(db).all()), isEmpty);
    await teardownDb(tester, db);
  });

  testWidgets('carbon view: unverified badge, factor-not-set message, refresh calls backend', (tester) async {
    final db = memoryDb();
    await tester.runAsync(() async {
      await DriftFactoryRepository(db).save(testProfile());
      await DriftBillRepository(db).save(testBill());
      await DriftResultCacheRepository(db).put('carbon', {'input_hash': 'old', 'response': carbonJsonFixture()});
    });
    final adapter = FakeAdapter((o) => o.path == '/v1/carbon/calculate' ? jsonBody(carbonJsonFixture()) : defaultHandler(o));
    await tester.pumpWidget(
      testApp(
        const Scaffold(body: CarbonView()),
        overrides: testOverrides(db: db, api: fakeApi(adapter)),
      ),
    );
    await waitFor(tester, find.byKey(const Key('factor-not-set')));
    expect(find.textContaining('grid electricity emission factor is not set'), findsOneWidget);
    expect(find.byKey(const Key('carbon-stale')), findsOneWidget);
    await _scrollTo(tester, find.byKey(const Key('unverified-badge')), delta: 200);
    await _scrollTo(tester, find.byKey(const Key('carbon-refresh')), delta: -300);

    await tester.tap(find.byKey(const Key('carbon-refresh')));
    await settle(tester);
    final sent = adapter.requests.singleWhere((r) => r.path == '/v1/carbon/calculate');
    final body = sent.data as Map<String, dynamic>;
    expect((body['bills'] as List<dynamic>).single, containsPair('billing_month', '2024-05'));
    expect(find.byKey(const Key('carbon-stale')), findsNothing);
    await teardownDb(tester, db);
  });

  testWidgets('waste view: insufficient data state and flagged message', (tester) async {
    final db = memoryDb();
    var response = <String, dynamic>{
      'status': 'insufficient_data',
      'method': null,
      'confidence_label': null,
      'month_count': 3,
      'required_months': 6,
      'months': <Object>[],
      'flagged_months': <Object>[],
      'avg_bdt_per_kwh': null,
      'messages': <Object>[],
      'limitations': <Object>[],
      'model_summary': <String, Object>{},
    };
    final adapter = FakeAdapter((o) => jsonBody(response));
    await tester.pumpWidget(
      testApp(
        const Scaffold(body: WasteView()),
        overrides: testOverrides(db: db, api: fakeApi(adapter)),
      ),
    );
    await settle(tester);
    await tester.tap(find.byKey(const Key('waste-analyze')));
    await waitFor(tester, find.byKey(const Key('waste-insufficient')));
    expect(find.textContaining('Only 3 months'), findsOneWidget);

    response = {
      'status': 'ok',
      'method': 'ols_production',
      'confidence_label': 'x',
      'month_count': 6,
      'required_months': 6,
      'months': [
        for (var i = 1; i <= 6; i++)
          {
            'month': '2024-0$i',
            'actual_kwh': i == 4 ? 118000.0 : 100000.0,
            'production': 1000.0,
            'expected_kwh': 100000.0,
            'lower_kwh': 90000.0,
            'upper_kwh': 110000.0,
            'flagged': i == 4,
            'excess_kwh': i == 4 ? 18000.0 : null,
            'excess_pct': i == 4 ? 18.0 : null,
            'excess_cost_bdt': i == 4 ? 189000.0 : null,
          },
      ],
      'flagged_months': ['2024-04'],
      'avg_bdt_per_kwh': 10.5,
      'messages': <Object>[],
      'limitations': <Object>[],
      'model_summary': <String, Object>{},
    };
    await tester.tap(find.byKey(const Key('waste-analyze')));
    await settle(tester);
    await _scrollTo(tester, find.byKey(const Key('waste-flag-2024-04')), delta: 200);
    expect(find.textContaining('Anomaly in April 2024: about 18% more electricity than expected for the units produced'), findsOneWidget);
    expect(find.textContaining('about Tk 189,000'), findsOneWidget);
    await teardownDb(tester, db);
  });

  test('data admin: demo data loads as synthetic, is removable, never mixes with real data', () async {
    final db = memoryDb();
    final container = ProviderContainer(overrides: testOverrides(db: db));
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final admin = container.read(dataAdminProvider);
    final demoJson = File('assets/demo/demo_data.json').readAsStringSync();

    expect(await admin.loadDemo(jsonText: demoJson), DemoLoadResult.loaded);
    final bills = await DriftBillRepository(db).all();
    expect(bills, hasLength(72));
    expect(bills.every((b) => b.isSynthetic), isTrue);
    expect((await DriftProductionRepository(db).all()).every((p) => p.isSynthetic), isTrue);

    await admin.removeDemo();
    expect(await DriftBillRepository(db).all(), isEmpty);
    expect(await DriftProductionRepository(db).all(), isEmpty);

    await DriftBillRepository(db).save(testBill());
    expect(await admin.loadDemo(jsonText: demoJson), DemoLoadResult.notEmpty);
    expect((await DriftBillRepository(db).all()).where((b) => b.isSynthetic), isEmpty);

    await DriftFactoryRepository(db).save(testProfile());
    await admin.deleteAll();
    expect(await DriftBillRepository(db).all(), isEmpty);
    expect(await DriftFactoryRepository(db).get(), isNull);
  });

  testWidgets('synthetic data shows a banner and SYNTHETIC badges', (tester) async {
    final db = memoryDb();
    await tester.pumpWidget(
      testApp(
        const BillsScreen(),
        overrides: [
          ...testOverrides(db: db),
          billsProvider.overrideWith((ref) => Stream.value([testBill(origin: DataOrigin.demo)])),
          productionProvider.overrideWith((ref) => Stream.value(const <ProductionEntry>[])),
        ],
      ),
    );
    await waitFor(tester, find.byKey(const Key('synthetic-banner')));
    expect(find.text('SYNTHETIC DATA'), findsOneWidget);
    await teardownDb(tester, db);
  });

  testWidgets('Bangla locale renders translated onboarding', (tester) async {
    final db = memoryDb();
    final settings = MemorySettingsStore()..localeCode = 'bn';
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(db: db, settings: settings, api: fakeApi(FakeAdapter(defaultHandler))),
        retry: (_, _) => null,
        child: const FactoryCarbonApp(),
      ),
    );
    await waitFor(tester, find.text('পরবর্তী'));
    await tester.tap(find.byKey(const Key('intro-skip')));
    await tester.pump();
    await waitFor(tester, find.text('আপনার কারখানা সেট আপ করুন'));
    await teardownDb(tester, db);
  });

  testWidgets('redaction: drag covers an area, undo removes it, result is burned in', (tester) async {
    final white = img.Image(width: 300, height: 400);
    img.fill(white, color: img.ColorRgb8(255, 255, 255));
    final jpeg = Uint8List.fromList(img.encodeJpg(white));
    Uint8List? result;
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async => result = await Navigator.of(context).push<Uint8List>(
                  MaterialPageRoute(
                    builder: (_) => RedactScreen(imageBytes: jpeg, redactor: (b, x) async => applyRedactions(b, x)),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        overrides: testOverrides(db: memoryDb()),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump(const Duration(milliseconds: 500));
    await waitFor(tester, find.byKey(const Key('redact-canvas')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100)); // let the page transition finish
    }
    expect(find.text('No areas covered'), findsOneWidget);

    final r = tester.getRect(find.byKey(const Key('redact-canvas')));
    await tester.dragFrom(r.topLeft + Offset(r.width * 0.1, r.height * 0.1), Offset(r.width * 0.5, r.height * 0.2));
    await tester.pump();
    expect(find.text('1 area covered'), findsOneWidget);
    await tester.tap(find.byKey(const Key('redact-undo')));
    await tester.pump();
    expect(find.text('No areas covered'), findsOneWidget);
    await tester.dragFrom(r.topLeft + Offset(r.width * 0.1, r.height * 0.1), Offset(r.width * 0.5, r.height * 0.2));
    await tester.pump();

    await tester.tap(find.byKey(const Key('redact-done')));
    for (var i = 0; i < 100 && result == null; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(result, isNotNull);
    final out = img.decodeJpg(result!)!;
    expect(out.getPixel((300 * 0.3).round(), (400 * 0.2).round()).r, lessThan(30)); // covered
    expect(out.getPixel(280, 380).r, greaterThan(225)); // untouched
  });

  test('carbon fixture round-trips through JSON', () {
    final r = CarbonResult.fromJson(jsonDecode(jsonEncode(carbonJsonFixture())) as Map<String, dynamic>);
    expect(r.errors.single.factor, 'grid_electricity');
  });
}
