import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../domain/api_models.dart';
import '../../widgets/common.dart';
import '../import_history/import_screen.dart';
import 'waste_chart.dart';
import 'waste_controller.dart';

/// Electricity waste alerts (spec 8.6).
class WasteView extends ConsumerWidget {
  const WasteView({super.key});

  /// Localized plain-language message built from structured fields.
  static String flagMessage(AppLocalizations l, Fmt fmt, WasteResult r, WasteMonth m) {
    final cost = m.excessCostBdt == null ? l.wasteNoCost : l.wasteCostPart(fmt.number(m.excessCostBdt));
    final pct = fmt.number(m.excessPct, decimals: 0);
    final kwh = fmt.number(m.excessKwh);
    final month = fmt.monthLong(m.month);
    return r.usesProduction ? l.wasteFlagMessage(month, pct, kwh, cost) : l.wasteFlagMessageMad(month, pct, kwh, cost);
  }

  void _how(BuildContext context) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.wasteHowTitle, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(l.wasteHowBody),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final control = ref.watch(wasteControllerProvider);
    final cached = ref.watch(wasteResultProvider);
    final analyze = ref.read(wasteControllerProvider.notifier).analyze;
    final r = cached?.result;

    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Expanded(
          child: FilledButton.icon(
            key: const Key('waste-analyze'),
            onPressed: control.isLoading ? null : analyze,
            icon: control.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.bolt),
            label: Text(l.wasteAnalyze),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(tooltip: l.wasteHowTitle, onPressed: () => _how(context), icon: const Icon(Icons.help_outline)),
      ]),
      if (cached != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.lastUpdated(fmt.dateTime(cached.updatedAt)), style: Theme.of(context).textTheme.bodySmall)),
      if (control.hasError && !control.isLoading) ErrorPanel(message: errorText(l, control.error!), onRetry: analyze, extra: cached != null ? Text(l.showingSaved) : null),
      if (r != null && r.insufficient)
        Card(
          key: const Key('waste-insufficient'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.wasteInsufficient('${r.monthCount}', '${r.requiredMonths}')),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ImportScreen())),
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(l.wasteImportPrompt),
              ),
            ]),
          ),
        ),
      if (r != null && !r.insufficient) ...[
        const SizedBox(height: 12),
        Card(
          color: r.usesProduction ? null : Colors.orange.withValues(alpha: 0.12),
          child: ListTile(
            leading: Icon(r.usesProduction ? Icons.precision_manufacturing_outlined : Icons.warning_amber_rounded),
            title: Text(r.usesProduction ? l.wasteMethodOls : l.wasteMethodMad),
            subtitle: Text(l.wasteFlaggedCount(r.flaggedMonths.length)),
          ),
        ),
        const SizedBox(height: 8),
        WasteChart(months: r.months),
        Wrap(spacing: 12, children: [
          _legend(SeriesColors.electricity, l.wasteActual),
          _legend(SeriesColors.expected, l.wasteExpected),
          _legend(Colors.blueGrey.withValues(alpha: 0.4), l.wasteBand),
          _legend(SeriesColors.flagged, l.wasteFlaggedCount(r.flaggedMonths.length)),
        ]),
        const SizedBox(height: 12),
        if (r.flaggedMonths.isEmpty)
          ListTile(leading: const Icon(Icons.check_circle_outline, color: Colors.green), title: Text(l.wasteNoFlags))
        else
          for (final m in r.months.where((m) => m.flagged))
            Card(
              key: Key('waste-flag-${m.month}'),
              child: ListTile(
                leading: const Icon(Icons.bolt, color: SeriesColors.flagged),
                title: Text(flagMessage(l, fmt, r, m)),
              ),
            ),
      ],
    ]);
  }

  Widget _legend(Color c, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, color: c),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ]);
}
