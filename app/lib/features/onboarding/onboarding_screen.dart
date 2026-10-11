import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../data/drift_repositories.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../widgets/inputs.dart';
import '../../widgets/language_switch.dart';

/// First-run factory profile + privacy acknowledgement (spec 8.1).
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
  late final _unit = TextEditingController(text: widget.existing?.productionUnitLabel ?? 'pieces');
  late bool _ack = widget.existing != null;
  bool _ackError = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _location, _lat, _lon, _unit]) {
      c.dispose();
    }
    super.dispose();
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
    await ref.read(factoryRepositoryProvider).save(FactoryProfile(
          id: existing?.id ?? newId(),
          name: _name.text.trim(),
          location: _location.text.trim(),
          lat: parseNumber(_lat.text),
          lon: parseNumber(_lon.text),
          productionUnitLabel: _unit.text.trim().isEmpty ? 'pieces' : _unit.text.trim(),
          privacyAcknowledgedAt: existing?.privacyAcknowledgedAt ?? DateTime.now(),
        ));
    if (!mounted) return;
    setState(() => _saving = false);
    if (existing != null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? l.settingsFactory : l.onboardingTitle), actions: [if (!editing) const LanguageToggleAction()]),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            if (!editing) ...[
              Center(child: Icon(Icons.eco_outlined, size: 56, color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 8),
              Text(l.appTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(l.onboardingIntro, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(l.languageChoose, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              const LanguageSwitch(),
              const SizedBox(height: 20),
            ],
            TextFormField(
              key: const Key('factory-name'),
              controller: _name,
              decoration: InputDecoration(labelText: l.factoryNameLabel, prefixIcon: const Icon(Icons.factory_outlined)),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _location, decoration: InputDecoration(labelText: l.factoryLocationLabel, prefixIcon: const Icon(Icons.place_outlined))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _lat,
                  decoration: InputDecoration(labelText: l.factoryLatLabel),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: signedNumberInput,
                  validator: (v) => _coord(v, 90, l.invalidLatitude),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _lon,
                  decoration: InputDecoration(labelText: l.factoryLonLabel),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: signedNumberInput,
                  validator: (v) => _coord(v, 180, l.invalidLongitude),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(controller: _unit, decoration: InputDecoration(labelText: l.productionUnitLabel, prefixIcon: const Icon(Icons.inventory_2_outlined))),
            if (!editing) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.privacyTitle, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(l.privacyBody),
                  ]),
                ),
              ),
              CheckboxListTile(
                key: const Key('privacy-ack'),
                value: _ack,
                onChanged: (v) => setState(() {
                  _ack = v ?? false;
                  _ackError = false;
                }),
                title: Text(l.privacyAcknowledge),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                subtitle: _ackError ? Text(l.privacyMustAcknowledge, style: TextStyle(color: Theme.of(context).colorScheme.error)) : null,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('onboarding-save'),
              onPressed: _saving ? null : _save,
              child: Text(editing ? l.actionSave : l.onboardingStart),
            ),
          ]),
        ),
      ),
    );
  }
}
