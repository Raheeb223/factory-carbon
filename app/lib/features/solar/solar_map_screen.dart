import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/geo.dart';
import '../../domain/models.dart' as m;
import '../../widgets/common.dart';
import 'place_finder.dart';
import 'solar_params_screen.dart';

const _dhaka = LatLng(23.8103, 90.4125);

/// Below this zoom a tap is too coarse to pick a roof, so it zooms in instead.
const _roofZoom = 16.0;

/// Find the factory (search, GPS or saved location), then tap the roof: the OSM building
/// outline is used when there is one, otherwise the user taps the corners (spec 8.7).
/// Satellite imagery is offered (and shown first, as roofs are easier to trace on it)
/// when a provider is configured via --dart-define (ARCGIS_API_KEY or SATELLITE_TILE_URL).
class SolarMapScreen extends ConsumerStatefulWidget {
  const SolarMapScreen({super.key, this.plan, this.finder});
  final m.SolarPlan? plan;

  /// Overrides [placeFinderProvider] (tests).
  final PlaceFinder? finder;

  @override
  ConsumerState<SolarMapScreen> createState() => _SolarMapScreenState();
}

class _SolarMapScreenState extends ConsumerState<SolarMapScreen> {
  late final List<LatLng> _points = [for (final p in widget.plan?.polygon ?? const <m.LatLon>[]) LatLng(p.lat, p.lon)];
  final List<List<LatLng>> _history = [];
  late bool _satellite = ref.read(appConfigProvider).hasSatellite;
  final _map = MapController();
  final _query = TextEditingController();
  List<Place>? _results;
  String? _busyText;
  LatLng? _gps;

  PlaceFinder get _finder => widget.finder ?? ref.read(placeFinderProvider);

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _change(void Function() edit) => setState(() {
        _history.add(List.of(_points));
        edit();
      });

  void _fit(List<LatLng> pts, {double maxZoom = 19}) {
    if (pts.length == 1) {
      _map.move(pts.first, maxZoom);
      return;
    }
    _map.fitCamera(CameraFit.bounds(bounds: LatLngBounds.fromPoints(pts), padding: const EdgeInsets.all(48), maxZoom: maxZoom));
  }

  Future<T?> _busy<T>(String text, Future<T> Function() work) async {
    setState(() => _busyText = text);
    try {
      return await work();
    } finally {
      if (mounted) setState(() => _busyText = null);
    }
  }

  Future<void> _search(AppLocalizations l) async {
    final text = _query.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    final coords = parseLatLon(text);
    if (coords != null) {
      setState(() => _results = null);
      _map.move(LatLng(coords.lat, coords.lon), 18);
      return;
    }
    try {
      final found = await _busy(l.solarSearching, () => _finder.search(text, language: l.localeName));
      if (!mounted) return;
      setState(() => _results = found);
      if (found!.isEmpty) showSnack(context, l.solarSearchNone);
    } catch (_) {
      if (mounted) showSnack(context, l.solarSearchFailed);
    }
  }

  void _goTo(Place p) {
    setState(() => _results = null);
    if (p.hasBounds) {
      _fit([LatLng(p.south!, p.west!), LatLng(p.north!, p.east!)], maxZoom: 18);
    } else {
      _map.move(LatLng(p.at.lat, p.at.lon), 17);
    }
  }

  Future<void> _locate(AppLocalizations l) async {
    try {
      final here = await _busy(l.solarGpsFinding, _finder.myLocation);
      if (!mounted || here == null) return;
      setState(() => _gps = LatLng(here.lat, here.lon));
      _map.move(_gps!, 18);
    } on GpsException catch (e) {
      if (!mounted) return;
      showSnack(context, switch (e.problem) {
        GpsProblem.off => l.solarGpsOff,
        GpsProblem.denied => l.solarGpsDenied,
        GpsProblem.failed => l.solarGpsFailed,
      });
    }
  }

