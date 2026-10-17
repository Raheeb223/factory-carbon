import 'dart:io';

import 'package:dio/dio.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/features/solar/place_finder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// A 100 m x 100 m roof around (23.8, 90.4), as Overpass returns it (closed ring).
Map<String, dynamic> _overpassRoof() => {
      'elements': [
        {
          'type': 'way',
          'geometry': [
            for (final (lat, lon) in [(23.7995, 90.3995), (23.7995, 90.4005), (23.8005, 90.4005), (23.8005, 90.3995), (23.7995, 90.3995)]) {'lat': lat, 'lon': lon},
          ],
        },
      ],
    };

void main() {
  test('a roof found once is answered from the phone when Overpass is down', () async {
    final dir = await Directory.systemTemp.createTemp('fc_outlines');
    addTearDown(() => dir.delete(recursive: true));
    Future<File> file() async => File('${dir.path}/outlines.json');

    var serversUp = true;
    final adapter = FakeAdapter((o) => serversUp ? jsonBody(_overpassRoof()) : jsonBody({'error': 'busy'}, status: 504));
    OsmPlaceFinder finder() => OsmPlaceFinder(dio: Dio()..httpClientAdapter = adapter, cache: BuildingCache(file: file));

    const tap = LatLon(23.8, 90.4);
    expect(await finder().buildingAt(tap), hasLength(4));
    await Future<void>.delayed(const Duration(milliseconds: 50)); // cache write

    serversUp = false;
    adapter.requests.clear();
    // A new finder (as after an app restart) reads the saved file; a tap 30 m away hits it.
    expect(await finder().buildingAt(const LatLon(23.8003, 90.4)), hasLength(4));
    expect(adapter.requests, isEmpty);
  });

  test('cached lookups are only reused inside the area they covered', () {
    expect(BuildingCache.reuseWithinM, lessThan(150), reason: 'must stay inside the 150 m lookup radius');
  });
}
