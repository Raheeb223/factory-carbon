import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

/// English / বাংলা toggle. Labels are always shown in their own language so
/// anyone can find their language whatever is currently selected.
class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key, this.dense = false});
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider)?.languageCode ?? Localizations.localeOf(context).languageCode;
    return SegmentedButton<String>(
      showSelectedIcon: !dense,
      style: dense ? const ButtonStyle(visualDensity: VisualDensity.compact) : null,
      segments: const [
        ButtonSegment(value: 'en', label: Text('English'), icon: Icon(Icons.language)),
        ButtonSegment(value: 'bn', label: Text('বাংলা')),
      ],
      selected: {current == 'bn' ? 'bn' : 'en'},
      onSelectionChanged: (s) => ref.read(localeProvider.notifier).set(s.first),
    );
  }
}

/// Compact app-bar action that flips between English and Bangla.
class LanguageToggleAction extends ConsumerWidget {
  const LanguageToggleAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider)?.languageCode ?? Localizations.localeOf(context).languageCode;
    final toBangla = current != 'bn';
    return TextButton.icon(
      key: const Key('language-toggle'),
      onPressed: () => ref.read(localeProvider.notifier).set(toBangla ? 'bn' : 'en'),
      icon: const Icon(Icons.translate, size: 18),
      label: Text(toBangla ? 'বাংলা' : 'English'),
    );
  }
}

/// Language toggle pill for use on top of a gradient header.
class LanguagePill extends ConsumerWidget {
  const LanguagePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider)?.languageCode ?? Localizations.localeOf(context).languageCode;
    final toBangla = current != 'bn';
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const Key('language-toggle'),
        borderRadius: BorderRadius.circular(20),
        onTap: () => ref.read(localeProvider.notifier).set(toBangla ? 'bn' : 'en'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.translate_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(toBangla ? 'বাংলা' : 'English', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}
