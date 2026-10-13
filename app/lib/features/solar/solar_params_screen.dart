import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart';
import '../../domain/requests.dart';
import '../../domain/solar_summary.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import 'solar_result_screen.dart';

final solarDefaultsProvider = FutureProvider<SolarDefaults>((ref) => ref.watch(apiClientProvider).solarDefaults());

/// Fractions the API takes as 0..1; the user types them as percent.
const _percentKeys = {'usable_roof_fraction', 'performance_ratio', 'degradation_per_year', 'om_fraction_of_capex_per_year'};

/// Shading choices offered as plain answers instead of a fraction to type.
/// "Not sure" sends nothing, so the result warns that shading was not assessed.
const shadeChoices = {'unsure': null, 'none': 0.0, 'some': 0.1, 'lot': 0.25};

/// Solar assumptions: a few plain questions first, engineering values folded away.
/// Every field is optional; empty means the backend default. Then /v1/solar/estimate.
class SolarParamsScreen extends ConsumerStatefulWidget {
  const SolarParamsScreen({super.key, required this.polygon, this.plan});
  final List<LatLon> polygon;
  final SolarPlan? plan;

  @override
  ConsumerState<SolarParamsScreen> createState() => _SolarParamsScreenState();
}

class _SolarParamsScreenState extends ConsumerState<SolarParamsScreen> {
  final _form = GlobalKey<FormState>();
  static const _simpleKeys = ['capex_bdt_per_kwp', 'electricity_price_bdt_per_kwh'];
  static const _advancedKeys = [
    'usable_roof_fraction',
    'm2_per_kwp',
    'performance_ratio',
    'degradation_per_year',
    'om_fraction_of_capex_per_year',
  ];
  static const _keys = [..._simpleKeys, ..._advancedKeys, 'export_price_bdt_per_kwh'];
  late final Map<String, TextEditingController> _c = {
    for (final k in [..._keys, 'psh']) k: TextEditingController(text: _initial(k)),
  };
  bool? _netMetering;
  String _structure = 'unknown';
  String _shade = 'unsure';
  late int _panelWatt = (widget.plan?.params['panel_watt'] as num?)?.toInt() ?? defaultPanelWatt;
  bool _busy = false;
  Object? _error;

  Map<String, dynamic>? get _savedParams => widget.plan?.params['params'] as Map<String, dynamic>?;

  String _initial(String key) {
    final params = widget.plan?.params;
    if (params == null) return '';
    final v = key == 'psh' ? params['manual_peak_sun_hours'] : _savedParams?[key];
    if (v is! num) return '';
    return _percentKeys.contains(key) ? _trim(v * 100) : _trim(v);
  }

  static String _trim(num v) => v == v.roundToDouble() ? '${v.round()}' : '${double.parse(v.toStringAsFixed(3))}';

  @override
  void initState() {
    super.initState();
    _netMetering = _savedParams?['net_metering'] as bool?;
    _structure = _savedParams?['roof_structure'] as String? ?? 'unknown';
    final shading = (_savedParams?['shading_loss'] as num?)?.toDouble();
    if (shading != null) {
      // nearest offered answer for plans saved with a typed value
      final known = shadeChoices.entries.where((e) => e.value != null);
      _shade = known.reduce((a, b) => (a.value! - shading).abs() <= (b.value! - shading).abs() ? a : b).key;
    }
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  double? _value(String k) {
    final n = parseNumber(_c[k]!.text);
    if (n == null) return null;
    return _percentKeys.contains(k) ? n / 100 : n;
  }

  Map<String, dynamic> _body(bool netDefault) {
    final net = _netMetering ?? netDefault;
    final overrides = <String, dynamic>{
      for (final k in _keys)
        if (_value(k) != null && (k != 'export_price_bdt_per_kwh' || net)) k: _value(k),
      'shading_loss': ?shadeChoices[_shade],
      'net_metering': ?_netMetering,
      'roof_structure': _structure,
    };
    return {
      'polygon': [for (final p in widget.polygon) p.toJson()],
      'params': overrides,
      'consumption': solarConsumption(ref.read(billsProvider).value ?? const []),
      'manual_peak_sun_hours': parseNumber(_c['psh']!.text),
    };
  }

  Future<void> _estimate(bool netDefault) async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final body = _body(netDefault);
    try {
      final result = await ref.read(apiClientProvider).solarEstimate(body);
      if (!mounted) return;
      final saved = {'params': body['params'], 'manual_peak_sun_hours': body['manual_peak_sun_hours'], 'panel_watt': _panelWatt};
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => SolarResultScreen(result: result, polygon: widget.polygon, params: saved, plan: widget.plan),
      ));
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validate(String key, String? v, AppLocalizations l) {
    if (v == null || v.trim().isEmpty) return null;
    final n = parseNumber(v);
    if (n == null) return l.invalidNumber;
    if (n < 0) return l.invalidNonNegative;
    if (_percentKeys.contains(key) && n > 100) return l.invalidPercent;
    if (key == 'psh' && (n <= 0 || n > 12)) return l.invalidNumber;
    return null;
  }

