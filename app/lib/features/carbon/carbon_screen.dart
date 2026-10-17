import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/carbon_summary.dart';
import '../../domain/impact.dart';
import '../../domain/models.dart';
import '../../domain/report_period.dart';
import '../../domain/requests.dart';
import '../../widgets/auto_run.dart';
import '../../widgets/co2_explainer.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../export/export_service.dart';
import '../bills/bills_screen.dart' show billColor, billIcon;
import '../import_history/import_screen.dart';
import '../target/target_card.dart';
import '../tutorial/speech.dart';
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
        'missing_lpg_data' => l.noteMissingData(l.factorLpg),
        'missing_furnace_oil_data' => l.noteMissingData(l.factorFurnaceOil),
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
    final production = ref.watch(productionProvider).value ?? const [];
    final period = ref.watch(reportPeriodProvider);
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
    return AutoRun(
      trigger: ref.watch(carbonInputHashProvider),
      enabled: bills.isNotEmpty && (cached == null || stale) && !loading,
      run: refresh,
      child: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 32), children: [
          _PeriodPicker(
            period: period,
            options: availablePeriods([for (final b in bills) b.billingMonth, for (final p in production) p.month]),
            onChanged: (p) async {
              await ref.read(reportPeriodProvider.notifier).set(p);
              if (bills.isNotEmpty) await refresh();
            },
          ),
          const SizedBox(height: 10),
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
          if (r != null)
            ..._result(context, l, fmt, r, unit, averagePrice(bills), previous: cached!.previous, partial: period.isPartial(lastDataMonth(bills, production))),
        ]),
      ),
    );
  }

  List<Widget> _result(
    BuildContext context,
    AppLocalizations l,
    Fmt fmt,
    CarbonResult r,
    String unit,
    double? priceBdtPerKwh, {
    CarbonResult? previous,
    bool partial = false,
  }) {
    final t = r.totals;
    final s = CarbonSummary(r);
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
            Text(
              '${fmt.month(r.periodStart!)} – ${fmt.month(r.periodEnd!)}${partial ? ' · ${l.periodSoFar}' : ''}',
              key: const Key('carbon-period-range'),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
            ),
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
      if (previous != null) _Comparison(current: r, previous: previous, unit: unit),
      const TargetCard(),
      if (s.lines.isNotEmpty) ...[
        _PlainWords(lines: carbonPlainWords(l, fmt, s, unit)),
        _Calculation(summary: s),
        if (r.energy case final e?) _EnergyCard(energy: e),
        if (s.tenPercentLessElectricity() case final cut?)
          SoftCard(
            key: const Key('carbon-cut'),
            color: FeatureColors.carbon.withValues(alpha: 0.06),
            borderColor: FeatureColors.carbon.withValues(alpha: 0.25),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const IconBlob(Icons.trending_down_rounded, color: FeatureColors.carbon, size: 38),
                const SizedBox(width: 12),
                Expanded(child: Text(l.carbonCutTitle, style: tt.titleMedium)),
              ]),
              const SizedBox(height: 8),
              Text(
                priceBdtPerKwh == null
                    ? l.carbonCutNoTk(fmt.number(cut.kwh), fmt.tonnes(cut.tonnes))
                    : l.carbonCutTk(fmt.number(cut.kwh), fmt.number(cut.kwh * priceBdtPerKwh), fmt.tonnes(cut.tonnes)),
                style: tt.bodyLarge,
              ),
              if (DefaultTabController.maybeOf(context) != null) ...[
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  key: const Key('carbon-see-actions'),
                  onPressed: () => DefaultTabController.of(context).animateTo(2),
                  icon: const Icon(Icons.checklist_rounded),
                  label: Text(l.carbonCutButton),
                ),
              ],
            ]),
          ),
      ],
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
            if (r.months.any((m) => m.lpgKg != null)) LegendDot(color: SeriesColors.lpg, label: l.legendLpg),
            if (r.months.any((m) => m.furnaceOilLitres != null)) LegendDot(color: SeriesColors.furnaceOil, label: l.legendFurnaceOil),
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
      FilledButton.icon(
        key: const Key('share-summary'),
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A), minimumSize: const Size.fromHeight(50)),
        onPressed: () => SharePlus.instance.share(ShareParams(
          text: shareSummaryText(
            l,
            fmt,
            r,
            previous,
            unit,
            factoryName: ref.read(factoryProvider).value?.name,
            electricityCostBdt: electricityCostIn(ref.read(billsProvider).value ?? const [], r.periodStart, r.periodEnd),
          ),
        )),
        icon: const Icon(Icons.share_rounded),
        label: Text(l.shareSummary),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
        child: Text(l.shareSummaryHint, style: tt.bodySmall),
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
              Expanded(child: Text(capitalized(factorLabel(l, f.name)), style: tt.titleSmall)),
              f.isPlaceholder ? const UnverifiedBadge() : Badge2(l.factorStatusVerified, color: Colors.green.shade700, icon: Icons.verified_rounded),
            ]),
            const SizedBox(height: 6),
            Text(f.value == null ? l.notSet : '${fmt.number(f.value, decimals: 4)} ${f.unit.replaceAll('_per_', '/').replaceAll('_', ' ')}',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
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

String periodLabel(AppLocalizations l, ReportPeriod p) => switch (p.kind) {
      PeriodKind.all => l.periodAll,
      PeriodKind.calendarYear => l.periodCalendar('${p.year}'),
      PeriodKind.fiscalYear => l.periodFiscal('${p.year}–${((p.year + 1) % 100).toString().padLeft(2, '0')}'),
    };

class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.period, required this.options, required this.onChanged});
  final ReportPeriod period;
  final List<ReportPeriod> options;
  final ValueChanged<ReportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = options.contains(period) ? options : [...options, period];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<ReportPeriod>(
          key: const Key('carbon-period'),
          initialValue: period,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.periodLabel, prefixIcon: const Icon(Icons.date_range_rounded)),
          items: [
            for (final p in all)
              DropdownMenuItem(
                value: p,
                child: Text(periodLabel(l, p), overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (p) {
            if (p != null && p != period) onChanged(p);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 4),
          child: Text(l.periodHint, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

/// This period against the same months one year earlier: total and CO2 per unit.
class _Comparison extends StatelessWidget {
  const _Comparison({required this.current, required this.previous, required this.unit});
  final CarbonResult current;
  final CarbonResult previous;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final tt = Theme.of(context).textTheme;
    Widget row(String label, double? before, double? now) {
      final pct = percentChange(before, now);
      final (text, color, icon) = switch (pct) {
        null => (l.notAvailable, Theme.of(context).colorScheme.outline, Icons.remove_rounded),
        final p when p.abs() < 0.5 => (l.compareSame, Theme.of(context).colorScheme.outline, Icons.remove_rounded),
        final p when p < 0 => (l.compareDown(fmt.number(-p)), const Color(0xFF16A34A), Icons.south_east_rounded),
        final p => (l.compareUp(fmt.number(p)), const Color(0xFFDC2626), Icons.north_east_rounded),
      };
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: tt.titleSmall),
                  Text('${fmt.tonnes(before)} → ${fmt.tonnes(now)} t', style: tt.bodySmall),
                ],
              ),
            ),
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              text,
              style: tt.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    final gaps = previous.totals.monthsWithData < previous.totals.monthsInPeriod || current.totals.monthsWithData < current.totals.monthsInPeriod;
    return SoftCard(
      key: const Key('carbon-compare'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows_rounded, color: FeatureColors.carbon),
              const SizedBox(width: 10),
              Expanded(child: Text(l.compareTitle, style: tt.titleMedium)),
            ],
          ),
          if (previous.periodStart != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(l.compareWith(fmt.month(previous.periodStart!), fmt.month(previous.periodEnd!)), style: tt.bodySmall),
            ),
          const SizedBox(height: 6),
          row(l.carbonTotal, previous.totals.totalT, current.totals.totalT),
          row(l.carbonIntensity(unit), previous.totals.intensity, current.totals.intensity),
          const SizedBox(height: 4),
          Text(l.compareNote(unit), style: tt.bodySmall),
          if (gaps) ...[
            const SizedBox(height: 4),
            Text(
              l.compareGaps,
              key: const Key('carbon-compare-gaps'),
              style: tt.bodySmall?.copyWith(color: Colors.orange.shade900),
            ),
          ],
        ],
      ),
    );
  }
}

