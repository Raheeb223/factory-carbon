import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';

/// What the 3D page (assets/cesium/viewer.html) needs: the roof, the panels, and up to
/// 25 panel corners where it samples the real roof height on the Google 3D mesh.
Map<String, dynamic> viewerConfig({
  required String token,
  required List<LatLon> roof,
  required List<List<LatLon>> panels,
  required String mode,
  required double heightM,
  required bool showPanels,
}) {
  List<double> pt(LatLon p) => [p.lat, p.lon];
  final step = panels.length <= 25 ? 1 : (panels.length / 25).ceil();
  final samples = [for (var i = 0; i < panels.length; i += step) pt(panels[i].first)];
  return {
    'token': token,
    'roof': [for (final p in roof) pt(p)],
    'panels': [for (final p in panels) [for (final c in p) pt(c)]],
    'samples': samples.isEmpty ? [for (final p in roof) pt(p)] : samples,
    'mode': mode,
    'height': heightM,
    'showPanels': showPanels,
  };
}

/// The factory in 3D: Google's photorealistic 3D buildings where they exist, or a block
/// raised from the traced outline, with the solar panels on the roof. Spin and zoom by touch.
class Solar3DScreen extends ConsumerStatefulWidget {
  const Solar3DScreen({super.key, required this.roof, required this.panels, this.showPanels = true});
  final List<LatLon> roof;
  final List<List<LatLon>> panels;
  final bool showPanels;

  @override
  ConsumerState<Solar3DScreen> createState() => _Solar3DScreenState();
}

class _Solar3DScreenState extends ConsumerState<Solar3DScreen> {
  late final WebViewController _web;
  late bool _panels = widget.showPanels;
  var _mode = 'google';
  var _floors = 2;
  var _ready = false;
  String? _error;

  double get _heightM => _floors * 4.0;

  @override
  void initState() {
    super.initState();
    final config = ref.read(appConfigProvider);
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0B1220))
      ..addJavaScriptChannel('App', onMessageReceived: (m) => _onMessage(m.message))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => _web.runJavaScript('setup(${jsonEncode(viewerConfig(
              token: config.cesiumIonToken,
              roof: widget.roof,
              panels: widget.panels,
              mode: _mode,
              heightM: _heightM,
              showPanels: _panels,
            ))})'),
      ));
    _load(config.apiBaseUrl);
  }

  // Loaded under an https origin (not file://) so the 3D library's web workers can start.
  Future<void> _load(String baseUrl) async {
    final html = await rootBundle.loadString('assets/cesium/viewer.html');
    await _web.loadHtmlString(html, baseUrl: baseUrl.startsWith('https://') ? baseUrl : 'https://localhost/');
  }

  void _onMessage(String m) {
    if (!mounted) return;
    setState(() {
      if (m == 'ready') {
        _ready = true;
        _error = null;
      } else if (m.startsWith('error:')) {
        _error = m.substring(6);
      }
    });
  }

  void _setMode(String m) {
    setState(() {
      _mode = m;
      _ready = false;
    });
    _web.runJavaScript("setMode('$m').then(() => App.postMessage('ready'))");
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.view3dTitle),
        actions: [
          IconButton(
            tooltip: l.view3dReset,
            icon: const Icon(Icons.center_focus_strong_rounded),
            onPressed: () => _web.runJavaScript('resetCamera()'),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: Stack(children: [
            WebViewWidget(controller: _web),
            if (!_ready && _error == null)
              Container(
                color: const Color(0xCC0B1220),
                alignment: Alignment.center,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 14),
                  Text(l.view3dLoading, style: const TextStyle(color: Colors.white)),
                ]),
              ),
            if (_error != null)
              Container(
                color: const Color(0xEE0B1220),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Text(l.view3dError, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
              ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Center(
                child: Material(
                  color: scheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                  child: SegmentedButton<bool>(
                    key: const Key('3d-panels'),
                    segments: [
                      ButtonSegment(value: false, label: Text(l.previewBefore), icon: const Icon(Icons.factory_outlined)),
                      ButtonSegment(value: true, label: Text(l.previewAfter), icon: const Icon(Icons.solar_power_rounded)),
                    ],
                    selected: {_panels},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) {
                      setState(() => _panels = s.first);
                      _web.runJavaScript('setPanels(${s.first})');
                    },
                  ),
                ),
              ),
            ),
          ]),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
              SegmentedButton<String>(
                key: const Key('3d-mode'),
                segments: [
                  ButtonSegment(value: 'google', label: Text(l.view3dReal), icon: const Icon(Icons.public_rounded)),
                  ButtonSegment(value: 'model', label: Text(l.view3dModel), icon: const Icon(Icons.view_in_ar_rounded)),
                ],
                selected: {_mode},
                showSelectedIcon: false,
                onSelectionChanged: (s) => _setMode(s.first),
              ),
              const SizedBox(height: 6),
              if (_mode == 'model')
                Row(children: [
                  Text(l.view3dFloors(Fmt.of(context).number(_floors.toDouble())), style: t.bodyMedium),
                  Expanded(
                    child: Slider(
                      value: _floors.toDouble(),
                      min: 1,
                      max: 8,
                      divisions: 7,
                      onChanged: (v) {
                        setState(() => _floors = v.round());
                        _web.runJavaScript('setHeight($_heightM)');
                      },
                    ),
                  ),
                ])
              else
                Text(l.view3dRealHint, style: t.bodySmall),
              Text(l.view3dGesture, style: t.bodySmall),
            ]),
          ),
        ),
      ]),
    );
  }
}
