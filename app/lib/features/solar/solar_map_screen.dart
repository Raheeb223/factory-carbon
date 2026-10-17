import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/geo.dart';
import '../../domain/models.dart' as m;
import 'place_finder.dart';
import 'solar_params_screen.dart';

const _dhaka = LatLng(23.8103, 90.4125);

/// Below this zoom a tap is too coarse to pick a roof, so it zooms in instead.
const _roofZoom = 16.0;

/// Find the factory (search, GPS or saved location), then tap the roof: the building outline
/// (Overture Maps: OpenStreetMap + Google/Microsoft footprints) is used when there is one,
/// otherwise the user taps the corners (spec 8.7). A new plan starts with the roof at the
/// factory's saved location already marked. Corners can be dragged, added (+ on an edge)
/// and removed (long-press).
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

  /// The corners came from a building outline, not tapped one by one: a tap elsewhere then
  /// switches to the roof there instead of adding a corner.
  late bool _fromOutline = _points.isNotEmpty;

  /// Corner being dragged, and its current screen position.
  int? _dragIndex;
  Offset? _dragAt;
  var _dragMoved = false;

  /// The corner and + handles sit above the map (not inside it), so touching one never pans
  /// or taps the map; they are placed from the map camera once the map is ready.
  var _mapReady = false;

  /// Hint shown over the top of the map for a few seconds. Unlike a snack bar it lets touches
  /// through, so it never blocks a corner or the buttons.
  String? _message;
  Timer? _messageTimer;

  void _say(String text) {
    _messageTimer?.cancel();
    setState(() => _message = text);
    _messageTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _message = null);
    });
  }

  @override
  void initState() {
    super.initState();
    if (_points.isEmpty) WidgetsBinding.instance.addPostFrameCallback((_) => _suggestAtFactory());
  }

  PlaceFinder get _finder => widget.finder ?? ref.read(placeFinderProvider);

  @override
  void dispose() {
    _messageTimer?.cancel();
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
    // room at the top for the hint banner
    _map.fitCamera(CameraFit.bounds(bounds: LatLngBounds.fromPoints(pts), padding: const EdgeInsets.fromLTRB(56, 96, 56, 56), maxZoom: maxZoom));
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
      if (found!.isEmpty) _say(l.solarSearchNone);
    } catch (_) {
      if (mounted) _say(l.solarSearchFailed);
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

  /// A new plan starts with the roof at the factory's saved location marked, if the map has it.
  Future<void> _suggestAtFactory() async {
    final profile = await ref.read(factoryProvider.future);
    if (!mounted || profile?.lat == null || profile?.lon == null) return;
    await _suggest(LatLng(profile!.lat!, profile.lon!));
  }

  Future<void> _suggest(LatLng p) async {
    if (_points.isNotEmpty || _busyText != null) return;
    final l = AppLocalizations.of(context);
    final (outline, _) = await _lookup(l, p);
    if (!mounted || outline == null || _points.isNotEmpty) return;
    _useOutline(outline);
    _say(l.solarSuggested);
  }

  /// The building outline at [p]; the flag is true when the lookup failed (offline).
  Future<(List<LatLng>?, bool)> _lookup(AppLocalizations l, LatLng p) async {
    try {
      final o = await _busy<List<m.LatLon>?>(l.solarFindingRoof, () => _finder.buildingAt(m.LatLon(p.latitude, p.longitude)));
      return (o == null ? null : [for (final x in o) LatLng(x.lat, x.lon)], false);
    } catch (_) {
      return (null, true);
    }
  }

  void _useOutline(List<LatLng> pts) {
    _change(() => _points
      ..clear()
      ..addAll(pts));
    _fromOutline = true;
    _fit(pts);
  }

  void _clear() {
    _change(_points.clear);
    _fromOutline = false;
  }

  void _startDrag(int i) => setState(() {
        _dragIndex = i;
        _dragMoved = false;
        _dragAt = _map.camera.latLngToScreenOffset(_points[i]);
      });

  void _drag(Offset delta) {
    final i = _dragIndex;
    if (i == null || i >= _points.length || delta == Offset.zero) return;
    if (!_dragMoved) {
      _history.add(List.of(_points)); // one undo step per drag
      _dragMoved = true;
    }
    _dragAt = _dragAt! + delta;
    setState(() => _points[i] = _map.camera.screenOffsetToLatLng(_dragAt!));
  }

  void _endDrag() => setState(() => _dragIndex = null);

  Future<void> _locate(AppLocalizations l) async {
    try {
      final here = await _busy(l.solarGpsFinding, _finder.myLocation);
      if (!mounted || here == null) return;
      setState(() => _gps = LatLng(here.lat, here.lon));
      _map.move(_gps!, 18);
      await _suggest(_gps!);
    } on GpsException catch (e) {
      if (!mounted) return;
      _say(switch (e.problem) {
        GpsProblem.off => l.solarGpsOff,
        GpsProblem.denied => l.solarGpsDenied,
        GpsProblem.failed => l.solarGpsFailed,
      });
    }
  }

  Future<void> _onTap(AppLocalizations l, LatLng p) async {
    if (_busyText != null || _dragIndex != null) return;
    setState(() => _results = null);
    if (_points.isNotEmpty && !_fromOutline) {
      _change(() => _points.add(p));
      return;
    }
    if (_map.camera.zoom < _roofZoom) {
      _map.move(p, 18);
      _say(l.solarZoomedIn);
      return;
    }
    if (_points.length >= 3 && containsPoint([for (final q in _points) m.LatLon(q.latitude, q.longitude)], m.LatLon(p.latitude, p.longitude))) {
      _say(l.solarAdjustHint);
      return;
    }
    final switching = _points.isNotEmpty;
    final (outline, failed) = await _lookup(l, p);
    if (!mounted) return;
    if (outline != null) {
      _useOutline(outline);
      _say(switching ? l.solarOutlineSwitched : l.solarOutlineFound);
    } else if (switching) {
      _say(l.solarNoRoofThere);
    } else {
      _change(() => _points.add(p));
      _say(failed ? l.solarOutlineOffline : l.solarOutlineNone);
    }
  }

  static LatLng _midpoint(LatLng a, LatLng b) => LatLng((a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);

  void _repositionHandles() {
    if (!mounted || _points.isEmpty) return;
    // the map can report a move while it lays out; rebuild after that frame
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  /// Corner handles (drag to move, long-press to remove) and + handles on each edge (tap to add
  /// a corner), positioned over the map.
  List<Widget> _handles(AppLocalizations l, ColorScheme scheme) {
    Widget at(LatLng p, double size, Key key, Widget child) {
      final o = _map.camera.latLngToScreenOffset(p);
      return Positioned(key: key, left: o.dx - size / 2, top: o.dy - size / 2, width: size, height: size, child: child);
    }

    final n = _points.length;
    return [
      if (n >= 2)
        for (var i = 0; i < (n >= 3 ? n : 1); i++)
          at(
            _midpoint(_points[i], _points[(i + 1) % n]),
            34,
            Key('roof-add-$i'),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _change(() => _points.insert(i + 1, _midpoint(_points[i], _points[(i + 1) % n]))),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.primary, width: 1.5),
                  ),
                  child: Icon(Icons.add, size: 14, color: scheme.primary),
                ),
              ),
            ),
          ),
      for (var i = 0; i < n; i++)
        at(
          _points[i],
          44,
          Key('roof-corner-$i'),
          Listener(
            onPointerDown: (_) => _startDrag(i),
            onPointerMove: (e) => _drag(e.delta),
            onPointerUp: (_) => _endDrag(),
            onPointerCancel: (_) => _endDrag(),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _say(l.solarAdjustHint),
              onLongPress: () => _change(() => _points.removeAt(i)),
              child: Center(
                child: Container(
                  width: _dragIndex == i ? 26 : 18,
                  height: _dragIndex == i ? 26 : 18,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
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
                    // no rotation: keeps the corner handles simple
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                    onMapReady: () => setState(() => _mapReady = true),
                    // keep the handles on their corners while the map moves
                    onPositionChanged: (_, _) => _repositionHandles(),
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
                      ],
                    ),
                    // map and outline credits (required); wraps instead of running off a narrow screen
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        key: const Key('map-attribution'),
                        color: scheme.surface.withValues(alpha: 0.8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          [
                            useSatellite ? config.satelliteTileAttribution : config.mapTileAttribution,
                            if (_fromOutline && _points.isNotEmpty) l.solarOutlineAttribution,
                          ].join(' · '),
                          style: TextStyle(fontSize: 10, color: scheme.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_mapReady) ..._handles(l, scheme),
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
                if (_message != null && _results == null)
                  Positioned(
                    left: 8,
                    right: 64,
                    top: 8,
                    child: IgnorePointer(
                      child: Container(
                        key: const Key('map-message'),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.72), borderRadius: BorderRadius.circular(12)),
                        child: Text(_message!, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
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
        ],
      ),
      // in the bottom bar, so messages appear above these buttons instead of covering them
      bottomNavigationBar: SafeArea(
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
                    if (area > 0) Text(l.solarAreaApprox(fmt.number(area)), key: const Key('roof-area'), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                tooltip: l.actionUndo,
                onPressed: _history.isEmpty
                    ? null
                    : () => setState(() => _points
                      ..clear()
                      ..addAll(_history.removeLast())),
                icon: const Icon(Icons.undo),
              ),
              IconButton(
                tooltip: l.actionClear,
                onPressed: _points.isEmpty ? null : _clear,
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  if (_points.length < 3) {
                    _say(l.solarNeedPoints);
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SolarParamsScreen(polygon: [for (final p in _points) m.LatLon(p.latitude, p.longitude)], plan: widget.plan),
                    ),
                  );
                },
                child: Text(l.actionContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
