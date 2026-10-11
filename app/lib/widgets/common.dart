import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/gen/app_localizations.dart';
import '../data/providers.dart';
import 'ui.dart';

/// Shown on every main screen while synthetic demo data exists (spec 3, 8.9).
class SyntheticBanner extends ConsumerWidget {
  const SyntheticBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(containsSyntheticProvider)) return const SizedBox.shrink();
    return Container(
      key: const Key('synthetic-banner'),
      width: double.infinity,
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)])),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, color: Color(0xFFC2410C), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context).syntheticBanner,
              style: const TextStyle(color: Color(0xFF9A3412), fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: c), const SizedBox(width: 3)],
          Text(
            text,
            style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w700),
          ),
        ],
      ),
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.errorContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.error.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBlob(Icons.error_outline_rounded, color: scheme.error, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            if (onRetry != null || extra != null) const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (onRetry != null)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: scheme.error, minimumSize: const Size(0, 44)),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(l.actionRetry),
                  ),
                ?extra,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message, this.action, this.color});
  final IconData icon;
  final String message;
  final Widget? action;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    final content = Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [c.withValues(alpha: 0.22), c.withValues(alpha: 0.04)]),
            ),
            child: Icon(icon, size: 52, color: c),
          ),
          const SizedBox(height: 18),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4)),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
    // Scroll only when given a bounded height (full-page use); inside a list, lay out plainly.
    return LayoutBuilder(
      builder: (context, box) => box.hasBoundedHeight ? Center(child: SingleChildScrollView(child: content)) : Center(child: content),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8, left: 2),
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
    child: Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        if (trailing != null) ...[const SizedBox(width: 6), trailing!],
      ],
    ),
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

void showSnack(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));
