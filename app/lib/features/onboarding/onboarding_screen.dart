import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/drift_repositories.dart';
import '../../data/providers.dart';
import '../../domain/geo.dart';
import '../../domain/models.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import '../../widgets/language_switch.dart';
import '../../widgets/ui.dart';
import '../carbon/carbon_controller.dart';
import '../solar/place_finder.dart';
import '../tutorial/tutorial_screen.dart';

/// First-run welcome slides, then a four-step factory setup (spec 8.1):
/// 1 the factory, 2 its location, 3 production and energy, 4 check + privacy notice.
/// With [existing] all sections are shown on one page for editing.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.existing, this.finder});
  final FactoryProfile? existing;

  /// Overrides [placeFinderProvider] (tests).
  final PlaceFinder? finder;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

const _stepCount = 4;

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _form = GlobalKey<FormState>();
  late final FactoryProfile? _e = widget.existing;
  late final _name = TextEditingController(text: _e?.name ?? '');
  late final _address = TextEditingController(text: _e?.location ?? '');
  late final _lat = TextEditingController(text: _e?.lat?.toString() ?? '');
  late final _lon = TextEditingController(text: _e?.lon?.toString() ?? '');
  late final _paste = TextEditingController();
  late final _workers = TextEditingController(text: _e?.workers?.toString() ?? '');
  late String _unitChoice = _initialChoice(_e?.productionUnitLabel);
  late final _unit = TextEditingController(text: _unitChoice == 'other' ? _e!.productionUnitLabel : '');
  late String? _facility = _e?.facilityType;
  late String? _district = _e?.district;
  late int? _shifts = _e?.shiftsPerDay;
  late Set<String> _sources = {...(_e?.energySources ?? const {'electricity'})};
  late String _reportingYear = _e?.reportingYear ?? 'calendar';
  late bool _manualCoords = _e?.lat != null;
  late bool _ack = _e != null;
  late bool _intro = _e == null;
  int _step = 0;
  bool _ackError = false;
  bool _sourcesError = false;
  bool _saving = false;
  bool _locating = false;
  String? _pasteError;

  PlaceFinder get _finder => widget.finder ?? ref.read(placeFinderProvider);

  @override
  void dispose() {
    for (final c in [_name, _address, _lat, _lon, _paste, _workers, _unit]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _initialChoice(String? stored) {
    final s = stored?.trim().toLowerCase() ?? '';
    if (s.isEmpty) return 'pieces';
    return productionUnitChoices.contains(s) ? s : 'other';
  }

  String get _unitValue {
    if (_unitChoice != 'other') return _unitChoice;
    final typed = _unit.text.trim();
    return typed.isEmpty ? 'pieces' : typed;
  }

  double? get _latValue => parseNumber(_lat.text);
  double? get _lonValue => parseNumber(_lon.text);
  bool get _hasLocation => _latValue != null && _lonValue != null;

  void _setLocation(LatLon p) => setState(() {
        _lat.text = p.lat.toStringAsFixed(6);
        _lon.text = p.lon.toStringAsFixed(6);
        _pasteError = null;
      });

  Future<void> _useGps() async {
    final l = AppLocalizations.of(context);
    setState(() => _locating = true);
    try {
      _setLocation(await _finder.myLocation());
    } on GpsException catch (e) {
      if (mounted) {
        showSnack(context, switch (e.problem) {
          GpsProblem.off => l.solarGpsOff,
          GpsProblem.denied => l.solarGpsDenied,
          GpsProblem.failed => l.solarGpsFailed,
        });
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _usePasted() {
    final p = parseLatLon(_paste.text);
    if (p == null) {
      setState(() => _pasteError = AppLocalizations.of(context).locPasteInvalid);
      return;
    }
    _paste.clear();
    _setLocation(p);
  }

  String? _coordError(AppLocalizations l) {
    final lat = _latValue, lon = _lonValue;
    if (_lat.text.trim().isEmpty && _lon.text.trim().isEmpty) return null;
    if (lat == null || lon == null) return l.locBothNeeded;
    return insideBangladesh(lat, lon) ? null : l.locOutside;
  }

  /// Checks the fields of the current step (all steps when editing).
  bool _validate() {
    final valid = _form.currentState!.validate();
    final energyStep = widget.existing != null || _step == 2;
    setState(() => _sourcesError = energyStep && _sources.isEmpty);
    return valid && !_sourcesError;
  }

  void _next() {
    if (!_validate()) return;
    setState(() => _step++);
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _ackError = !_ack);
    if (!_ack) return;
    setState(() => _saving = true);
    final existing = widget.existing;
    await ref.read(factoryRepositoryProvider).save(
          FactoryProfile(
            id: existing?.id ?? newId(),
            name: _name.text.trim(),
            location: _address.text.trim(),
            lat: _hasLocation ? _latValue : null,
            lon: _hasLocation ? _lonValue : null,
            productionUnitLabel: _unitValue,
            privacyAcknowledgedAt: existing?.privacyAcknowledgedAt ?? DateTime.now(),
            facilityType: _facility,
            district: _district,
            workers: int.tryParse(_workers.text.trim()),
            shiftsPerDay: _shifts,
            energySources: _sources,
            reportingYear: _reportingYear,
            target: existing?.target, // set on the report, not here
          ),
        );
    if (existing?.reportingYear != _reportingYear) {
      // The report should open on the newly chosen kind of year.
      await ref.read(settingsStoreProvider).setReportPeriod(null);
      ref.invalidate(reportPeriodProvider);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (existing != null) Navigator.of(context).pop();
  }

  // ---------------------------------------------------------------- sections

  Widget _section({required IconData icon, required String title, String? subtitle, required List<Widget> children}) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          IconBlob(icon, color: scheme.primary, size: 38),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: t.titleMedium)),
        ]),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle, style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ],
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );

  Widget _chips<T>({required List<(T, String)> options, required bool Function(T) selected, required void Function(T) onTap, required String keyPrefix}) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (value, label) in options)
            ChoiceChip(
              key: Key('$keyPrefix-$value'),
              label: Text(label),
              selected: selected(value),
              showCheckmark: true,
              onSelected: (_) => onTap(value),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
        ],
      );

  Widget _basics(AppLocalizations l) => _section(
        icon: Icons.factory_rounded,
        title: l.setupBasicsTitle,
        subtitle: l.setupBasicsSub,
        children: [
          TextFormField(
            key: const Key('factory-name'),
            controller: _name,
            decoration: InputDecoration(labelText: l.factoryNameLabel, prefixIcon: const Icon(Icons.badge_outlined)),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 14),
          _label(l.facilityTypeLabel),
          _chips(
            keyPrefix: 'facility',
            options: [for (final f in facilityTypes) (f, facilityLabel(l, f))],
            selected: (v) => _facility == v,
            onTap: (v) => setState(() => _facility = _facility == v ? null : v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const Key('district'),
            initialValue: _district,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.districtLabel, prefixIcon: const Icon(Icons.map_outlined)),
            items: [for (final d in factoryDistricts) DropdownMenuItem(value: d, child: Text(districtLabel(l, d)))],
            onChanged: (v) => setState(() => _district = v),
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const Key('factory-address'),
            controller: _address,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            maxLength: 200,
            decoration: InputDecoration(labelText: l.addressLabel, hintText: l.addressHint, prefixIcon: const Icon(Icons.place_outlined), counterText: ''),
          ),
        ],
      );

  Widget _location(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final error = _coordError(l);
    return _section(
      icon: Icons.my_location_rounded,
      title: l.setupLocationTitle,
      subtitle: l.setupLocationSub,
      children: [
        Container(
          key: const Key('loc-status'),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (_hasLocation && error == null ? const Color(0xFF16A34A) : scheme.outline).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Icon(
              _hasLocation && error == null ? Icons.check_circle_rounded : Icons.location_off_outlined,
              color: _hasLocation && error == null ? const Color(0xFF16A34A) : scheme.outline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _hasLocation ? l.locSet(_latValue!.toStringAsFixed(5), _lonValue!.toStringAsFixed(5)) : l.locNotSet,
                style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (_hasLocation)
              TextButton(
                key: const Key('loc-clear'),
                onPressed: () => setState(() {
                  _lat.clear();
                  _lon.clear();
                }),
                child: Text(l.actionClear),
              ),
          ]),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(error, key: const Key('loc-error'), style: t.bodySmall?.copyWith(color: scheme.error)),
          ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          key: const Key('loc-gps'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          onPressed: _locating ? null : _useGps,
          icon: _locating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.gps_fixed_rounded),
          label: Text(_locating ? l.locGpsBusy : l.locGps),
        ),
        const SizedBox(height: 14),
        TextField(
          key: const Key('loc-paste'),
          controller: _paste,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _usePasted(),
          decoration: InputDecoration(
            labelText: l.locPasteLabel,
            hintText: l.locPasteHint,
            errorText: _pasteError,
            errorMaxLines: 3,
            prefixIcon: const Icon(Icons.link_rounded),
            suffixIcon: IconButton(key: const Key('loc-paste-go'), tooltip: l.actionContinue, icon: const Icon(Icons.arrow_forward_rounded), onPressed: _usePasted),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('loc-manual'),
            onPressed: () => setState(() => _manualCoords = !_manualCoords),
            icon: Icon(_manualCoords ? Icons.expand_less_rounded : Icons.expand_more_rounded),
            label: Text(l.locManual),
          ),
        ),
        if (_manualCoords)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: TextFormField(
                key: const Key('factory-lat'),
                controller: _lat,
                decoration: InputDecoration(labelText: l.factoryLatLabel),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                inputFormatters: signedNumberInput,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                key: const Key('factory-lon'),
                controller: _lon,
                decoration: InputDecoration(labelText: l.factoryLonLabel),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                inputFormatters: signedNumberInput,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ]),
        // Hidden validator so Next/Save stop on a bad location.
        FormField<void>(validator: (_) => _coordError(l), builder: (_) => const SizedBox.shrink()),
      ],
    );
  }

  Widget _production(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return _section(
      icon: Icons.precision_manufacturing_rounded,
      title: l.setupProductionTitle,
      subtitle: l.setupProductionSub,
      children: [
        _UnitPicker(choice: _unitChoice, other: _unit, onChanged: (v) => setState(() => _unitChoice = v)),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: TextFormField(
              key: const Key('workers'),
              controller: _workers,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              decoration: InputDecoration(labelText: l.workersLabel, prefixIcon: const Icon(Icons.groups_outlined)),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _label(l.shiftsLabel),
        _chips(
          keyPrefix: 'shifts',
          options: [for (final n in const [1, 2, 3]) (n, fmtInt(context, n))],
          selected: (v) => _shifts == v,
          onTap: (v) => setState(() => _shifts = _shifts == v ? null : v),
        ),
        const Divider(height: 32),
        _label(l.energySourcesLabel),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final s in energySourceOptions)
            FilterChip(
              key: Key('source-$s'),
              avatar: Icon(energySourceIcon(s), size: 18),
              label: Text(energySourceLabel(l, s)),
              selected: _sources.contains(s),
              onSelected: (on) => setState(() {
                _sources = on ? {..._sources, s} : ({..._sources}..remove(s));
                _sourcesError = false;
              }),
            ),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(
            _sourcesError ? l.sourcesNeedOne : l.energySourcesHint,
            key: _sourcesError ? const Key('sources-error') : null,
            style: t.bodySmall?.copyWith(color: _sourcesError ? scheme.error : scheme.onSurfaceVariant),
          ),
        ),
        const Divider(height: 32),
        _label(l.reportingYearLabel),
        SegmentedButton<String>(
          key: const Key('reporting-year'),
          segments: [
            ButtonSegment(value: 'calendar', label: Text(l.reportingCalendar)),
            ButtonSegment(value: 'fiscal', label: Text(l.reportingFiscal)),
          ],
          selected: {_reportingYear},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _reportingYear = s.first),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(l.reportingYearHint, style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ),
      ],
    );
  }

  Widget _review(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            SizedBox(width: 110, child: Text(label, style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant))),
            Expanded(child: Text(value, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
          ]),
        );
    final place = [if (_address.text.trim().isNotEmpty) _address.text.trim(), if (_district != null) districtLabel(l, _district!)].join(', ');
    final summary = _section(
      icon: Icons.fact_check_outlined,
      title: l.setupReviewTitle,
      subtitle: l.setupReviewSub,
      children: [
        row(Icons.badge_outlined, l.factoryNameLabel, _name.text.trim()),
        row(Icons.category_outlined, l.facilityTypeLabel, _facility == null ? '–' : facilityLabel(l, _facility!)),
        row(Icons.place_outlined, l.districtLabel, place.isEmpty ? '–' : place),
        row(Icons.my_location_rounded, l.setupLocationTitle, _hasLocation ? '${_latValue!.toStringAsFixed(5)}, ${_lonValue!.toStringAsFixed(5)}' : l.locNotSet),
        row(Icons.inventory_2_outlined, l.productionUnitLabel, unitLabel(l, _unitValue)),
        if (_workers.text.trim().isNotEmpty) row(Icons.groups_outlined, l.workersLabel, _workers.text.trim()),
        row(Icons.bolt_rounded, l.energySourcesLabel, [for (final s in energySourceOptions) if (_sources.contains(s)) energySourceLabel(l, s)].join(', ')),
        row(Icons.date_range_rounded, l.reportingYearLabel, _reportingYear == 'fiscal' ? l.reportingFiscal : l.reportingCalendar),
      ],
    );
    final privacy = SoftCard(
      color: scheme.primary.withValues(alpha: 0.05),
      borderColor: _ackError ? scheme.error : scheme.primary.withValues(alpha: 0.2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconBlob(Icons.shield_outlined, color: scheme.primary, size: 40),
          const SizedBox(width: 12),
          Expanded(child: Text(l.privacyTitle, style: t.titleMedium)),
        ]),
        const SizedBox(height: 10),
        Text(l.privacyBody, style: t.bodyMedium?.copyWith(height: 1.4)),
        const SizedBox(height: 4),
        CheckboxListTile(
          key: const Key('privacy-ack'),
          value: _ack,
          onChanged: (v) => setState(() {
            _ack = v ?? false;
            _ackError = false;
          }),
          title: Text(l.privacyAcknowledge, style: const TextStyle(fontWeight: FontWeight.w600)),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          subtitle: _ackError ? Text(l.privacyMustAcknowledge, style: TextStyle(color: scheme.error)) : null,
        ),
      ]),
    );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [summary, privacy]);
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    if (_intro) return TutorialScreen(firstRun: true, onDone: () => setState(() => _intro = false));
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    final saveButton = FilledButton.icon(
      key: const Key('onboarding-save'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
      onPressed: _saving ? null : _save,
      icon: Icon(widget.existing != null ? Icons.check_rounded : Icons.rocket_launch_outlined),
      label: Text(widget.existing != null ? l.actionSave : l.onboardingStart),
    );

    if (widget.existing != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.settingsFactory)),
        body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [
            _basics(l),
            _location(l),
            _production(l),
            const SizedBox(height: 8),
            saveButton,
          ]),
        ),
      );
    }

    final step = switch (_step) {
      0 => _basics(l),
      1 => _location(l),
      2 => _production(l),
      _ => _review(l),
    };
    final last = _step == _stepCount - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Form(
          key: _form,
          child: StatusBarScrim(
            child: ListView(
            padding: EdgeInsets.zero,
            children: [
              HeroHeader(
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 22),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    IconButton(
                      key: const Key('onboarding-back'),
                      tooltip: l.actionBack,
                      onPressed: () => setState(() => _step == 0 ? _intro = true : _step--),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    const Spacer(),
                    const LanguagePill(),
                  ]),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.onboardingTitle, style: t.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(l.onboardingFormSubtitle, style: t.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.88))),
                      const SizedBox(height: 14),
                      Text(l.setupStep(_step + 1, _stepCount), key: const Key('onboarding-step'), style: t.labelLarge?.copyWith(color: Colors.white)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_step + 1) / _stepCount,
                          minHeight: 6,
                          color: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  KeyedSubtree(key: ValueKey(_step), child: step),
                  const SizedBox(height: 8),
                  if (last)
                    saveButton
                  else
                    FilledButton.icon(
                      key: const Key('onboarding-next'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                      onPressed: _next,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(_step == 1 && !_hasLocation ? l.setupSkipLocation : l.actionNext),
                    ),
                ]),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

