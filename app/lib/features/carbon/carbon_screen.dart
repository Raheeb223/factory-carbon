import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../widgets/common.dart';
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
    final unit = ref.watch(factoryProvider).value?.productionUnitLabel ?? 'units';
    final loading = control.isLoading;
    final refresh = ref.read(carbonControllerProvider.notifier).refresh;

    if (bills.isEmpty && cached == null) {
      return EmptyState(
        icon: Icons.co2_outlined,
        message: l.carbonNoData,
        action: FilledButton.tonal(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ImportScreen())),
          child: Text(l.homeImportHistory),
        ),
      );
    }

    final r = cached?.result;
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          Expanded(
            child: FilledButton.icon(
              key: const Key('carbon-refresh'),
              onPressed: loading ? null : refresh,
              icon: loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh),
              label: Text(l.carbonCalculate),
            ),
          ),
        ]),
        if (cached != null) ...[
          const SizedBox(height: 6),
          Text(l.lastUpdated(fmt.dateTime(cached.updatedAt)), style: Theme.of(context).textTheme.bodySmall),
        ],
        if (control.hasError && !loading)
          ErrorPanel(message: errorText(l, control.error!), onRetry: refresh, extra: cached != null ? Text(l.showingSaved) : null)
        else if (stale && !loading)
          Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.carbonStale, key: const Key('carbon-stale'), style: TextStyle(color: Colors.orange.shade800))),
        if (r != null) ..._result(context, l, fmt, r, unit),
      ]),
    );
  }

  List<Widget> _result(BuildContext context, AppLocalizations l, Fmt fmt, CarbonResult r, String unit) {
    final t = r.totals;
    final placeholder = r.placeholdersInUse.isNotEmpty;
    String tonnes(double? v) => v == null ? l.notAvailable : l.tonnesCo2e(fmt.tonnes(v));
    return [
      const SizedBox(height: 8),
      if (r.periodStart != null) Text('${fmt.month(r.periodStart!)} – ${fmt.month(r.periodEnd!)}', style: Theme.of(context).textTheme.titleMedium),
      for (final e in r.errors)
        Card(
          key: const Key('factor-not-set'),
          color: Theme.of(context).colorScheme.errorContainer,
          child: ListTile(leading: const Icon(Icons.block), title: Text(l.carbonFactorNotSet(factorLabel(l, e.factor)))),
        ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            LabeledValue(l.carbonScope1, tonnes(t.scope1T), trailing: placeholder && t.scope1T != null ? const UnverifiedBadge() : null),
            LabeledValue(l.carbonScope2, tonnes(t.scope2T), trailing: placeholder && t.scope2T != null ? const UnverifiedBadge() : null),
            const Divider(),
            LabeledValue(l.carbonTotal, tonnes(t.totalT)),
            if (t.intensity != null) LabeledValue(l.carbonIntensity(unit), tonnes(t.intensity)),
            const SizedBox(height: 4),
            Text(l.monthsSummary('${t.monthsWithData}', '${t.monthsInPeriod}', '${t.completeMonths}'), style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ),
      SectionTitle(l.carbonMonthly),
      CarbonMonthlyChart(months: r.months),
      Wrap(spacing: 12, children: [
        _legend(SeriesColors.electricity, l.legendElectricity),
        _legend(SeriesColors.diesel, l.legendDiesel),
        _legend(SeriesColors.gas, l.legendGas),
      ]),
      const SizedBox(height: 4),
      Text(l.carbonPartialMonth, style: Theme.of(context).textTheme.bodySmall),
      SectionTitle(l.carbonFactorsTitle),
      for (final f in r.factors.values)
        Card(
          child: ListTile(
            title: Row(children: [
              Expanded(child: Text(factorLabel(l, f.name))),
              f.isPlaceholder ? const UnverifiedBadge() : Badge2(l.factorStatusVerified, color: Colors.green.shade700),
            ]),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.value == null ? l.notSet : '${fmt.number(f.value, decimals: 4)} ${f.unit}', style: const TextStyle(fontWeight: FontWeight.w600)),
              if (f.source.isNotEmpty) Text(l.factorSource(f.source), maxLines: 3, overflow: TextOverflow.ellipsis),
              if (f.year != null) Text(l.factorYear('${f.year}')),
            ]),
          ),
        ),
      SectionTitle(l.carbonQualityTitle),
      for (final n in r.notes)
        ListTile(
          dense: true,
          leading: Icon(n.code == 'synthetic_data' || n.code == 'placeholder_factors' ? Icons.warning_amber_rounded : Icons.info_outline),
          title: Text(_noteText(l, n)),
          subtitle: n.months.isEmpty ? null : Text(n.months.map(fmt.month).join(', ')),
        ),
      SectionTitle(l.methodologyTitle),
      Text(l.methodologyBody),
      SectionTitle(l.settingsExport),
      Wrap(spacing: 8, runSpacing: 8, children: [
        FilledButton.icon(
          key: const Key('export-pdf'),
          onPressed: _exporting ? null : () => _export((s) => s.exportPdf()),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: Text(_exporting ? l.exporting : l.exportPdf),
        ),
        OutlinedButton.icon(
          onPressed: _exporting ? null : () => _export((s) => s.exportEmissionsCsv(r)),
          icon: const Icon(Icons.table_chart_outlined),
          label: Text(l.exportCsv),
        ),
        OutlinedButton.icon(
          onPressed: _exporting ? null : () => _export((s) => s.exportRawCsv()),
          icon: const Icon(Icons.dataset_outlined),
          label: Text(l.exportRaw),
        ),
      ]),
      const SizedBox(height: 32),
    ];
  }

  Widget _legend(Color c, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, color: c),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ]);
}
