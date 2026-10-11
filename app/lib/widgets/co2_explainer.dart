import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/l10n/gen/app_localizations.dart';
import '../features/tutorial/speech.dart';

/// CO2 one tree takes up in a year, roughly (kg). Used only for the "about N trees"
/// comparison, so the rough figure is fine.
const double kgCo2PerTreeYear = 22;

/// Plain-words lines under a tCO2e figure: "= 750 kg of CO2 gas" and "about 34 trees
/// would need a whole year to soak this up", plus a "What does this mean?" button.
class Co2Plain extends StatelessWidget {
  const Co2Plain({super.key, required this.tonnes, this.onDark = true});
  final double tonnes;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final kg = tonnes * 1000;
    final trees = (kg / kgCo2PerTreeYear).round().clamp(1, 1 << 31);
    final color = onDark ? Colors.white : Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.co2Kg(fmt.number(kg)),
          key: const Key('co2-kg'),
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.park_rounded, size: 18, color: onDark ? const Color(0xFFBBF7D0) : const Color(0xFF16A34A)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(l.co2Trees(fmt.number(trees.toDouble())), style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 13, height: 1.3)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          key: const Key('co2-explain'),
          style: TextButton.styleFrom(
            foregroundColor: color,
            backgroundColor: color.withValues(alpha: 0.14),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: () => showCo2Explainer(context),
          icon: const Icon(Icons.help_outline_rounded, size: 18),
          label: Text(l.co2Explain),
        ),
      ],
    );
  }
}

/// Bottom sheet that explains tCO2e, Scope 1 and Scope 2 in plain words, with a
/// read-aloud button.
Future<void> showCo2Explainer(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (ctx) {
    final l = AppLocalizations.of(ctx);
    final t = Theme.of(ctx).textTheme;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.85),
        child: SingleChildScrollView(
          key: const Key('co2-sheet'),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.co2_rounded, size: 36, color: Color(0xFF0F766E)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l.co2WhatTitle, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(l.co2WhatBody, style: t.bodyLarge?.copyWith(height: 1.45)),
              const SizedBox(height: 16),
              ListenButton(text: '${l.co2WhatTitle}. ${l.co2WhatBody}'),
            ],
          ),
        ),
      ),
    );
  },
);