String fmtInt(BuildContext context, int n) => Fmt.of(context).number(n.toDouble());

String facilityLabel(AppLocalizations l, String f) => switch (f) {
      'knit' => l.facilityKnit,
      'woven' => l.facilityWoven,
      'sweater' => l.facilitySweater,
      'denim' => l.facilityDenim,
      'dyeing' => l.facilityDyeing,
      'washing' => l.facilityWashing,
      _ => l.facilityOther,
    };

String districtLabel(AppLocalizations l, String d) => switch (d) {
      'dhaka' => l.districtDhaka,
      'gazipur' => l.districtGazipur,
      'narayanganj' => l.districtNarayanganj,
      'narsingdi' => l.districtNarsingdi,
      'chattogram' => l.districtChattogram,
      'mymensingh' => l.districtMymensingh,
      'cumilla' => l.districtCumilla,
      'khulna' => l.districtKhulna,
      _ => l.districtOther,
    };

String energySourceLabel(AppLocalizations l, String s) => switch (s) {
      'electricity' => l.sourceElectricity,
      'gas' => l.sourceGas,
      'diesel' => l.sourceDiesel,
      'lpg' => l.sourceLpg,
      'furnace_oil' => l.sourceFurnaceOil,
      _ => l.sourceSolar,
    };

