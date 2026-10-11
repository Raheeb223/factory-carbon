import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../domain/api_models.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../import_history/import_screen.dart';
import '../impact/action_catalog.dart';
import '../impact/impact_screen.dart';
import 'waste_chart.dart';
import 'waste_controller.dart';

/// One numbered check, with a button that adds the matching fix to the action plan.
class _InspectionRow extends ConsumerWidget {
  const _InspectionRow({required this.index, required this.inspection});
  final String index;
  final Inspection inspection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final (title, how) = inspectionText(l, inspection.code, inspection.title, inspection.detail);
    final action = actionForInspection(inspection.code);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(
        radius: 13,
        backgroundColor: FeatureColors.waste.withValues(alpha: 0.15),
        child: Text(index, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: FeatureColors.waste)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: tt.titleSmall),
          const SizedBox(height: 2),
          Text(how, style: tt.bodySmall?.copyWith(height: 1.35)),
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: OutlinedButton.icon(
                key: Key('waste-plan-${inspection.code}'),
                onPressed: () => addToPlan(ref, context, action.code),
                icon: const Icon(Icons.add_task_rounded, size: 18),
                label: Text(actionCodeTitle(l, action.code), maxLines: 2),
              ),
            ),
        ]),
      ),
    ]);
  }
}

/// Unusual electricity use: anomalies with an estimated extra cost (spec 8.6).
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
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const IconBlob(Icons.lightbulb_outline_rounded, color: FeatureColors.waste),
              const SizedBox(width: 12),
              Expanded(child: Text(l.wasteHowTitle, style: Theme.of(ctx).textTheme.titleLarge)),
            ]),
            const SizedBox(height: 14),
            Text(l.wasteHowBody, style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.45)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final tt = Theme.of(context).textTheme;
    final control = ref.watch(wasteControllerProvider);
    final cached = ref.watch(wasteResultProvider);
    final analyze = ref.read(wasteControllerProvider.notifier).analyze;
    final r = cached?.result;

    return ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 32), children: [
      Row(children: [
        Expanded(
          child: FilledButton.icon(
            key: const Key('waste-analyze'),
            style: FilledButton.styleFrom(backgroundColor: FeatureColors.waste, foregroundColor: Colors.white),
            onPressed: control.isLoading ? null : analyze,
            icon: control.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.manage_search_rounded),
            label: Text(l.wasteAnalyze),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          tooltip: l.wasteHowTitle,
          style: IconButton.styleFrom(minimumSize: const Size(52, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: () => _how(context),
          icon: const Icon(Icons.help_outline_rounded),
        ),
      ]),
      if (cached != null)
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Row(children: [
            Icon(Icons.schedule_rounded, size: 14, color: Theme.of(context).colorScheme.outline),
            const SizedBox(width: 4),
            Expanded(child: Text(l.lastUpdated(fmt.dateTime(cached.updatedAt)), style: tt.bodySmall)),
          ]),
        ),
      if (control.hasError && !control.isLoading) ErrorPanel(message: errorText(l, control.error!), onRetry: analyze, extra: cached != null ? Text(l.showingSaved) : null),
      if (r == null && !control.isLoading && !control.hasError)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SoftCard(
            child: Row(children: [
              const IconBlob(Icons.bolt_rounded, color: FeatureColors.waste, size: 46),
              const SizedBox(width: 14),
              Expanded(child: Text(l.tileWasteSub, style: tt.titleSmall)),
            ]),
          ),
        ),
      if (r != null && r.insufficient)
        SoftCard(
          key: const Key('waste-insufficient'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconBlob(Icons.hourglass_bottom_rounded, color: Colors.orange.shade800, size: 42),
              const SizedBox(width: 12),
              Expanded(child: Text(l.wasteInsufficient('${r.monthCount}', '${r.requiredMonths}'))),
            ]),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ImportScreen())),
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(l.wasteImportPrompt),
            ),
          ]),
        ),
      if (r != null && !r.insufficient) ...[
        const SizedBox(height: 12),
        SoftCard(
          gradient: r.flaggedMonths.isEmpty ? BrandGradients.calm : BrandGradients.waste,
          borderColor: Colors.transparent,
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
              child: Icon(r.flaggedMonths.isEmpty ? Icons.verified_rounded : Icons.warning_amber_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  r.flaggedMonths.isEmpty ? l.wasteAllGoodTitle : l.wasteAttentionTitle,
                  style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                ),
                Text(l.wasteFlaggedCount(r.flaggedMonths.length), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(r.usesProduction ? l.wasteMethodOls : l.wasteMethodMad, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
              ]),
            ),
          ]),
        ),
        SoftCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            WasteChart(months: r.months),
            const SizedBox(height: 8),
            Wrap(spacing: 14, runSpacing: 6, children: [
              LegendDot(color: SeriesColors.electricity, label: l.wasteActual),
              LegendDot(color: SeriesColors.expected, label: l.wasteExpected),
              LegendDot(color: Colors.blueGrey.withValues(alpha: 0.4), label: l.wasteBand),
              LegendDot(color: SeriesColors.flagged, label: l.wasteFlaggedCount(r.flaggedMonths.length)),
            ]),
          ]),
        ),
        if (r.flaggedMonths.isEmpty)
          SoftCard(
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
              const SizedBox(width: 12),
              Expanded(child: Text(l.wasteNoFlags)),
            ]),
          )
        else
          for (final m in r.months.where((m) => m.flagged))
            SoftCard(
              key: Key('waste-flag-${m.month}'),
              color: FeatureColors.waste.withValues(alpha: 0.06),
              borderColor: FeatureColors.waste.withValues(alpha: 0.25),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const IconBlob(Icons.bolt_rounded, color: SeriesColors.flagged, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(flagMessage(l, fmt, r, m), style: const TextStyle(height: 1.35)),
                    if (m.kwhPerUnit != null && m.expectedKwhPerUnit != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        l.wastePerUnit(fmt.number(m.kwhPerUnit, decimals: 3), fmt.number(m.expectedKwhPerUnit, decimals: 3)),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ]),
                ),
              ]),
            ),
        if (r.baselineKwhPerUnit != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: Text(l.wasteBaseline(fmt.number(r.baselineKwhPerUnit, decimals: 3)), style: tt.bodySmall),
          ),
        if (r.inspections.isNotEmpty)
          SoftCard(
            key: const Key('waste-checks'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const IconBlob(Icons.checklist_rounded, color: FeatureColors.waste, size: 40),
                const SizedBox(width: 12),
                Expanded(child: Text(l.wasteChecksTitle, style: tt.titleMedium)),
              ]),
              const SizedBox(height: 6),
              Text(l.wasteChecksIntro, style: tt.bodySmall),
              for (final (i, insp) in r.inspections.indexed) ...[
                const Divider(height: 22),
                _InspectionRow(index: fmt.number((i + 1).toDouble()), inspection: insp),
              ],
            ]),
          ),
      ],
    ]);
  }
}
