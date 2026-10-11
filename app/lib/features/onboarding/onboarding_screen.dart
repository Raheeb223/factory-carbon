import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/drift_repositories.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../widgets/inputs.dart';
import '../../widgets/language_switch.dart';
import '../../widgets/ui.dart';

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
  late final _unit = TextEditingController(text: widget.existing?.productionUnitLabel ?? 'pieces');
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
            productionUnitLabel: _unit.text.trim().isEmpty ? 'pieces' : _unit.text.trim(),
            privacyAcknowledgedAt: existing?.privacyAcknowledgedAt ?? DateTime.now(),
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (existing != null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_intro) return _IntroSlides(onDone: () => setState(() => _intro = false));
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
          TextFormField(
            controller: _unit,
            decoration: InputDecoration(labelText: l.productionUnitLabel, prefixIcon: const Icon(Icons.inventory_2_outlined)),
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

/// Language toggle styled for use on a gradient.

class _Slide {
  const _Slide(this.icon, this.orbit, this.title, this.body);
  final IconData icon;
  final List<(IconData, Color)> orbit;
  final String title;
  final String body;
}

class _IntroSlides extends StatefulWidget {
  const _IntroSlides({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_IntroSlides> createState() => _IntroSlidesState();
}

class _IntroSlidesState extends State<_IntroSlides> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final slides = [
      _Slide(
        Icons.document_scanner_rounded,
        const [
          (Icons.bolt_rounded, FeatureColors.bills),
          (Icons.local_fire_department_rounded, FeatureColors.waste),
          (Icons.local_gas_station_rounded, FeatureColors.production),
        ],
        l.intro1Title,
        l.intro1Body,
      ),
      _Slide(
        Icons.eco_rounded,
        const [
          (Icons.picture_as_pdf_rounded, FeatureColors.waste),
          (Icons.bar_chart_rounded, FeatureColors.bills),
          (Icons.table_chart_rounded, FeatureColors.carbon),
        ],
        l.intro2Title,
        l.intro2Body,
      ),
      _Slide(
        Icons.solar_power_rounded,
        const [
          (Icons.trending_down_rounded, FeatureColors.carbon),
          (Icons.wb_sunny_rounded, FeatureColors.solar),
          (Icons.savings_rounded, FeatureColors.production),
        ],
        l.intro3Title,
        l.intro3Body,
      ),
    ];
    final last = _index == slides.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: BrandGradients.primary),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
                        child: const Icon(Icons.eco_rounded, color: Color(0xFF0F766E), size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.appTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                      const LanguagePill(),
                      TextButton(
                        key: const Key('intro-skip'),
                        onPressed: widget.onDone,
                        child: Text(l.introSkip, style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _page,
                    itemCount: slides.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      final s = slides[i];
                      return LayoutBuilder(
                        builder: (context, c) {
                          final art = (c.maxHeight * 0.48).clamp(160.0, 300.0);
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: c.maxHeight),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _Art(size: art, icon: s.icon, orbit: s.orbit),
                                  const SizedBox(height: 28),
                                  Text(
                                    s.title,
                                    textAlign: TextAlign.center,
                                    style: t.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    s.body,
                                    textAlign: TextAlign.center,
                                    style: t.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.9), height: 1.45),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _index ? 26 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: i == _index ? 1 : 0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Column(
                    children: [
                      FilledButton(
                        key: const Key('intro-next'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F766E),
                          minimumSize: const Size.fromHeight(56),
                        ),
                        onPressed: () => last ? widget.onDone() : _page.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic),
                        child: Text(last ? l.introGetStarted : l.introNext),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                          const SizedBox(width: 6),
                          Text(l.introPrivacyNote, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Illustration: a big white disc with the main icon and three orbiting chips.
class _Art extends StatelessWidget {
  const _Art({required this.size, required this.icon, required this.orbit});
  final double size;
  final IconData icon;
  final List<(IconData, Color)> orbit;

  @override
  Widget build(BuildContext context) {
    final chip = size * 0.24;
    Widget orbitChip((IconData, Color) o) => Container(
      width: chip,
      height: chip,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(chip * 0.3),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Icon(o.$1, color: o.$2, size: chip * 0.55),
    );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.12)),
          ),
          Container(
            width: size * 0.54,
            height: size * 0.54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10))],
            ),
            child: Icon(icon, size: size * 0.28, color: const Color(0xFF0F766E)),
          ),
          Positioned(left: size * 0.02, top: size * 0.16, child: orbitChip(orbit[0])),
          Positioned(right: size * 0.0, top: size * 0.30, child: orbitChip(orbit[1])),
          Positioned(left: size * 0.16, bottom: size * 0.02, child: orbitChip(orbit[2])),
        ],
      ),
    );
  }
}