/// Total electricity bill amount for the months from [start] to [end]; null unless every
/// month with an electricity bill has its amount.
double? electricityCostIn(List<Bill> bills, String? start, String? end) {
  if (start == null || end == null) return null;
  final months = [for (final e in monthlyElectricity(bills)) if (e.month.compareTo(start) >= 0 && e.month.compareTo(end) <= 0) e];
  if (months.isEmpty || months.any((e) => e.costBdt == null)) return null;
  return months.fold<double>(0, (a, e) => a + e.costBdt!);
}

/// A short message for WhatsApp or SMS: the plain-words report, the change from a year
/// earlier and the electricity cost, in the app's language.
String shareSummaryText(
  AppLocalizations l,
  Fmt fmt,
  CarbonResult r,
  CarbonResult? previous,
  String unit, {
  String? factoryName,
  double? electricityCostBdt,
}) {
  final s = CarbonSummary(r);
  final change = percentChange(previous?.totals.totalT, r.totals.totalT);
  final cost = electricityCostBdt;
  return [
    ?factoryName,
    l.shareHeading,
    if (r.periodStart != null) '${fmt.month(r.periodStart!)} – ${fmt.month(r.periodEnd!)}',
    '',
    for (final line in carbonPlainWords(l, fmt, s, unit)) '• $line',
    if (change != null && previous?.periodStart != null)
      '• ${l.shareCompare(change.abs() < 0.5 ? l.compareSame : (change < 0 ? l.compareDown(fmt.number(-change)) : l.compareUp(fmt.number(change))), fmt.month(previous!.periodStart!), fmt.month(previous.periodEnd!))}',
    if (cost != null) '• ${l.shareCost(fmt.number(cost))}',
    '',
    l.shareFooter,
  ].join('\n');
}

