import 'package:factory_carbon/data/backup.dart';
import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/data/providers.dart';
import 'package:factory_carbon/data/settings_store.dart';
import 'package:factory_carbon/domain/carbon_summary.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/domain/report_period.dart';
import 'package:factory_carbon/features/carbon/carbon_controller.dart';
import 'package:factory_carbon/features/onboarding/onboarding_screen.dart';
import 'package:factory_carbon/features/solar/place_finder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

class _FakeFinder implements PlaceFinder {
  _FakeFinder(this.here);
  final LatLon here;
  @override
  Future<List<Place>> search(String query, {required String language}) async => const [];
  @override
  Future<List<LatLon>?> buildingAt(LatLon tap) async => null;
  @override
  Future<LatLon> myLocation() async => here;
}

FactoryProfile _profile({Set<String>? sources, String? reportingYear}) => FactoryProfile(
      id: 'f',
      name: 'X',
      location: '',
      lat: null,
      lon: null,
      productionUnitLabel: 'pieces',
      privacyAcknowledgedAt: DateTime(2026),
      energySources: sources,
      reportingYear: reportingYear,
    );

Future<void> _next(WidgetTester tester) async {
  await tapScrolled(tester, find.byKey(const Key('onboarding-next')));
  await settle(tester);
}

void main() {
  test('Bangladesh bounds catch swapped or mistyped coordinates', () {
    expect(insideBangladesh(23.81, 90.41), isTrue); // Dhaka
    expect(insideBangladesh(22.33, 91.83), isTrue); // Chattogram
    expect(insideBangladesh(90.41, 23.81), isFalse); // swapped
    expect(insideBangladesh(2.381, 90.41), isFalse); // missing digit
  });

  test('suggestions fit the energy the factory uses', () {
    final gridOnly = _profile(sources: {'electricity'});
    expect(actionFits('generator_hours', gridOnly), isFalse);
    expect(actionFits('steam_leaks', gridOnly), isFalse);
    expect(actionFits('led_lighting', gridOnly), isTrue);
    expect(actionFits('steam_leaks', _profile(sources: {'electricity', 'lpg'})), isTrue);
    expect(actionFits('rooftop_solar', _profile(sources: {'electricity', 'solar'})), isFalse);
    expect(actionFits('generator_hours', _profile()), isTrue, reason: 'not answered: show everything');
    expect(actionFits('generator_hours', null), isTrue);
  });

  test('profile details survive save, load and a backup', () async {
    final db = memoryDb();
    final full = FactoryProfile(
      id: 'f1',
      name: 'Rahman Knit',
      location: 'Konabari',
      lat: 24.0,
      lon: 90.3,
      productionUnitLabel: 'pieces',
      privacyAcknowledgedAt: DateTime(2026),
      facilityType: 'knit',
      district: 'gazipur',
      workers: 1200,
      shiftsPerDay: 2,
      energySources: const {'electricity', 'gas', 'diesel'},
      reportingYear: 'fiscal',
    );
    await DriftFactoryRepository(db).save(full);
    final parsed = parseBackup(await buildBackup(db));
    final dst = memoryDb();
    await restoreBackup(dst, parsed);
    for (final p in [await DriftFactoryRepository(db).get(), await DriftFactoryRepository(dst).get()]) {
      expect(p!.facilityType, 'knit');
      expect(p.district, 'gazipur');
      expect(p.workers, 1200);
      expect(p.shiftsPerDay, 2);
      expect(p.energySources, {'electricity', 'gas', 'diesel'});
      expect(p.reportingYear, 'fiscal');
    }
    await db.close();
    await dst.close();
  });

  test('older backups without the new fields still restore', () {
    const old = '{"format":"$backupFormat","version":1,"created_at":"2026-01-01T00:00:00Z","factory_profiles":[{"id":"f","createdAt":0,"updatedAt":0,"deleted":false,"name":"Old","location":"","lat":null,"lon":null,"productionUnitLabel":"pieces","privacyAcknowledgedAt":0}]}';
    final p = parseBackup(old).profiles.single;
    expect(p.name, 'Old');
    expect(p.energySources, isNull);
  });

  test('the report opens on the latest year of the kind chosen in setup', () async {
    final db = memoryDb();
    await DriftFactoryRepository(db).save(_profile(reportingYear: 'fiscal'));
    await DriftBillRepository(db).save(testBill(id: 'a', month: '2025-08'));
    addTearDown(db.close);
    final container = ProviderContainer(overrides: testOverrides(db: db));
    addTearDown(container.dispose); // runs first: stops drift streams before the DB closes
    container.listen(factoryProvider, (_, _) {});
    container.listen(billsProvider, (_, _) {});
    await container.read(factoryProvider.future).timeout(const Duration(seconds: 5), onTimeout: () => throw 'factory');
    await container.read(billsProvider.future).timeout(const Duration(seconds: 5), onTimeout: () => throw 'bills');
    expect(container.read(reportPeriodProvider), const ReportPeriod.fiscal(2025));
    await container.read(reportPeriodProvider.notifier).set(const ReportPeriod.all());
    expect((container.read(settingsStoreProvider) as MemorySettingsStore).reportPeriod, 'all');
    container.invalidate(reportPeriodProvider);
    expect(container.read(reportPeriodProvider), const ReportPeriod.all(), reason: 'a choice the user made is kept');
  });

  testWidgets('setup: GPS fills the location, energy sources and details are saved', (tester) async {
    final db = memoryDb();
    await tester.pumpWidget(testApp(
      OnboardingScreen(finder: _FakeFinder(const LatLon(23.99951, 90.42031))),
      overrides: testOverrides(db: db),
    ));
    await waitFor(tester, find.byKey(const Key('intro-skip')));
    await tester.tap(find.byKey(const Key('intro-skip')));
    await settle(tester);

    // Step 1: the name is required.
    await _next(tester);
    expect(find.text('Step 1 of 4'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('factory-name')), 'Rahman Knit');
    await tapScrolled(tester, find.byKey(const Key('facility-knit')));
    await _next(tester);

    // Step 2: location from GPS.
    expect(find.text('Step 2 of 4'), findsOneWidget);
    await tapScrolled(tester, find.byKey(const Key('loc-gps')));
    await settle(tester);
    expect(find.text('Location set: 23.99951, 90.42031'), findsOneWidget);
    await _next(tester);

    // Step 3: workforce, then at least one energy source.
    await tester.enterText(find.byKey(const Key('workers')), '1200');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 200));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('shifts-2')));
    await tester.pump();
    await tapScrolled(tester, find.byKey(const Key('source-electricity')));
    await _next(tester);
    expect(find.byKey(const Key('sources-error')), findsOneWidget);
    await tapScrolled(tester, find.byKey(const Key('source-electricity')));
    await tapScrolled(tester, find.byKey(const Key('source-diesel')));
    await _next(tester);

    // Step 4: review + privacy.
    await tapScrolled(tester, find.byKey(const Key('privacy-ack')));
    await tapScrolled(tester, find.byKey(const Key('onboarding-save')));
    await settle(tester);

    final p = (await tester.runAsync(() => DriftFactoryRepository(db).get()))!;
    expect(p.name, 'Rahman Knit');
    expect(p.facilityType, 'knit');
    expect(p.lat, closeTo(23.99951, 1e-6));
    expect(p.energySources, {'electricity', 'diesel'});
    expect(p.workers, 1200);
    expect(p.shiftsPerDay, 2);
    expect(p.reportingYear, 'calendar');
    await teardownDb(tester, db);
  });

  testWidgets('setup: a pasted Google Maps link sets the location; a point outside Bangladesh is refused', (tester) async {
    final db = memoryDb();
    await tester.pumpWidget(testApp(OnboardingScreen(existing: _profile()), overrides: testOverrides(db: db)));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('loc-paste')), 'https://www.google.com/maps/@23.8103,90.4125,17z');
    await tapScrolled(tester, find.byKey(const Key('loc-paste-go')));
    await settle(tester);
    expect(find.text('Location set: 23.81030, 90.41250'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('loc-paste')), '27.7172, 85.3240');
    await tapScrolled(tester, find.byKey(const Key('loc-paste-go')));
    await settle(tester);
    expect(find.byKey(const Key('loc-error')), findsOneWidget);
    await tapScrolled(tester, find.byKey(const Key('onboarding-save')));
    await settle(tester);
    expect(await tester.runAsync(() => DriftFactoryRepository(db).get()), isNull, reason: 'not saved with a bad location');
    await teardownDb(tester, db);
  });
}
