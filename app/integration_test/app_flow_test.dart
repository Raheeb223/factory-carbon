// End-to-end checks on a real phone against the real backend (Gemini, NASA POWER).
//
//   flutter test integration_test/app_flow_test.dart -d <device> --dart-define-from-file=env/dev.json
//
// Lines printed as "SHOT:<name>" are hooks for a host script that takes screenshots.
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:factory_carbon/app.dart';
import 'package:factory_carbon/core/format.dart';
import 'package:factory_carbon/core/l10n/gen/app_localizations.dart';
import 'package:factory_carbon/data/database.dart';
import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/data/providers.dart';
import 'package:factory_carbon/data/settings_store.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/features/add_bill/redact_screen.dart';
import 'package:factory_carbon/features/add_bill/text_finder.dart';
import 'package:factory_carbon/features/add_bill/upload_screen.dart';
import 'package:factory_carbon/features/carbon/carbon_screen.dart';
import 'package:factory_carbon/features/export/export_service.dart';
import 'package:factory_carbon/features/home/home_shell.dart';
import 'package:factory_carbon/features/impact/impact_screen.dart';
import 'package:factory_carbon/features/solar/solar_params_screen.dart';
import 'package:factory_carbon/features/solar/solar_result_screen.dart';
import 'package:factory_carbon/features/waste/waste_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';

final en = lookupAppLocalizations(const Locale('en'));

/// A clearly synthetic electricity bill with printed values for Gemini to read.
Uint8List syntheticBill() {
  final image = img.Image(width: 1100, height: 1400);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));
  final black = img.ColorRgb8(20, 20, 20);
  var y = 50;
  void line(String text, {img.BitmapFont? font, int gap = 70}) {
    img.drawString(image, text, font: font ?? img.arial24, x: 60, y: y, color: black);
    y += gap;
  }

  line('DHAKA POWER DISTRIBUTION CO. (SAMPLE)', font: img.arial48, gap: 90);
  line('ELECTRICITY BILL - SYNTHETIC TEST DOCUMENT', gap: 80);
  line('Consumer Name: MD. KARIM UDDIN', gap: 40);
  line('Address: House 12, Road 5, Gazipur', gap: 70);
  line('Bill Month: May 2024');
  line('Billing Period: 01-05-2024 to 31-05-2024');
  line('Tariff: LT-E (Industrial)');
  line('Sanctioned Load: 150 kW');
  line('Previous Reading: 345,600');
  line('Present Reading: 358,050');
  line('Units Consumed: 12,450 kWh', font: img.arial48, gap: 90);
  line('Energy Charge: Tk 99,600');
  line('Demand Charge: Tk 4,500');
  line('VAT (5%): Tk 4,400');
  line('Total Amount Payable: Tk 108,500', font: img.arial48, gap: 90);
  line('This is synthetic test data, not a real bill.');
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

Future<void> pumpFor(WidgetTester tester, Duration d) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

Future<void> pumpUntil(WidgetTester tester, Finder f, {Duration timeout = const Duration(seconds: 30)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (f.evaluate().isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }
  throw TestFailure('Timed out after $timeout waiting for $f');
}

/// Prints a screenshot hook and holds the frame still long enough for capture.
Future<void> shot(WidgetTester tester, String name) async {
  await pumpFor(tester, const Duration(milliseconds: 900));
  // ignore: avoid_print
  print('SHOT:$name');
  await pumpFor(tester, const Duration(milliseconds: 2600));
}

Future<void> tapVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await pumpFor(tester, const Duration(milliseconds: 400));
  await tester.tap(f);
  await tester.pump();
}

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)));
  await pumpFor(tester, const Duration(milliseconds: 600));
}