  /// "Typical 60%" from the backend default, or null when there is no default.
  String? _typical(String k, SolarDefaults? d, Fmt fmt, AppLocalizations l) {
    final v = d?.param(k)?.number;
    if (v == null) return null;
    if (_percentKeys.contains(k)) return l.paramDefault('${fmt.number(v * 100, decimals: v * 100 < 1 ? 1 : 0)}%');
    return l.paramDefault(fmt.number(v, decimals: v < 1 ? 3 : 0));
  }

  Widget _field(String k, String label, String? hint, AppLocalizations l, {String? typical}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          key: Key('param-$k'),
          controller: _c[k],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: numberInput,
          validator: (v) => _validate(k, v, l),
          decoration: InputDecoration(
            labelText: label,
            helperText: [?hint, ?typical].join(' '),
            helperMaxLines: 4,
            suffixText: _percentKeys.contains(k) ? '%' : null,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final text = Theme.of(context).textTheme;
    final defaults = ref.watch(solarDefaultsProvider);
    final d = defaults.value;
    final netDefault = d?.netMetering ?? false;
    final net = _netMetering ?? netDefault;
    final advanced = {
      'usable_roof_fraction': (l.paramUsableRoof, l.paramUsableRoofHint),
      'm2_per_kwp': (l.paramM2PerKwp, l.paramM2PerKwpHint),
      'performance_ratio': (l.paramPerformanceRatio, l.paramPerformanceRatioHint),
      'degradation_per_year': (l.paramDegradation, l.paramDegradationHint),
      'om_fraction_of_capex_per_year': (l.paramOm, l.paramOmHint),
    };
    final advancedFilled = [..._advancedKeys, 'psh'].any((k) => _c[k]!.text.trim().isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: Text(l.solarParamsTitle)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          if (defaults.hasError) ErrorPanel(message: errorText(l, defaults.error!), onRetry: () => ref.invalidate(solarDefaultsProvider)),
          Card(
            key: const Key('params-intro'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                const Icon(Icons.lightbulb_outline),
                const SizedBox(width: 12),
                Expanded(child: Text(l.paramsIntro)),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Text(l.paramPanelQuestion, style: text.titleSmall),
          Text(l.paramPanelHint, style: text.bodySmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final w in {...panelWattChoices, _panelWatt}.toList()..sort())
              ChoiceChip(
                key: Key('panel-$w'),
                label: Text(l.valueWatt(fmt.number(w.toDouble()))),
                selected: _panelWatt == w,
                onSelected: (_) => setState(() => _panelWatt = w),
              ),
          ]),
          const SizedBox(height: 18),
          Text(l.paramShadeQuestion, style: text.titleSmall),
          Text(l.paramShadeHint, style: text.bodySmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final (code, label) in [('unsure', l.shadeUnsure), ('none', l.shadeNone), ('some', l.shadeSome), ('lot', l.shadeLot)])
              ChoiceChip(
                key: Key('shade-$code'),
                label: Text(label),
                selected: _shade == code,
                onSelected: (_) => setState(() => _shade = code),
              ),
          ]),
          const SizedBox(height: 18),
          Text(l.paramRoofStructure, style: text.titleSmall),
          Text(l.paramRoofHint, style: text.bodySmall),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            key: const Key('roof-structure'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 'unknown', label: Text(l.roofUnknown)),
              ButtonSegment(value: 'ok', label: Text(l.roofOk)),
              ButtonSegment(value: 'needs_work', label: Text(l.roofNeedsWork)),
            ],
            selected: {_structure},
            onSelectionChanged: (s) => setState(() => _structure = s.first),
          ),
          const SizedBox(height: 20),
          _field('capex_bdt_per_kwp', l.paramCapex, l.paramCapexHint, l),
          _field('electricity_price_bdt_per_kwh', l.paramPrice, l.paramPriceHint, l),
          SwitchListTile(
            key: const Key('net-metering'),
            title: Text(l.paramNetMetering),
            subtitle: Text(l.paramNetMeteringHint),
            value: net,
            onChanged: (v) => setState(() => _netMetering = v),
            contentPadding: EdgeInsets.zero,
          ),
          if (net) ...[
            const SizedBox(height: 8),
            _field('export_price_bdt_per_kwh', l.paramExportPrice, null, l),
          ],
          const SizedBox(height: 4),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              key: const Key('params-advanced'),
              initiallyExpanded: advancedFilled,
              title: Text(l.paramsAdvanced),
              subtitle: Text(l.paramsAdvancedHint),
              childrenPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              children: [
                for (final MapEntry(key: k, value: (label, hint)) in advanced.entries)
                  _field(k, label, hint, l, typical: _typical(k, d, fmt, l)),
                _field('psh', l.paramPsh, l.paramPshHint, l),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(l.solarDisclaimer, style: text.bodySmall),
          const SizedBox(height: 12),
          if (_error != null) ErrorPanel(message: errorText(l, _error!), onRetry: () => _estimate(netDefault)),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            key: const Key('solar-estimate'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: _busy ? null : () => _estimate(netDefault),
            icon: _busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.calculate_outlined),
            label: Text(l.solarEstimate),
          ),
        ),
      ),
    );
  }
}
