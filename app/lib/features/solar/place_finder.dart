import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/providers.dart';
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
  OsmPlaceFinder({Dio? dio, BuildingCache? cache, this.footprints})
      : _cache = cache ?? BuildingCache(),
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'User-Agent': 'BillToGreen/0.1 (factory rooftop solar pre-feasibility app)'},
            ));

  final Dio _dio;
  final BuildingCache _cache;

  /// Building outlines from the app's server (Overture Maps), tried before Overpass:
  /// it also has Google and Microsoft footprints, so far more Bangladeshi roofs are covered.
  final Future<List<List<LatLon>>> Function(LatLon at)? footprints;

  /// The whole outline lookup gives up after this, so the user can tap the corners instead
  /// of waiting on overloaded public servers.
  static const outlineBudget = Duration(seconds: 12);

  /// Time allowed for the app's server before falling back to Overpass (its first lookup in
  /// a new area reads a few map tiles from Overture).
  static const serverBudget = Duration(seconds: 20);

  /// Public Overpass mirrors are often overloaded (504) or reject POST, so the same GET query
  /// goes to several at once and the first good answer wins.
  /// Checked 2026-10-17: often only one of them answers, so keep several.
  static const _overpass = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
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
    // Outlines fetched before are kept on the phone, so a roof found once still works
    // when the Overpass servers are down (or there is no internet).
    final cached = await _cache.near(tap);
    final fromCache = cached == null ? null : pickBuilding(cached, tap);
    if (fromCache != null) return fromCache;

    if (footprints != null) {
      List<List<LatLon>>? outlines;
      try {
        outlines = await footprints!(tap).timeout(serverBudget);
      } catch (_) {
        // server asleep or offline: fall back to OpenStreetMap's Overpass below
      }
      if (outlines != null) {
        // Overture already includes OpenStreetMap, so its answer is final.
        unawaited(_cache.add(tap, outlines));
        return pickBuilding(outlines, tap);
      }
    }

    // "around" measures distance to a building's outline, so a wide radius is needed for a
    // tap in the middle of a big shed; the containing outline is then chosen locally.
    final query = '[out:json][timeout:10];way["building"](around:150,${tap.lat},${tap.lon});out geom;';
    final deadline = DateTime.now().add(outlineBudget);
    Future<List<List<LatLon>>> round() => _firstSuccess([for (final url in _overpass) () => _outlines(url, query)]).timeout(deadline.difference(DateTime.now()));
    List<List<LatLon>> outlines;
    try {
      outlines = await round();
    } on TimeoutException {
      rethrow;
    } catch (_) {
      // busy mirrors usually free a slot within seconds; retry only while time is left
      if (deadline.difference(DateTime.now()) < const Duration(seconds: 5)) rethrow;
      await Future<void>.delayed(const Duration(seconds: 2));
      outlines = await round();
    }
    unawaited(_cache.add(tap, outlines));
    return pickBuilding(outlines, tap);
  }

  Future<List<List<LatLon>>> _outlines(String url, String query) async {
    final res = await _dio.get<Map<String, dynamic>>(
      url,
      queryParameters: {'data': query},
      options: Options(receiveTimeout: const Duration(seconds: 10)),
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

/// Building outlines already downloaded, saved in a small JSON file on the phone.
class BuildingCache {
  BuildingCache({Future<File> Function()? file}) : _file = file ?? _defaultFile;

  final Future<File> Function() _file;
  List<({LatLon at, List<List<LatLon>> outlines})>? _entries;

  /// Areas kept; each is one 150 m lookup, a few kB.
  static const maxEntries = 40;

  /// A tap this close to an earlier lookup is answered from it (the lookup covers 150 m).
  static const reuseWithinM = 100.0;

  static Future<File> _defaultFile() async => File('${(await getApplicationSupportDirectory()).path}/building_outlines.json');

  Future<List<({LatLon at, List<List<LatLon>> outlines})>> _load() async {
    if (_entries != null) return _entries!;
    try {
      final f = await _file();
      final raw = await f.exists() ? jsonDecode(await f.readAsString()) as List<dynamic> : const [];
      LatLon pt(dynamic p) => LatLon(((p as List<dynamic>)[0] as num).toDouble(), (p[1] as num).toDouble());
      _entries = [
        for (final e in raw.cast<Map<String, dynamic>>())
          (at: pt(e['at']), outlines: [for (final o in e['outlines'] as List<dynamic>) [for (final p in o as List<dynamic>) pt(p)]]),
      ];
    } catch (_) {
      _entries = [];
    }
    return _entries!;
  }

  Future<List<List<LatLon>>?> near(LatLon tap) async {
    for (final e in (await _load()).reversed) {
      if (distanceM(e.at, tap) <= reuseWithinM) return e.outlines;
    }
    return null;
  }

  Future<void> add(LatLon at, List<List<LatLon>> outlines) async {
    if (outlines.isEmpty) return;
    final entries = await _load()
      ..add((at: at, outlines: outlines));
    if (entries.length > maxEntries) entries.removeRange(0, entries.length - maxEntries);
    try {
      List<double> pt(LatLon p) => [p.lat, p.lon];
      await (await _file()).writeAsString(jsonEncode([
        for (final e in entries) {'at': pt(e.at), 'outlines': [for (final o in e.outlines) [for (final p in o) pt(p)]]},
      ]));
    } catch (_) {
      // the cache is only a convenience
    }
  }
}

final placeFinderProvider = Provider<PlaceFinder>(
  (ref) => OsmPlaceFinder(footprints: (at) => ref.read(apiClientProvider).buildingsNear(at, timeout: OsmPlaceFinder.serverBudget)),
);
