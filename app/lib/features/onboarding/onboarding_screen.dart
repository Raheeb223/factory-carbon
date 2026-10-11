import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/drift_repositories.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../widgets/inputs.dart';
import '../../widgets/language_switch.dart';
import '../../widgets/ui.dart';
import '../tutorial/tutorial_screen.dart';

/// First-run welcome slides, then the factory profile + privacy acknowledgement (spec 8.1).
/// With [existing] it edits the profile (privacy already acknowledged).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.existing});
  final FactoryProfile? existing;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _location = TextEditingController(text: widget.existing?.location ?? '');
  late final _lat = TextEditingController(text: widget.existing?.lat?.toString() ?? '');
  late final _lon = TextEditingController(text: widget.existing?.lon?.toString() ?? '');
  late String _unitChoice = _initialChoice(widget.existing?.productionUnitLabel);
  late final _unit = TextEditingController(text: _unitChoice == 'other' ? widget.existing!.productionUnitLabel : '');
  late bool _ack = widget.existing != null;
  late bool _intro = widget.existing == null;
  bool _ackError = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _location, _lat, _lon, _unit]) {
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

  String? _coord(String? v, double limit, String message) {
    if (v == null || v.trim().isEmpty) return null;
    final d = parseNumber(v);
    if (d == null) return AppLocalizations.of(context).invalidNumber;
    return d.abs() > limit ? message : null;
  }

  Future<void> _save() async {
    final valid = _form.currentState!.validate();
    setState(() => _ackError = !_ack);
    if (!valid || !_ack) return;
    setState(() => _saving = true);
    final existing = widget.existing;
    await ref
        .read(factoryRepositoryProvider)
        .save(
          FactoryProfile(
            id: existing?.id ?? newId(),
            name: _name.text.trim(),
            location: _location.text.trim(),
            lat: parseNumber(_lat.text),
            lon: parseNumber(_lon.text),
            productionUnitLabel: _unitValue,
            privacyAcknowledgedAt: existing?.privacyAcknowledgedAt ?? DateTime.now(),
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (existing != null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_intro) return TutorialScreen(firstRun: true, onDone: () => setState(() => _intro = false));
    final l = AppLocalizations.of(context);
    final editing = widget.existing != null;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final fields = SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        children: [
          TextFormField(
            key: const Key('factory-name'),
            controller: _name,
            decoration: InputDecoration(labelText: l.factoryNameLabel, prefixIcon: const Icon(Icons.factory_outlined)),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _location,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l.factoryLocationLabel, prefixIcon: const Icon(Icons.place_outlined)),
          ),
          const SizedBox(height: 14),
          _UnitPicker(
            choice: _unitChoice,
            other: _unit,
            onChanged: (v) => setState(() => _unitChoice = v),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _lat,
            decoration: InputDecoration(labelText: l.factoryLatLabel, prefixIcon: const Icon(Icons.explore_outlined)),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            inputFormatters: signedNumberInput,
            validator: (v) => _coord(v, 90, l.invalidLatitude),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _lon,
            decoration: InputDecoration(labelText: l.factoryLonLabel, prefixIcon: const Icon(Icons.explore_outlined)),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            inputFormatters: signedNumberInput,
            validator: (v) => _coord(v, 180, l.invalidLongitude),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(l.factoryCoordsHint, style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ),
        ],
      ),
    );

    final privacy = SoftCard(
      color: scheme.primary.withValues(alpha: 0.05),
      borderColor: _ackError ? scheme.error : scheme.primary.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBlob(Icons.shield_outlined, color: scheme.primary, size: 40),
              const SizedBox(width: 12),
              Expanded(child: Text(l.privacyTitle, style: t.titleMedium)),
            ],
          ),
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
        ],
      ),
    );

    final save = FilledButton.icon(
      key: const Key('onboarding-save'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
      onPressed: _saving ? null : _save,
      icon: Icon(editing ? Icons.check_rounded : Icons.rocket_launch_outlined),
      label: Text(editing ? l.actionSave : l.onboardingStart),
    );

    if (editing) {
      return Scaffold(
        appBar: AppBar(title: Text(l.settingsFactory)),
        body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [fields, const SizedBox(height: 16), save]),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Form(
          key: _form,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              HeroHeader(
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => setState(() => _intro = true),
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                        const Spacer(),
                        const LanguagePill(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.onboardingTitle,
                            style: t.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(l.onboardingFormSubtitle, style: t.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.88))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [fields, const SizedBox(height: 6), privacy, const SizedBox(height: 16), save],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