String sourceLabel(AppLocalizations l, CarbonSource s) => switch (s) {
      CarbonSource.electricity => l.legendElectricity,
      CarbonSource.diesel => l.legendDiesel,
      CarbonSource.gas => l.legendGas,
      CarbonSource.lpg => l.legendLpg,
      CarbonSource.furnaceOil => l.legendFurnaceOil,
    };

/// The report in a few plain sentences.
List<String> carbonPlainWords(AppLocalizations l, Fmt fmt, CarbonSummary s, String unit) {
  final r = s.r;
  final t = r.totals;
  final big = s.biggest;
  final peak = s.peakMonth;
  return [
    if (r.periodStart != null && t.totalT != null && s.perMonth != null)
      l.carbonSay1(fmt.month(r.periodStart!), fmt.month(r.periodEnd!), fmt.tonnes(t.totalT), fmt.tonnes(s.perMonth)),
    if (big != null) l.carbonSay2(sourceLabel(l, big.source), fmt.number(s.share(big) * 100)),
    if (t.intensity != null) l.carbonSay3(unit, fmt.tonnes(t.intensity)),
    if (peak != null && r.months.length > 1) l.carbonSay4(fmt.monthLong(peak.month), fmt.tonnes(peak.totalT)),
  ];
}

class _PlainWords extends StatelessWidget {
  const _PlainWords({required this.lines});
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return SoftCard(
      key: const Key('carbon-plain'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.chat_bubble_outline_rounded, color: FeatureColors.carbon),
          const SizedBox(width: 10),
          Expanded(child: Text(l.carbonPlainTitle, style: tt.titleMedium)),
        ]),
        const SizedBox(height: 8),
        for (final line in lines) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(line, style: tt.bodyLarge)),
        const SizedBox(height: 4),
        ListenButton(key: const Key('carbon-listen'), text: lines.join(' ')),
      ]),
    );
  }
}