  Future<void> _onTap(AppLocalizations l, LatLng p) async {
    if (_busyText != null) return;
    setState(() => _results = null);
    if (_points.isNotEmpty) {
      _change(() => _points.add(p));
      return;
    }
    if (_map.camera.zoom < _roofZoom) {
      _map.move(p, 18);
      showSnack(context, l.solarZoomedIn);
      return;
    }
    List<m.LatLon>? outline;
    var failed = false;
    try {
      outline = await _busy<List<m.LatLon>?>(l.solarFindingRoof, () => _finder.buildingAt(m.LatLon(p.latitude, p.longitude)));
    } catch (_) {
      failed = true;
    }
    if (!mounted) return;
    if (outline != null) {
      final pts = [for (final o in outline) LatLng(o.lat, o.lon)];
      _change(() => _points.addAll(pts));
      _fit(pts);
      showSnack(context, l.solarOutlineFound);
    } else {
      _change(() => _points.add(p));
      showSnack(context, failed ? l.solarOutlineOffline : l.solarOutlineNone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final config = ref.watch(appConfigProvider);
    final profile = ref.watch(factoryProvider).value;
    final hasFactoryPos = profile?.lat != null && profile?.lon != null;
    final center = _points.isNotEmpty
        ? LatLng(
            _points.map((p) => p.latitude).reduce((a, b) => a + b) / _points.length,
            _points.map((p) => p.longitude).reduce((a, b) => a + b) / _points.length,
          )
        : (hasFactoryPos ? LatLng(profile!.lat!, profile.lon!) : _dhaka);
    final zoom = _points.isNotEmpty || hasFactoryPos ? 18.0 : 12.0;
    final useSatellite = _satellite && config.hasSatellite;
    final scheme = Theme.of(context).colorScheme;
    final area = polygonAreaM2([for (final p in _points) m.LatLon(p.latitude, p.longitude)]);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan?.name ?? l.solarNewPlan),
        actions: [
          if (config.hasSatellite)
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l.solarLayerStreet)),
                ButtonSegment(value: true, label: Text(l.solarLayerSatellite)),
              ],
              selected: {useSatellite},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _satellite = s.first),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const Key('place-search'),
                  controller: _query,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(l),
                  decoration: InputDecoration(
                    hintText: l.solarSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      key: const Key('place-search-go'),
                      tooltip: l.solarSearchHint,
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => _search(l),
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                Text(l.solarDrawHint, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: zoom,
                    maxZoom: 20,
                    onTap: (_, point) => _onTap(l, point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: useSatellite ? config.satelliteTileUrl : config.mapTileUrl,
                      userAgentPackageName: config.userAgentPackageName,
                      maxNativeZoom: 19,
                    ),
                    if (_points.length >= 3)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _points,
                            color: scheme.primary.withValues(alpha: 0.3),
                            borderColor: scheme.primary,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      )
                    else if (_points.length == 2)
                      PolylineLayer(
                        polylines: [Polyline(points: _points, color: scheme.primary, strokeWidth: 2)],
                      ),
                    MarkerLayer(
                      markers: [
                        if (_gps != null)
                          Marker(
                            point: _gps!,
                            width: 22,
                            height: 22,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        for (final p in _points)
                          Marker(
                            point: p,
                            width: 14,
                            height: 14,
                            child: Container(
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SimpleAttributionWidget(
                      source: Text(
                        useSatellite ? config.satelliteTileAttribution : config.mapTileAttribution,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        key: const Key('map-gps'),
                        heroTag: 'gps',
                        tooltip: l.solarGps,
                        onPressed: _busyText != null ? null : () => _locate(l),
                        child: const Icon(Icons.my_location),
                      ),
                      if (hasFactoryPos) ...[
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'factory',
                          tooltip: l.solarMyLocation,
                          onPressed: () => _map.move(LatLng(profile!.lat!, profile.lon!), 18),
                          child: const Icon(Icons.factory_outlined),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_results != null && _results!.isNotEmpty)
                  Positioned(
                    left: 8,
                    right: 64,
                    top: 8,
                    child: Card(
                      key: const Key('place-results'),
                      clipBehavior: Clip.antiAlias,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          children: [
                            for (final p in _results!)
                              ListTile(
                                dense: true,
                                leading: const Icon(Icons.place_outlined),
                                title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                                onTap: () => _goTo(p),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_busyText != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            const SizedBox(width: 10),
                            Text(_busyText!),
                          ]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.solarPoints(_points.length)),
                        if (area > 0)
                          Text(l.solarAreaApprox(fmt.number(area)),
                              key: const Key('roof-area'), style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l.actionUndo,
                    onPressed: _history.isEmpty ? null : () => setState(() => _points..clear()..addAll(_history.removeLast())),
                    icon: const Icon(Icons.undo),
                  ),
                  IconButton(
                    tooltip: l.actionClear,
                    onPressed: _points.isEmpty ? null : () => _change(_points.clear),
                    icon: const Icon(Icons.delete_sweep_outlined),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (_points.length < 3) {
                        showSnack(context, l.solarNeedPoints);
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              SolarParamsScreen(polygon: [for (final p in _points) m.LatLon(p.latitude, p.longitude)], plan: widget.plan),
                        ),
                      );
                    },
                    child: Text(l.actionContinue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
