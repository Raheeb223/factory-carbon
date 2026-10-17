import 'dart:io';

import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/domain/geo.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/features/solar/place_finder.dart';
import 'package:factory_carbon/features/solar/solar_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const _factory = LatLon(23.8, 90.4);

List<LatLon> _square(LatLon c, double half) => [
      LatLon(c.lat - half, c.lon - half),
      LatLon(c.lat - half, c.lon + half),
      LatLon(c.lat + half, c.lon + half),
      LatLon(c.lat + half, c.lon - half),
    ];

/// The factory's roof is a ~65 m square; any tap outside it finds a smaller roof around the tap.
class _Finder implements PlaceFinder {
  final taps = <LatLon>[];
  @override
  Future<List<Place>> search(String query, {required String language}) async => const [];
  @override
  Future<List<LatLon>?> buildingAt(LatLon tap) async {
    taps.add(tap);
    final roof = _square(_factory, 0.0003);
    return containsPoint(roof, tap) ? roof : _square(tap, 0.0001);
  }

  @override
  Future<LatLon> myLocation() async => _factory;
}

FactoryProfile _profile() => FactoryProfile(
      id: 'factory-1',
      name: 'Test Garments',
      location: 'Gazipur',
      lat: _factory.lat,
      lon: _factory.lon,
      productionUnitLabel: 'pieces',
      privacyAcknowledgedAt: DateTime(2026, 1, 1),
    );

Future<_Finder> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // the map's tile cache asks for a cache folder
  final cache = Directory.systemTemp.createTempSync('fc_tiles');
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (_) async => cache.path);
  addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
  final db = memoryDb();
  addTearDown(() => teardownDb(tester, db));
  await tester.runAsync(() => DriftFactoryRepository(db).save(_profile()));
  final finder = _Finder();
  await tester.pumpWidget(testApp(SolarMapScreen(finder: finder), overrides: testOverrides(db: db)));
  await settle(tester);
  return finder;
}

/// Unmounts and lets the snack bar and tile timers finish.
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 10));
}

String _area(WidgetTester tester) => tester.widget<Text>(find.byKey(const Key('roof-area'))).data!;

void main() {
  testWidgets('a new plan starts with the roof at the factory location marked', (tester) async {
    final finder = await _open(tester);
    expect(finder.taps.single.lat, _factory.lat);
    expect(find.byKey(const Key('roof-corner-3')), findsOneWidget);
    expect(find.byKey(const Key('roof-corner-4')), findsNothing);
    expect(find.textContaining('We marked the roof'), findsOneWidget);
    expect(find.textContaining('Overture Maps'), findsOneWidget, reason: 'outline source is credited');
    await _close(tester);
  });

  testWidgets('corners can be dragged, added and removed, and undone', (tester) async {
    await _open(tester);
    final before = _area(tester);

    await tester.drag(find.byKey(const Key('roof-corner-2')), const Offset(60, -60));
    await settle(tester);
    expect(_area(tester), isNot(before), reason: 'dragging a corner outwards changes the area');

    await tester.tap(find.byKey(const Key('roof-add-0')));
    await settle(tester);
    expect(find.byKey(const Key('roof-corner-4')), findsOneWidget);

    await tester.longPress(find.byKey(const Key('roof-corner-1')));
    await settle(tester);
    expect(find.byKey(const Key('roof-corner-4')), findsNothing);

    await tester.tap(find.byTooltip('Undo'));
    await settle(tester);
    expect(find.byKey(const Key('roof-corner-4')), findsOneWidget);
    await _close(tester);
  });

  testWidgets('tapping outside the marked roof switches to the roof there', (tester) async {
    final finder = await _open(tester);
    final before = _area(tester);
    final corner = tester.getRect(find.byKey(const Key('roof-corner-3'))); // top-left
    // just inside the left edge of the screen, outside the fitted roof (56 px side padding)
    await tester.tapAt(Offset(8, corner.center.dy));
    await settle(tester);
    expect(finder.taps, hasLength(2));
    expect(_area(tester), isNot(before), reason: 'the smaller roof there replaced the factory roof');
    expect(find.byKey(const Key('roof-corner-3')), findsOneWidget);
    await _close(tester);
  });
}
