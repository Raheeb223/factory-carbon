import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/geo.dart';
import '../../domain/models.dart';

/// A search hit. [south]/[north]/[west]/[east] frame the place when known (an area, not a point).
class Place {
  const Place({required this.name, required this.at, this.south, this.north, this.west, this.east});
  final String name;
  final LatLon at;
  final double? south, north, west, east;
  bool get hasBounds => south != null && north != null && west != null && east != null;
}

enum GpsProblem { off, denied, failed }

class GpsException implements Exception {
  const GpsException(this.problem);
  final GpsProblem problem;
}

/// Helps the user find their roof: place search, GPS position and OSM building outlines.
abstract interface class PlaceFinder {
  Future<List<Place>> search(String query, {required String language});

  /// Outline of the building under [tap], or null when the map has none there.
  Future<List<LatLon>?> buildingAt(LatLon tap);

  /// Current phone position; throws [GpsException].
  Future<LatLon> myLocation();
}

/// OpenStreetMap services: Nominatim for search (one request per user action, as its usage
/// policy requires; no search-as-you-type) and Overpass for building footprints.
class OsmPlaceFinder implements PlaceFinder {
  OsmPlaceFinder({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'User-Agent': 'BillToGreen/0.1 (factory rooftop solar pre-feasibility app)'},
            ));

  final Dio _dio;

  /// Public Overpass mirrors are often overloaded (504) or reject POST, so the same GET query
  /// goes to several at once and the first good answer wins.
  static const _overpass = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
  ];

  @override
  Future<List<Place>> search(String query, {required String language}) async {
    final res = await _dio.get<List<dynamic>>('https://nominatim.openstreetmap.org/search', queryParameters: {
      'q': query,
      'format': 'jsonv2',
      'countrycodes': 'bd',
      'limit': 8,
      'accept-language': '$language,en',
    });
    return [
      for (final e in res.data ?? const [])
        if (e is Map<String, dynamic>) _place(e),
    ];
  }

  static Place _place(Map<String, dynamic> e) {
    final box = (e['boundingbox'] as List<dynamic>?)?.map((v) => double.tryParse('$v')).toList();
    final ok = box != null && box.length == 4 && box.every((v) => v != null);
    return Place(
      name: e['display_name'] as String? ?? '',
      at: LatLon(double.parse('${e['lat']}'), double.parse('${e['lon']}')),
      south: ok ? box[0] : null,
      north: ok ? box[1] : null,
      west: ok ? box[2] : null,
      east: ok ? box[3] : null,
    );
  }

  @override
  Future<List<LatLon>?> buildingAt(LatLon tap) async {
    // "around" measures distance to a building's outline, so a wide radius is needed for a
    // tap in the middle of a big shed; the containing outline is then chosen locally.
    final query = '[out:json][timeout:15];way["building"](around:150,${tap.lat},${tap.lon});out geom;';
    List<List<LatLon>> outlines;
    try {
      outlines = await _firstSuccess([for (final url in _overpass) () => _outlines(url, query)]);
    } catch (_) {
      // busy mirrors usually free a slot within seconds
      await Future<void>.delayed(const Duration(seconds: 3));
      outlines = await _firstSuccess([for (final url in _overpass) () => _outlines(url, query)]);
    }
    return pickBuilding(outlines, tap);
  }

  Future<List<List<LatLon>>> _outlines(String url, String query) async {
    final res = await _dio.get<Map<String, dynamic>>(
      url,
      queryParameters: {'data': query},
      options: Options(receiveTimeout: const Duration(seconds: 20)),
    );
    final elements = res.data?['elements'];
    if (elements is! List) throw const FormatException('no elements');
    return [
      for (final el in elements)
        if (el is Map<String, dynamic> && el['geometry'] is List)
          [
            for (final g in el['geometry'] as List<dynamic>)
              LatLon(((g as Map<String, dynamic>)['lat'] as num).toDouble(), (g['lon'] as num).toDouble()),
          ],
    ];
  }

  /// Runs all [tries] together; completes with the first success, or the last error if all fail.
  static Future<T> _firstSuccess<T>(List<Future<T> Function()> tries) {
    final done = Completer<T>();
    var failed = 0;
    for (final t in tries) {
      t().then((v) {
        if (!done.isCompleted) done.complete(v);
      }, onError: (Object e, StackTrace st) {
        if (++failed == tries.length && !done.isCompleted) done.completeError(e, st);
      });
    }
    return done.future;
  }

  @override
  Future<LatLon> myLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) throw const GpsException(GpsProblem.off);
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw const GpsException(GpsProblem.denied);
    }
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 25)),
      );
      return LatLon(p.latitude, p.longitude);
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return LatLon(last.latitude, last.longitude);
      throw const GpsException(GpsProblem.failed);
    }
  }
}

final placeFinderProvider = Provider<PlaceFinder>((ref) => OsmPlaceFinder());
