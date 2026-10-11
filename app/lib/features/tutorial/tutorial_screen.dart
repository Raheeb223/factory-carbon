import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../widgets/language_switch.dart';
import 'speech.dart';

class _Step {
  const _Step(this.icon, this.orbit, this.title, this.body, {this.art});
  final IconData icon;
  final List<(IconData, Color)> orbit;
  final String title;
  final String body;

  /// A small picture of the screen instead of the icon disc.
  final Widget Function(double size)? art;
}

/// Picture-first "How to use" guide: one big picture, a short sentence and a "Listen"
/// button per step, so it works for people who find reading hard. Shown on first run
/// and from Home/Settings. Once "Listen" is tapped, each next step is read aloud too.
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key, required this.onDone, this.firstRun = false});
  final VoidCallback onDone;
  final bool firstRun;

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _page = PageController();
  int _index = 0;
  bool _voice = false;

  @override
  void dispose() {
    Speech.instance.stop();
    _page.dispose();
    super.dispose();
  }

  List<_Step> _steps(AppLocalizations l) => [
    _Step(
      Icons.photo_camera_rounded,
      const [
        (Icons.bolt_rounded, FeatureColors.bills),
        (Icons.local_fire_department_rounded, FeatureColors.waste),
        (Icons.local_gas_station_rounded, FeatureColors.production),
      ],
      l.tut1Title,
      l.tut1Body,
    ),
    _Step(Icons.visibility_off_rounded, const [], l.tut2Title, l.tut2Body, art: (s) => _BillArt(size: s, hidden: true)),
    _Step(Icons.fact_check_rounded, const [], l.tut3Title, l.tut3Body, art: (s) => _BillArt(size: s, hidden: false)),
    _Step(
      Icons.precision_manufacturing_rounded,
      const [
        (Icons.checkroom_rounded, FeatureColors.production),
        (Icons.calendar_month_rounded, FeatureColors.bills),
        (Icons.edit_rounded, FeatureColors.carbon),
      ],
      l.tut4Title,
      l.tut4Body,
    ),
    _Step(
      Icons.co2_rounded,
      const [(Icons.picture_as_pdf_rounded, FeatureColors.waste), (Icons.bar_chart_rounded, FeatureColors.bills), (Icons.send_rounded, FeatureColors.carbon)],
      l.tut5Title,
      l.tut5Body,
    ),
    _Step(
      Icons.savings_rounded,
      const [
        (Icons.warning_amber_rounded, FeatureColors.waste),
        (Icons.wb_sunny_rounded, FeatureColors.solar),
        (Icons.solar_power_rounded, FeatureColors.production),
      ],
      l.tut6Title,
      l.tut6Body,
    ),
  ];

  String _spoken(_Step s) => '${s.title}. ${s.body}';

  void _onPage(int i, List<_Step> steps) {
    setState(() => _index = i);
    if (_voice) {
      Speech.instance.speak(_spoken(steps[i]), Localizations.localeOf(context));
    } else {
      Speech.instance.stop();
    }
  }

  void _finish() {
    Speech.instance.stop();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final t = Theme.of(context).textTheme;
    final steps = _steps(l);
    final last = _index == steps.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: BrandGradients.primary),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      if (!widget.firstRun)
                        IconButton(
                          onPressed: _finish,
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 10),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
                            child: const Icon(Icons.eco_rounded, color: Color(0xFF0F766E), size: 22),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          l.tutorialTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                      const LanguagePill(),
                      TextButton(
                        key: const Key('intro-skip'),
                        onPressed: _finish,
                        child: Text(l.introSkip, style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _page,
                    itemCount: steps.length,
                    onPageChanged: (i) => _onPage(i, steps),
                    itemBuilder: (context, i) {
                      final s = steps[i];
                      return LayoutBuilder(
                        builder: (context, c) {
                          final art = (c.maxHeight * 0.42).clamp(150.0, 280.0);
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: c.maxHeight),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      s.art?.call(art) ?? _Art(size: art, icon: s.icon, orbit: s.orbit),
                                      Positioned(left: 0, top: 0, child: _NumberBadge(n: fmt.number((i + 1).toDouble()))),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    l.tutorialStep(fmt.number((i + 1).toDouble()), fmt.number(steps.length.toDouble())),
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    s.title,
                                    textAlign: TextAlign.center,
                                    style: t.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    s.body,
                                    textAlign: TextAlign.center,
                                    style: t.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.95), height: 1.45, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 18),
                                  ListenButton(text: _spoken(s), onDark: true, onStarted: () => _voice = true),
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
                      for (var i = 0; i < steps.length; i++)
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
                      FilledButton.icon(
                        key: const Key('intro-next'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F766E),
                          minimumSize: const Size.fromHeight(58),
                          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        onPressed: () => last ? _finish() : _page.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic),
                        icon: Icon(last ? Icons.check_rounded : Icons.arrow_forward_rounded),
                        label: Text(last ? l.introGetStarted : l.introNext),
                      ),
                      if (widget.firstRun) ...[
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

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.n});
  final String n;

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFFBBF24),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Text(
      n,
      style: const TextStyle(color: Color(0xFF422006), fontWeight: FontWeight.w900, fontSize: 22),
    ),
  );
}

/// A big white disc with the main icon and three orbiting chips.
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
          if (orbit.length == 3) ...[
            Positioned(left: size * 0.02, top: size * 0.16, child: orbitChip(orbit[0])),
            Positioned(right: size * 0.0, top: size * 0.30, child: orbitChip(orbit[1])),
            Positioned(left: size * 0.16, bottom: size * 0.02, child: orbitChip(orbit[2])),
          ],
        ],
      ),
    );
  }
}

/// A little bill: with [hidden], the name lines are black boxes; otherwise the numbers
/// are highlighted with a green tick, as on the check screen.
class _BillArt extends StatelessWidget {
  const _BillArt({required this.size, required this.hidden});
  final double size;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final w = size * 0.78;
    Widget bar(double width, Color color, {double h = 10}) => Container(
      width: width,
      height: h,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
    );
    final grey = const Color(0xFFCBD5E1);
    Widget value(String text) => Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: hidden ? Colors.transparent : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(6),
        border: hidden ? null : Border.all(color: const Color(0xFF16A34A), width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: size * 0.075, color: const Color(0xFF0F172A)),
      ),
    );
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: w,
              padding: EdgeInsets.all(size * 0.06),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: FeatureColors.bills, size: size * 0.1),
                      bar(w * 0.45, grey, h: 8),
                    ],
                  ),
                  bar(w * 0.55, hidden ? Colors.black : grey, h: hidden ? 14 : 9),
                  bar(w * 0.65, hidden ? Colors.black : grey, h: hidden ? 14 : 9),
                  const SizedBox(height: 4),
                  value('1,097 kWh'),
                  value('৳ 16,054'),
                ],
              ),
            ),
            Positioned(
              right: -size * 0.04,
              bottom: -size * 0.04,
              child: Container(
                width: size * 0.26,
                height: size * 0.26,
                decoration: BoxDecoration(
                  color: hidden ? const Color(0xFF0F172A) : const Color(0xFF16A34A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(hidden ? Icons.visibility_off_rounded : Icons.check_rounded, color: Colors.white, size: size * 0.14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
