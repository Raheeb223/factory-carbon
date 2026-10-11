import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../widgets/co2_explainer.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../export/export_service.dart';
import '../import_history/import_screen.dart';
import 'carbon_chart.dart';
import 'carbon_controller.dart';

/// Carbon report (spec 8.5). Shows the cached result offline with a "last updated" label.
class CarbonView extends ConsumerStatefulWidget {
  const CarbonView({super.key});

  @override
  ConsumerState<CarbonView> createState() => _CarbonViewState();
}

class _CarbonViewState extends ConsumerState<CarbonView> {
  bool _exporting = false;

  Future<void> _export(Future<void> Function(ExportService s) run) async {
    final l = AppLocalizations.of(context);
    setState(() => _exporting = true);
    try {
      await run(ref.read(exportServiceProvider));
    } catch (e) {
      if (mounted) showSnack(context, errorText(l, e));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _noteText(AppLocalizations l, DataQualityNote n) => switch (n.code) {
        'missing_electricity_data' => l.noteMissingData(l.factorGrid),
        'missing_diesel_data' => l.noteMissingData(l.factorDiesel),
        'missing_gas_data' => l.noteMissingData(l.factorGas),
        'months_without_data' => l.noteMonthsWithoutData,
        'missing_production' => l.noteMissingProduction,
        'multiple_entries_same_month' => l.noteMultipleEntries,
        'user_edited_values' => l.noteUserEdited,
        'manual_entries' => l.noteManualEntries,
        'imported_history' => l.noteImportedHistory,
        'synthetic_data' => l.noteSyntheticData,
        'placeholder_factors' => l.notePlaceholderFactors,
        'incomplete_totals' => l.noteIncompleteTotals,
        'no_data' => l.noteNoData,
        _ => n.message,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final control = ref.watch(carbonControllerProvider);
    final cached = ref.watch(carbonResultProvider);
    final stale = ref.watch(carbonStaleProvider);
    final bills = ref.watch(billsProvider).value ?? const [];
    final unit = unitLabel(l, ref.watch(factoryProvider).value?.productionUnitLabel);
    final loading = control.isLoading;
    final refresh = ref.read(carbonControllerProvider.notifier).refresh;

    if (bills.isEmpty && cached == null) {
      return EmptyState(
        icon: Icons.co2_rounded,
        color: FeatureColors.carbon,
        message: l.carbonNoData,
        action: FilledButton.tonalIcon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ImportScreen())),
          icon: const Icon(Icons.upload_file_outlined),
          label: Text(l.homeImportHistory),
        ),
      );
    }

