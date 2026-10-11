import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/models.dart' as m;
import '../../widgets/common.dart';
import 'solar_params_screen.dart';

const _dhaka = LatLng(23.8103, 90.4125);

/// Draw the roof outline by tapping corners (spec 8.7). Tile source is configurable
/// via --dart-define; satellite imagery is only offered when explicitly configured.
class SolarMapScreen extends ConsumerStatefulWidget {
  const SolarMapScreen({super.key, this.plan});
  final m.SolarPlan? plan;

  @override
  ConsumerState<SolarMapScreen> createState() => _SolarMapScreenState();
}

class _SolarMapScreenState extends ConsumerState<SolarMapScreen> {
  late final List<LatLng> _points = [for (final p in widget.plan?.polygon ?? const <m.LatLon>[]) LatLng(p.lat, p.lon)];
  bool _satellite = false;
  final _map = MapController();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan?.name ?? l.solarNewPlan),
        actions: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(l.solarLayerStreet)),
              ButtonSegment(value: true, label: Text(l.solarLayerSatellite), enabled: config.hasSatellite),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.solarDrawHint),
                if (!config.hasSatellite) Text(l.solarSatelliteUnavailable, style: Theme.of(context).textTheme.bodySmall),
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
                    onTap: (_, point) => setState(() => _points.add(point)),
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
                if (hasFactoryPos)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'locate',
                      tooltip: l.solarMyLocation,
                      onPressed: () => _map.move(LatLng(profile!.lat!, profile.lon!), 18),
                      child: const Icon(Icons.my_location),
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
                  Text(l.solarPoints(_points.length)),
                  const Spacer(),
                  IconButton(
                    tooltip: l.actionUndo,
                    onPressed: _points.isEmpty ? null : () => setState(_points.removeLast),
                    icon: const Icon(Icons.undo),
                  ),
                  IconButton(
                    tooltip: l.actionClear,
                    onPressed: _points.isEmpty ? null : () => setState(_points.clear),
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
