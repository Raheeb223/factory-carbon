import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/gen/app_localizations.dart';
import '../data/providers.dart';

/// Shown on every main screen while synthetic demo data exists (spec 3, 8.9).
class SyntheticBanner extends ConsumerWidget {
  const SyntheticBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(containsSyntheticProvider)) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('synthetic-banner'),
      width: double.infinity,
      color: scheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Icon(Icons.science_outlined, color: scheme.onErrorContainer, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(AppLocalizations.of(context).syntheticBanner, style: TextStyle(color: scheme.onErrorContainer)),
        ),
      ]),
    );
  }
}

class Badge2 extends StatelessWidget {
  const Badge2(this.text, {super.key, this.color, this.icon});
  final String text;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: c), borderRadius: BorderRadius.circular(4)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 12, color: c), const SizedBox(width: 3)],
        Text(text, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class UnverifiedBadge extends StatelessWidget {
  const UnverifiedBadge({super.key});
  @override
  Widget build(BuildContext context) => Badge2(
        AppLocalizations.of(context).unverifiedFactorBadge,
        color: Colors.orange.shade800,
        icon: Icons.warning_amber_rounded,
        key: const Key('unverified-badge'),
      );
}

class SyntheticBadge extends StatelessWidget {
  const SyntheticBadge({super.key});
  @override
  Widget build(BuildContext context) =>
      Badge2(AppLocalizations.of(context).syntheticBadge, color: Theme.of(context).colorScheme.error, icon: Icons.science_outlined);
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.message, this.onRetry, this.extra});
  final String message;
  final VoidCallback? onRetry;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ]),
          if (onRetry != null || extra != null) const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            if (onRetry != null) FilledButton.tonal(onPressed: onRetry, child: Text(l.actionRetry)),
            ?extra,
          ]),
        ]),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message, this.action});
  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ]),
        ),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class LabeledValue extends StatelessWidget {
  const LabeledValue(this.label, this.value, {super.key, this.trailing});
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ]),
      );
}

Future<bool> confirmDialog(BuildContext context, {required String title, required String body, required String confirm, bool destructive = false}) async {
  final l = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error) : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showSnack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(text)));