Widget app(AppDatabase db, SettingsStore settings) => ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db), settingsStoreProvider.overrideWithValue(settings)],
      retry: (_, _) => null,
      child: const FactoryCarbonApp(),
    );

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first run: welcome, setup, scan a bill with Gemini, review and save', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final settings = MemorySettingsStore()..localeCode = 'en';
    await tester.pumpWidget(app(db, settings));

    await pumpUntil(tester, find.byKey(const Key('intro-next')));
    await shot(tester, '01_intro_1');
    await tester.tap(find.byKey(const Key('intro-next')));
    await shot(tester, '02_intro_2');
    await tester.tap(find.byKey(const Key('intro-next')));
    await shot(tester, '03_intro_3');
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const Key('intro-next')));
      await pumpFor(tester, const Duration(milliseconds: 600));
    }

    await pumpUntil(tester, find.byKey(const Key('factory-name')));
    await tester.enterText(find.byKey(const Key('factory-name')), 'Rahman Knit Ltd');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tapVisible(tester, find.byKey(const Key('unit-dozens')));
    await shot(tester, '04_setup');
    await tapVisible(tester, find.byKey(const Key('privacy-ack')));
    await tapVisible(tester, find.byKey(const Key('onboarding-save')));
    await pumpUntil(tester, find.byType(NavigationBar));

    // The server must be reachable and able to read bills: no warning card.
    await pumpFor(tester, const Duration(seconds: 3));
    expect(find.byKey(const Key('connection-card')), findsNothing, reason: 'backend unreachable or bill reading off');
    await shot(tester, '05_home_new');

    await tester.tap(find.byKey(const Key('add-bill-fab')));
    await pumpUntil(tester, find.byKey(const Key('add-camera')));
    await shot(tester, '06_add_bill');

    // Camera/crop are native screens; inject the prepared photo exactly where the flow hands it
    // over: to the "hide private details" step, then on to upload (as AddBillScreen does).
    final nav = Navigator.of(tester.element(find.byKey(const Key('add-camera'))));
    final covered = nav.push<Uint8List>(MaterialPageRoute(builder: (_) => RedactScreen(imageBytes: syntheticBill(), finder: MlKitTextFinder())));
    await pumpUntil(tester, find.byKey(const Key('redact-auto')));
    // The phone's text reader found the consumer name/address and covered it by itself.
    final auto = tester.widget<Text>(find.byKey(const Key('redact-auto'))).data!;
    expect(auto, isNot(en.redactAutoNone), reason: 'name/address not found automatically');
    await shot(tester, '07a_redact');
    // Also cover the company header line (top ~3-8% of the bill) by hand.
    final before = RegExp(r'\d+').firstMatch(auto)!.group(0)!;
    final canvas = tester.getRect(find.byKey(const Key('redact-canvas')));
    await tester.dragFrom(canvas.topLeft + Offset(canvas.width * 0.03, canvas.height * 0.025), Offset(canvas.width * 0.9, canvas.height * 0.06));
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.text(en.redactAreas(int.parse(before) + 1)), findsOneWidget);
    await shot(tester, '07b_redacted');
    await tester.tap(find.byKey(const Key('redact-done')));
    final bytes = await covered;
    expect(bytes, isNotNull);
    nav.pushReplacement(MaterialPageRoute<void>(builder: (_) => UploadScreen(imageBytes: bytes!)));
    await pumpFor(tester, const Duration(milliseconds: 1500));
    await shot(tester, '07_reading');
    await pumpUntil(tester, find.byKey(const Key('review-confirm')), timeout: const Duration(seconds: 150));

    final units = tester.widget<TextFormField>(find.byKey(const Key('input-consumed_units'))).controller!.text;
    final amount = tester.widget<TextFormField>(find.byKey(const Key('input-total_amount_bdt'))).controller!.text;
    expect(parseNumber(units), 12450, reason: 'consumed units read from the bill');
    expect(parseNumber(amount), 108500, reason: 'total amount read from the bill');
    await shot(tester, '08_review');

    await tapVisible(tester, find.byKey(const Key('review-confirm')));
    await tapVisible(tester, find.byKey(const Key('review-save')));
    await pumpUntil(tester, find.byType(NavigationBar));
    await pumpFor(tester, const Duration(seconds: 1));
    final saved = await DriftBillRepository(db).all();
    expect(saved, hasLength(1));
    expect(saved.single.billType, BillType.electricity);
    expect(saved.single.billingMonth, '2024-05');
    expect(saved.single.consumedUnits, 12450);
    expect(saved.single.origin, DataOrigin.billImage);
    await shot(tester, '09_home_after_bill');

    await openTab(tester, en.navBills);
    await shot(tester, '10_bills');

    // Monthly production entry (dialog form).
    await tester.tap(find.byTooltip(en.productionTitle));
    await pumpUntil(tester, find.byKey(const Key('production-add')));
    await tester.tap(find.byKey(const Key('production-add')));
    await pumpUntil(tester, find.byKey(const Key('production-units')));
    await tester.enterText(find.byKey(const Key('production-units')), '52000');
    await tester.tap(find.byKey(const Key('production-save')));
    await pumpFor(tester, const Duration(seconds: 1));
    expect((await DriftProductionRepository(db).all()).single.unitsProduced, 52000);
    await shot(tester, '10b_production');

    await tester.pumpWidget(const SizedBox());
    await pumpFor(tester, const Duration(seconds: 1));
    await db.close();
  });

  testWidgets('demo data: carbon report, waste check, PDF, solar estimate, Bangla', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final settings = MemorySettingsStore()..localeCode = 'en';
    await DriftFactoryRepository(db).save(FactoryProfile(
      id: 'f1',
      name: 'Rahman Knit Ltd',
      location: 'Gazipur',
      lat: 23.9999,
      lon: 90.4203,
      productionUnitLabel: 'pieces',
      privacyAcknowledgedAt: DateTime.now(),
    ));
    await tester.pumpWidget(app(db, settings));
    await pumpUntil(tester, find.byType(NavigationBar));

    // Load demo data from the home checklist.
    await pumpUntil(tester, find.byKey(const Key('home-load-demo')));
    await tapVisible(tester, find.byKey(const Key('home-load-demo')));
    await pumpFor(tester, const Duration(seconds: 2));
    expect(await DriftBillRepository(db).all(), isNotEmpty);
    // The tap scrolled the home list down; go back to the top where the banner sits.
    await tester.fling(find.byType(ListView).first, const Offset(0, 3000), 3000);
    await pumpUntil(tester, find.byKey(const Key('synthetic-banner')));
    await shot(tester, '11_home_demo');

    // Carbon report from the real backend.
    await openTab(tester, en.navReports);
    await tester.tap(find.byKey(const Key('carbon-refresh')));
    await pumpUntil(tester, find.text(en.carbonTotal), timeout: const Duration(seconds: 60));
    await shot(tester, '12_carbon');
    // Plain-words explanation of the tCO2e number.
    expect(find.byKey(const Key('co2-kg')), findsOneWidget);
    await tester.tap(find.byKey(const Key('co2-explain')));
    await pumpUntil(tester, find.byKey(const Key('co2-sheet')));
    await shot(tester, '12b_co2_explained');
    Navigator.of(tester.element(find.byKey(const Key('co2-sheet')))).pop();
    await pumpFor(tester, const Duration(milliseconds: 800));
    final carbonList = find.descendant(of: find.byType(CarbonView), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const Key('export-pdf')), 300, scrollable: carbonList);
    await shot(tester, '13_carbon_scrolled');

    // Back on Home the hero now shows the footprint.
    await openTab(tester, en.navHome);
    await shot(tester, '14_home_footprint');

    // Waste check.
    await openTab(tester, en.navReports);
    await tester.tap(find.descendant(of: find.byType(TabBar), matching: find.text(en.tabUnusual)));
    await pumpFor(tester, const Duration(milliseconds: 800));
    await tester.tap(find.byKey(const Key('waste-analyze')));
    await pumpUntil(tester, find.byWidgetPredicate((w) => w is Text && (w.data == en.wasteAttentionTitle || w.data == en.wasteAllGoodTitle)),
        timeout: const Duration(seconds: 60));
    expect(find.text(en.wasteAttentionTitle), findsOneWidget, reason: 'demo data has injected anomalies');
    await shot(tester, '15_waste');
    // Practical checks for the flagged months; one tap puts the fix on the action plan.
    final wasteList = find.descendant(of: find.byType(WasteView), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const Key('waste-plan-idle_machines')), 300, scrollable: wasteList);
    await shot(tester, '15b_waste_checks');
    await tapVisible(tester, find.byKey(const Key('waste-plan-idle_machines')));
    await pumpFor(tester, const Duration(seconds: 1));

    // Savings tab: the demo's air-leak fix (2024-09) is measured from later bills.
    await tester.tap(find.descendant(of: find.byType(TabBar), matching: find.text(en.tabImpact)));
    await pumpUntil(tester, find.byKey(const Key('impact-hero')));
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.textContaining(en.impactSince('').trim()), findsOneWidget, reason: 'demo action measured');
    await shot(tester, '15c_impact');
    final impactList = find.descendant(of: find.byType(ImpactView), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const Key('action-fix_air_leaks')), 300, scrollable: impactList);
    await shot(tester, '15d_action_plan');
    // The fix added from the checklist is on the plan (lists build lazily: scroll to it).
    await tester.scrollUntilVisible(find.byKey(const Key('action-switch_off_idle')), 300, scrollable: impactList);

    // PDF report bytes from the backend (the share sheet itself is a system screen).
    final container = ProviderScope.containerOf(tester.element(find.byType(HomeShell)));
    final pdf = await container.read(apiClientProvider).reportPdf(await container.read(exportServiceProvider).pdfRequest());
    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    expect(pdf.length, greaterThan(20000));

    // Solar estimate for a ~55 m x 51 m roof (NASA POWER irradiance).
    Navigator.of(tester.element(find.byType(HomeShell))).push(MaterialPageRoute<void>(
      builder: (_) => const SolarParamsScreen(polygon: [
        LatLon(23.99990, 90.42030),
        LatLon(23.99990, 90.42080),
        LatLon(24.00040, 90.42080),
        LatLon(24.00040, 90.42030),
      ]),
    ));
    await pumpUntil(tester, find.byType(SolarParamsScreen));
    await pumpFor(tester, const Duration(seconds: 2));
    await shot(tester, '16_solar_params');
    await tester.scrollUntilVisible(find.byKey(const Key('solar-estimate')), 300,
        scrollable: find.descendant(of: find.byType(SolarParamsScreen), matching: find.byType(Scrollable)).first);
    await tapVisible(tester, find.byKey(const Key('solar-estimate')));
    await pumpUntil(tester, find.byKey(const Key('solar-disclaimer')), timeout: const Duration(seconds: 90));
    await shot(tester, '17_solar_result');
    await tester.scrollUntilVisible(find.text(en.solarSavePlan), 300,
        scrollable: find.descendant(of: find.byType(SolarResultScreen), matching: find.byType(Scrollable)).first);
    await tapVisible(tester, find.text(en.solarSavePlan));
    await pumpUntil(tester, find.byType(AlertDialog));
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text(en.actionSave)));
    await pumpUntil(tester, find.byType(NavigationBar));
    await openTab(tester, en.navSolar);
    await pumpFor(tester, const Duration(seconds: 1));
    expect(await DriftSolarPlanRepository(db).watchAll().first, hasLength(1));
    await shot(tester, '18_solar_list');

    await openTab(tester, en.navSettings);
    await shot(tester, '19_settings');

    // Bangla.
    await openTab(tester, en.navHome);
    await tester.tap(find.byKey(const Key('language-toggle')));
    await pumpFor(tester, const Duration(seconds: 1));
    final bn = lookupAppLocalizations(const Locale('bn'));
    expect(find.text(bn.navHome), findsWidgets);
    await shot(tester, '20_home_bn');
    await openTab(tester, bn.navReports);
    await shot(tester, '21_reports_bn');
    await openTab(tester, bn.navBills);
    await shot(tester, '22_bills_bn');

    await tester.pumpWidget(const SizedBox());
    await pumpFor(tester, const Duration(seconds: 1));
    await db.close();
  });
}