IconData energySourceIcon(String s) => switch (s) {
      'electricity' => Icons.bolt_rounded,
      'gas' => Icons.local_fire_department_rounded,
      'diesel' => Icons.local_gas_station_rounded,
      'lpg' => Icons.propane_tank_rounded,
      'furnace_oil' => Icons.oil_barrel_rounded,
      _ => Icons.solar_power_rounded,
    };

/// "How do you count what you make?": one tap on a chip instead of typing a unit.
/// "Other" opens an empty box for a unit that is not listed.
class _UnitPicker extends StatelessWidget {
  const _UnitPicker({required this.choice, required this.other, required this.onChanged});
  final String choice;
  final TextEditingController other;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    final options = [
      for (final c in productionUnitChoices) (c, c == 'kg' ? unitLabel(l, c) : cap(unitLabel(l, c))),
      ('other', l.unitOther),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: scheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Text(l.productionUnitLabel, style: t.titleSmall)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (value, label) in options)
              ChoiceChip(
                key: Key('unit-$value'),
                label: Text(label),
                selected: choice == value,
                showCheckmark: true,
                onSelected: (_) => onChanged(value),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              ),
          ],
        ),
        if (choice == 'other') ...[
          const SizedBox(height: 10),
          TextFormField(
            key: const Key('unit-other-text'),
            controller: other,
            autofocus: true,
            maxLength: 40,
            decoration: InputDecoration(hintText: l.unitOtherHint, counterText: ''),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(l.productionUnitHelp, style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ),
      ],
    );
  }
}