/// "Units × factor = tonnes" for each energy source, adding up to the total.
class _Calculation extends StatelessWidget {
  const _Calculation({required this.summary});
  final CarbonSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    (String, String, Color, IconData) look(CarbonSource s) => switch (s) {
          CarbonSource.electricity => (l.carbonUnitKwh, l.carbonUnitKwh, SeriesColors.electricity, Icons.bolt_rounded),
          CarbonSource.diesel => (l.carbonUnitLitre, l.carbonUnitLitreOne, SeriesColors.diesel, Icons.local_gas_station_rounded),
          CarbonSource.gas => (l.carbonUnitM3, l.carbonUnitM3, SeriesColors.gas, Icons.local_fire_department_rounded),
          CarbonSource.lpg => (l.carbonUnitKg, l.carbonUnitKg, SeriesColors.lpg, Icons.propane_tank_rounded),
          CarbonSource.furnaceOil => (l.carbonUnitLitre, l.carbonUnitLitreOne, SeriesColors.furnaceOil, Icons.oil_barrel_rounded),
        };
    return SoftCard(
      key: const Key('carbon-calc'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.calculate_outlined, color: FeatureColors.carbon),
          const SizedBox(width: 10),
          Expanded(child: Text(l.carbonCalcTitle, style: tt.titleMedium)),
        ]),
        Text(l.carbonCalcHint, style: tt.bodySmall),
        const SizedBox(height: 10),
        for (final line in summary.lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconBlob(look(line.source).$4, color: look(line.source).$3, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    '${sourceLabel(l, line.source)} · ${line.source == CarbonSource.electricity ? l.scope2Short : l.scope1Short}',
                    style: tt.titleSmall,
                  ),
                  Text(
                    line.factorKg == null
                        ? '${fmt.number(line.amount)} ${look(line.source).$1}'
                        : l.carbonCalcLine(fmt.number(line.amount), look(line.source).$1, fmt.number(line.factorKg, decimals: 2), look(line.source).$2),
                    style: tt.bodyMedium,
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Text(l.carbonCalcResult(fmt.tonnes(line.tonnes)), style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            ]),
          ),
        Divider(color: scheme.outlineVariant),
        Row(children: [
          Expanded(child: Text(l.carbonCalcTotal, style: tt.titleSmall)),
          Text(l.carbonCalcResult(fmt.tonnes(summary.totalT)), style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 6),
        Text(l.carbonCalcNote, style: tt.bodySmall),
      ]),
    );
  }
}

/// Energy used per source in MWh and GJ, as buyer questionnaires (Higg FEM, CDP) ask for it.
class _EnergyCard extends StatelessWidget {
  const _EnergyCard({required this.energy});
  final EnergySummary energy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      key: const Key('carbon-energy'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.local_fire_department_outlined, color: FeatureColors.carbon),
          const SizedBox(width: 10),
          Expanded(child: Text(l.energyTitle, style: tt.titleMedium)),
        ]),
        if (energy.totalKwh != null) ...[
          const SizedBox(height: 6),
          Text(
            l.energyTotal(fmt.number(energy.totalKwh! / 1000, decimals: 1), fmt.number(energy.totalGj, decimals: 0)),
            key: const Key('energy-total'),
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
        const SizedBox(height: 8),
        for (final e in energy.lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(billIcon(e.source), size: 18, color: billColor(e.source)),
                const SizedBox(width: 8),
                Expanded(child: Text(billTypeLabel(l, e.source), style: tt.titleSmall)),
                Text(e.kwh == null ? l.notAvailable : '${fmt.number(e.kwh! / 1000, decimals: 1)} MWh', style: tt.titleSmall),
                if (e.share != null) SizedBox(width: 56, child: Text('${fmt.number(e.share! * 100)}%', textAlign: TextAlign.end, style: tt.bodySmall)),
              ]),
              if (e.share != null)
                Padding(
                  padding: const EdgeInsets.only(left: 26, top: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: e.share, minHeight: 6, color: billColor(e.source), backgroundColor: scheme.surfaceContainerHighest),
                  ),
                ),
            ]),
          ),
        const SizedBox(height: 6),
        Text(energy.complete ? l.energyNote : l.energyIncomplete, style: tt.bodySmall),
      ]),
    );
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
            Text(label,
                textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
          ]),
        ),
      );
}
