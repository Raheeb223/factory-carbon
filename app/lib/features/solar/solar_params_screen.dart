import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart';
import '../../domain/requests.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import 'solar_result_screen.dart';

final solarDefaultsProvider = FutureProvider<SolarDefaults>((ref) => ref.watch(apiClientProvider).solarDefaults());

/// Parameter sheet with backend defaults (editable) then /v1/solar/estimate.
class SolarParamsScreen extends ConsumerStatefulWidget {
  const SolarParamsScreen({super.key, required this.polygon, this.plan});
  final List<LatLon> polygon;
  final SolarPlan? plan;

  @override
  ConsumerState<SolarParamsScreen> createState() => _SolarParamsScreenState();
}

class _SolarParamsScreenState extends ConsumerState<SolarParamsScreen> {
  final _form = GlobalKey<FormState>();
  static const _keys = [
    'usable_roof_fraction',
    'm2_per_kwp',
    'performance_ratio',
    'shading_loss',
    'degradation_per_year',
    'capex_bdt_per_kwp',
    'om_fraction_of_capex_per_year',
    'electricity_price_bdt_per_kwh',
    'export_price_bdt_per_kwh',
  ];
  late final Map<String, TextEditingController> _c = {
    for (final k in [..._keys, 'psh']) k: TextEditingController(text: _initial(k)),
  };
  bool? _netMetering;
  String _structure = 'unknown';
  bool _busy = false;
  Object? _error;

  String _initial(String key) {
    final params = widget.plan?.params;
    if (params == null) return '';
    final v = key == 'psh' ? params['manual_peak_sun_hours'] : (params['params'] as Map<String, dynamic>?)?[key];
    return v == null ? '' : '$v';
  }

  @override
  void initState() {
    super.initState();
    _netMetering = (widget.plan?.params['params'] as Map<String, dynamic>?)?['net_metering'] as bool?;
    _structure = (widget.plan?.params['params'] as Map<String, dynamic>?)?['roof_structure'] as String? ?? 'unknown';
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _body() {
    final overrides = <String, dynamic>{
      for (final k in _keys)
        if (parseNumber(_c[k]!.text) != null) k: parseNumber(_c[k]!.text),
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

  Future<void> _estimate() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final body = _body();
    try {
      final result = await ref.read(apiClientProvider).solarEstimate(body);
      if (!mounted) return;
      final saved = {'params': body['params'], 'manual_peak_sun_hours': body['manual_peak_sun_hours']};
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
    if (key == 'shading_loss' && n >= 0.9) return l.invalidFraction;
    if (const {'usable_roof_fraction', 'performance_ratio', 'degradation_per_year', 'om_fraction_of_capex_per_year'}.contains(key) && n > 1) {
      return l.invalidFraction;
    }
    if (key == 'psh' && (n <= 0 || n > 12)) return l.invalidNumber;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final defaults = ref.watch(solarDefaultsProvider);
    final labels = {
      'usable_roof_fraction': l.paramUsableRoof,
      'm2_per_kwp': l.paramM2PerKwp,
      'performance_ratio': l.paramPerformanceRatio,
      'shading_loss': l.paramShading,
      'degradation_per_year': l.paramDegradation,
      'capex_bdt_per_kwp': l.paramCapex,
      'om_fraction_of_capex_per_year': l.paramOm,
      'electricity_price_bdt_per_kwh': l.paramPrice,
      'export_price_bdt_per_kwh': l.paramExportPrice,
    };
    final d = defaults.value;
    final netDefault = d?.netMetering ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(l.solarParamsTitle)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          if (defaults.hasError) ErrorPanel(message: errorText(l, defaults.error!), onRetry: () => ref.invalidate(solarDefaultsProvider)),
          for (final k in _keys)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _c[k],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: numberInput,
                validator: (v) => _validate(k, v, l),
                decoration: InputDecoration(
                  labelText: labels[k],
                  helperText: k == 'electricity_price_bdt_per_kwh'
                      ? l.paramPriceHint
                      : k == 'shading_loss'
                      ? l.paramShadingHint
                      : (d?.param(k)?.number == null ? null : l.paramDefault(fmt.number(d!.param(k)!.number, decimals: d.param(k)!.number! < 1 ? 3 : 0))),
                  suffixIcon: d?.param(k)?.isPlaceholder == true && d?.param(k)?.number != null
                      ? const Padding(padding: EdgeInsets.all(8), child: UnverifiedBadge())
                      : null,
                ),
              ),
            ),
          TextFormField(
            controller: _c['psh'],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: numberInput,
            validator: (v) => _validate('psh', v, l),
            decoration: InputDecoration(labelText: l.paramPsh, helperText: l.paramPshHint),
          ),
          const SizedBox(height: 14),
          Text(l.paramRoofStructure, style: Theme.of(context).textTheme.titleSmall),
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
          SwitchListTile(
            title: Text(l.paramNetMetering),
            value: _netMetering ?? netDefault,
            onChanged: (v) => setState(() => _netMetering = v),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Text(l.solarDisclaimer, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          if (_error != null) ErrorPanel(message: errorText(l, _error!), onRetry: _estimate),
          FilledButton.icon(
            key: const Key('solar-estimate'),
            onPressed: _busy ? null : _estimate,
            icon: _busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.calculate_outlined),
            label: Text(l.solarEstimate),
          ),
        ]),
      ),
    );
  }
}