    final r = cached?.result;
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 32), children: [
        FilledButton.icon(
          key: const Key('carbon-refresh'),
          onPressed: loading ? null : refresh,
          icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_graph_rounded),
          label: Text(l.carbonCalculate),
        ),
        if (cached != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(children: [
              Icon(Icons.schedule_rounded, size: 14, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 4),
              Expanded(child: Text(l.lastUpdated(fmt.dateTime(cached.updatedAt)), style: Theme.of(context).textTheme.bodySmall)),
            ]),
          ),
        if (control.hasError && !loading)
          ErrorPanel(message: errorText(l, control.error!), onRetry: refresh, extra: cached != null ? Text(l.showingSaved) : null)
        else if (stale && !loading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusPill(key: const Key('carbon-stale'), text: l.carbonStale, color: Colors.orange.shade800, icon: Icons.update_rounded),
            ),
          ),
        if (r != null) ..._result(context, l, fmt, r, unit),
      ]),
    );
  }

  List<Widget> _result(BuildContext context, AppLocalizations l, Fmt fmt, CarbonResult r, String unit) {
    final t = r.totals;
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final placeholder = r.placeholdersInUse.isNotEmpty;
    String tonnes(double? v) => v == null ? l.notAvailable : l.tonnesCo2e(fmt.tonnes(v));
    Widget whiteBadge() => Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: const UnverifiedBadge(),
        );
    Widget scopeRow(Color dot, String label, double? v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            Flexible(
              fit: FlexFit.tight,
              child: Wrap(alignment: WrapAlignment.end, crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, runSpacing: 4, children: [
                Text(tonnes(v), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                if (placeholder && v != null) whiteBadge(),
              ]),
            ),
          ]),
        );
    return [
      const SizedBox(height: 12),
      for (final e in r.errors)
        SoftCard(
          key: const Key('factor-not-set'),
          color: scheme.errorContainer.withValues(alpha: 0.6),
          child: Row(children: [
            IconBlob(Icons.block_rounded, color: scheme.error, size: 38),
            const SizedBox(width: 12),
            Expanded(child: Text(l.carbonFactorNotSet(factorLabel(l, e.factor)))),
          ]),
        ),
      SoftCard(
        gradient: BrandGradients.calm,
        borderColor: Colors.transparent,
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.carbonTotal, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(tonnes(t.totalT), style: tt.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          if (r.periodStart != null)
            Text('${fmt.month(r.periodStart!)} – ${fmt.month(r.periodEnd!)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
          if (t.totalT != null) ...[
            const SizedBox(height: 8),
            Co2Plain(tonnes: t.totalT!),
          ],
          const SizedBox(height: 14),
          SplitBar(parts: [(t.scope2T ?? 0, const Color(0xFFBAE6FD)), (t.scope1T ?? 0, const Color(0xFFFDE68A))], height: 10),
          const SizedBox(height: 10),
          scopeRow(const Color(0xFFFDE68A), l.carbonScope1, t.scope1T),
          scopeRow(const Color(0xFFBAE6FD), l.carbonScope2, t.scope2T),
          if (t.intensity != null) ...[
            Divider(color: Colors.white.withValues(alpha: 0.3), height: 20),
            Row(children: [
              Expanded(child: Text(l.carbonIntensity(unit), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
              Text(tonnes(t.intensity), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ]),
          ],
          const SizedBox(height: 8),
          Text(
            l.monthsSummary('${t.monthsWithData}', '${t.monthsInPeriod}', '${t.completeMonths}'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
        ]),
      ),
      SoftCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.carbonMonthly, style: tt.titleMedium),
          const SizedBox(height: 12),
          CarbonMonthlyChart(months: r.months),
          const SizedBox(height: 8),
          Wrap(spacing: 14, runSpacing: 6, children: [
            LegendDot(color: SeriesColors.electricity, label: l.legendElectricity),
            LegendDot(color: SeriesColors.diesel, label: l.legendDiesel),
            LegendDot(color: SeriesColors.gas, label: l.legendGas),
          ]),
          const SizedBox(height: 6),
          Text(l.carbonPartialMonth, style: tt.bodySmall),
        ]),
      ),
      SectionHeader(l.settingsExport),
      Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.edit_note_rounded, size: 18, color: Colors.orange.shade800),
          const SizedBox(width: 6),
          Expanded(child: Text(l.draftReportNote, key: const Key('draft-note'), style: tt.bodySmall)),
        ]),
      ),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: _ExportTile(
            key: const Key('export-pdf'),
            icon: Icons.picture_as_pdf_rounded,
            color: const Color(0xFFDC2626),
            label: _exporting ? l.exporting : l.exportPdf,
            onTap: _exporting ? null : () => _export((s) => s.exportPdf()),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ExportTile(
            icon: Icons.table_chart_rounded,
            color: FeatureColors.carbon,
            label: l.exportCsv,
            onTap: _exporting ? null : () => _export((s) => s.exportEmissionsCsv(r)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ExportTile(
            icon: Icons.dataset_rounded,
            color: FeatureColors.bills,
            label: l.exportRaw,
            onTap: _exporting ? null : () => _export((s) => s.exportRawCsv()),
          ),
        ),
      ]),
      SectionHeader(l.carbonFactorsTitle),
      for (final f in r.factors.values)
        SoftCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(factorLabel(l, f.name), style: tt.titleSmall)),
              f.isPlaceholder ? const UnverifiedBadge() : Badge2(l.factorStatusVerified, color: Colors.green.shade700, icon: Icons.verified_rounded),
            ]),
            const SizedBox(height: 6),
            Text(f.value == null ? l.notSet : '${fmt.number(f.value, decimals: 4)} ${f.unit.replaceAll('_per_', '/').replaceAll('_', ' ')}', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            if (f.source.isNotEmpty) Text(l.factorSource(f.source), maxLines: 3, overflow: TextOverflow.ellipsis, style: tt.bodySmall),
            if (f.year != null) Text(l.factorYear('${f.year}'), style: tt.bodySmall),
            if (f.gases != null) Text(l.factorGases(f.gases!), style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
          ]),
        ),
      SectionHeader(l.carbonQualityTitle),
      SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: [
          for (final n in r.notes)
            ListTile(
              dense: true,
              leading: Icon(
                n.code == 'synthetic_data' || n.code == 'placeholder_factors' ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                color: n.code == 'synthetic_data' || n.code == 'placeholder_factors' ? Colors.orange.shade800 : scheme.primary,
              ),
              title: Text(_noteText(l, n)),
              subtitle: n.months.isEmpty ? null : Text(n.months.map(fmt.month).join(', ')),
            ),
        ]),
      ),
      SoftCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(Icons.menu_book_rounded, color: scheme.primary),
            title: Text(l.methodologyTitle, style: tt.titleSmall),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [Text(l.methodologyBody)],
          ),
        ),
      ),
    ];
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile({super.key, required this.icon, required this.color, required this.label, required this.onTap});
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: SoftCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          onTap: onTap,
          child: Column(children: [
            IconBlob(icon, color: color, size: 44),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
          ]),
        ),
      );
}
