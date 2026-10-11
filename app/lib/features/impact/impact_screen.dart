import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/drift_repositories.dart';
import '../../data/providers.dart';
import '../../domain/impact.dart';
import '../../domain/models.dart';
import '../../domain/requests.dart';
import '../../widgets/co2_explainer.dart';
import '../../widgets/common.dart';
import '../../widgets/month_picker.dart';
import '../../widgets/ui.dart';
import '../carbon/carbon_controller.dart';
import '../production/production_screen.dart';
import 'action_catalog.dart';

/// Grid factor from the latest carbon report (kg CO2 per kWh), if one was made.
final gridFactorProvider = Provider<double?>((ref) => ref.watch(carbonResultProvider)?.result.factors['grid_electricity']?.value);

/// Savings measured since the first completed action.
final overallImpactProvider = Provider<Impact>((ref) {
  final actions = ref.watch(actionsProvider).value ?? const [];
  return measureSince(
    firstDoneMonth(actions),
    bills: ref.watch(billsProvider).value ?? const [],
    production: ref.watch(productionProvider).value ?? const [],
    gridKgPerKwh: ref.watch(gridFactorProvider),
  );
});

/// Adds [code] to the action plan (planned), unless it is already there.
Future<void> addToPlan(WidgetRef ref, BuildContext context, String code) async {
  final l = AppLocalizations.of(context);
  final existing = ref.read(actionsProvider).value ?? const [];
  if (existing.any((a) => a.code == code)) {
    showSnack(context, l.actionAlreadyInPlan);
    return;
  }
  await ref.read(actionRepositoryProvider).save(EnergyAction(id: newId(), code: code, origin: DataOrigin.manual, updatedAt: DateTime.now()));
  if (context.mounted) showSnack(context, l.actionAdded);
}

/// Action plan + savings measured from the factory's own bills (Feature 4).
class ImpactView extends ConsumerWidget {
  const ImpactView({super.key});

  Future<void> _markDone(BuildContext context, WidgetRef ref, EnergyAction a) async {
    final month = await showMonthPicker(context, initial: a.doneMonth ?? monthOf(DateTime.now()));
    if (month == null || !context.mounted) return;
    final cost = await _askCost(context, a.costBdt);
    if (!context.mounted) return;
    await ref.read(actionRepositoryProvider).save(a.copyWith(doneMonth: month, costBdt: cost));
  }

  Future<double?> _askCost(BuildContext context, double? initial) async {
    final l = AppLocalizations.of(context);
    final c = TextEditingController(text: initial == null ? '' : initial.toStringAsFixed(0));
    final v = await showDialog<double?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.actionCostTitle),
        content: TextField(
          key: const Key('action-cost'),
          controller: c,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l.actionCostLabel, prefixText: 'Tk ', helperText: l.actionCostHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.actionSkip)),
          FilledButton(key: const Key('action-cost-save'), onPressed: () => Navigator.pop(ctx, parseNumber(c.text)), child: Text(l.actionSave)),
        ],
      ),
    );
    c.dispose();
    return v;
  }

  Future<void> _addCustom(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final c = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.actionCustomTitle),
        content: TextField(
          controller: c,
          autofocus: true,
          maxLength: 80,
          decoration: InputDecoration(hintText: l.actionCustomHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: Text(l.actionSave)),
        ],
      ),
    );
    c.dispose();
    if (title == null || title.isEmpty) return;
    await ref
        .read(actionRepositoryProvider)
        .save(EnergyAction(id: newId(), code: 'custom', title: title, origin: DataOrigin.manual, updatedAt: DateTime.now()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final actions = ref.watch(actionsProvider).value ?? const [];
    final bills = ref.watch(billsProvider).value ?? const [];
    final production = ref.watch(productionProvider).value ?? const [];
    final grid = ref.watch(gridFactorProvider);
    final impact = ref.watch(overallImpactProvider);
    final unit = unitLabel(l, ref.watch(factoryProvider).value?.productionUnitLabel);
    final inPlan = {for (final a in actions) a.code};

    Widget actionCard(EnergyAction a) {
      final kind = actionKind(a.code);
      final own = a.done ? measureSince(a.doneMonth, bills: bills, production: production, gridKgPerKwh: grid) : null;
      final monthlyBdt = own != null && own.status == ImpactStatus.measured && own.savedBdt != null && own.monthsAfter > 0
          ? own.savedBdt! / own.monthsAfter
          : null;
      return SoftCard(
        key: Key('action-${a.code}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBlob(kind?.icon ?? Icons.task_alt_rounded, color: a.done ? FeatureColors.carbon : FeatureColors.production, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(actionTitle(l, a), style: tt.titleSmall),
                      const SizedBox(height: 4),
                      StatusPill(
                        text: a.done ? l.actionDoneIn(fmt.month(a.doneMonth!)) : l.actionPlanned,
                        color: a.done ? const Color(0xFF16A34A) : scheme.outline,
                        icon: a.done ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    final repo = ref.read(actionRepositoryProvider);
                    if (v == 'undo') await repo.save(a.copyWith(clearDone: true));
                    if (v == 'delete') await repo.softDelete(a.id);
                  },
                  itemBuilder: (_) => [
                    if (a.done) PopupMenuItem(value: 'undo', child: Text(l.actionUndoDone)),
                    PopupMenuItem(value: 'delete', child: Text(l.actionRemove)),
                  ],
                ),
              ],
            ),
            if (kind != null && !a.done) ...[const SizedBox(height: 8), Text(actionCodeHow(l, a.code), style: tt.bodySmall?.copyWith(height: 1.35))],
            if (own != null) ...[
              const SizedBox(height: 8),
              Text(_impactLine(l, fmt, own, unit), style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              if (a.costBdt != null && monthlyBdt != null && monthlyBdt > 0)
                Text(l.actionPayback(fmt.number(a.costBdt), fmt.number(a.costBdt! / monthlyBdt, decimals: 1)), style: tt.bodySmall),
            ],
            if (!a.done) ...[
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                key: Key('action-done-${a.code}'),
                onPressed: () => _markDone(context, ref, a),
                icon: const Icon(Icons.task_alt_rounded),
                label: Text(l.actionMarkDone),
              ),
            ],
          ],
        ),
      );
    }

    final suggestions = [
      for (final k in actionCatalog)
        if (!inPlan.contains(k.code)) k,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        _ImpactHero(impact: impact, hasActions: actions.isNotEmpty),
        if (impact.status == ImpactStatus.noProduction)
          SoftCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProductionScreen())),
            child: Row(
              children: [
                const IconBlob(Icons.precision_manufacturing_rounded, color: FeatureColors.production, size: 40),
                const SizedBox(width: 12),
                Expanded(child: Text(l.impactNeedProduction)),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        if (impact.status == ImpactStatus.measured || impact.status == ImpactStatus.tooEarly)
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.impactChartTitle(unit), style: tt.titleMedium),
                const SizedBox(height: 12),
                _IntensityChart(bills: bills, production: production, start: impact.startMonth!, baseline: impact.baselineKwhPerUnit!),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    LegendDot(color: SeriesColors.expected, label: l.impactBefore),
                    LegendDot(color: FeatureColors.carbon, label: l.impactAfter),
                    LegendDot(color: Colors.orange.shade700, label: l.impactBaseline),
                  ],
                ),
                const SizedBox(height: 6),
                Text(l.impactMethod, style: tt.bodySmall),
              ],
            ),
          ),
        if (impact.status == ImpactStatus.measured && impact.savedKwh > 0)
          SoftCard(
            key: const Key('impact-community'),
            color: FeatureColors.carbon.withValues(alpha: 0.06),
            borderColor: FeatureColors.carbon.withValues(alpha: 0.25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconBlob(Icons.diversity_3_rounded, color: FeatureColors.carbon, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.impactCommunityTitle, style: tt.titleSmall),
                      const SizedBox(height: 4),
                      Text(l.impactCommunityBody, style: tt.bodySmall?.copyWith(height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        SectionHeader(
          l.actionPlanTitle,
          action: TextButton.icon(onPressed: () => _addCustom(context, ref), icon: const Icon(Icons.add_rounded), label: Text(l.actionAddOwn)),
        ),
        if (actions.isEmpty)
          SoftCard(
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(l.actionPlanEmpty)),
              ],
            ),
          ),
        for (final a in actions) actionCard(a),
        if (suggestions.isNotEmpty) SectionHeader(l.actionSuggestions),
        for (final k in suggestions)
          SoftCard(
            key: Key('suggest-${k.code}'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBlob(k.icon, color: FeatureColors.import, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(actionCodeTitle(l, k.code), style: tt.titleSmall),
                      const SizedBox(height: 2),
                      Text(actionCodeHow(l, k.code), style: tt.bodySmall?.copyWith(height: 1.35)),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  key: Key('suggest-add-${k.code}'),
                  tooltip: l.actionAddToPlan,
                  onPressed: () => addToPlan(ref, context, k.code),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _impactLine(AppLocalizations l, Fmt fmt, Impact i, String unit) => switch (i.status) {
    ImpactStatus.measured => l.actionResult(
      fmt.number(i.changePct, decimals: 1),
      fmt.number(i.baselineKwhPerUnit, decimals: 3),
      fmt.number(i.afterKwhPerUnit, decimals: 3),
      unit,
    ),
    ImpactStatus.tooEarly => l.impactTooEarly,
    ImpactStatus.noBaseline => l.impactNoBaseline,
    ImpactStatus.noProduction => l.impactNeedProduction,
    ImpactStatus.planned => '',
  };
}

/// Headline: money, electricity and CO2 saved since the first completed action.
class _ImpactHero extends StatelessWidget {
  const _ImpactHero({required this.impact, required this.hasActions});
  final Impact impact;
  final bool hasActions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final tt = Theme.of(context).textTheme;
    const white = TextStyle(color: Colors.white);
    if (impact.status != ImpactStatus.measured) {
      final text = switch (impact.status) {
        ImpactStatus.planned => hasActions ? l.impactNothingDone : l.impactIntro,
        ImpactStatus.tooEarly => l.impactTooEarly,
        ImpactStatus.noBaseline => l.impactNoBaseline,
        _ => l.impactNeedProduction,
      };
      return SoftCard(
        key: const Key('impact-hero'),
        gradient: BrandGradients.calm,
        borderColor: Colors.transparent,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.trending_down_rounded, color: Colors.white, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Text(text, style: white.copyWith(fontWeight: FontWeight.w600, height: 1.35)),
            ),
          ],
        ),
      );
    }
    final saved = impact.savedKwh;
    final positive = saved > 0;
    return SoftCard(
      key: const Key('impact-hero'),
      gradient: positive ? BrandGradients.calm : BrandGradients.waste,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.impactSince(fmt.month(impact.startMonth!)), style: white.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              impact.savedBdt == null ? l.impactKwhSaved(fmt.number(saved)) : l.impactTkSaved(fmt.number(impact.savedBdt)),
              style: tt.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 6),
          if (impact.savedBdt != null) Text(l.impactKwhLine(fmt.number(saved)), style: white.copyWith(fontWeight: FontWeight.w700)),
          Text(l.impactIntensityLine(fmt.number(impact.changePct, decimals: 1)), style: white),
          const SizedBox(height: 4),
          StatusPill(
            text: impact.settled ? l.impactMeasuredMonths(impact.monthsAfter) : l.impactEarly(impact.monthsAfter),
            color: Colors.white,
            icon: impact.settled ? Icons.verified_rounded : Icons.hourglass_bottom_rounded,
            onDark: true,
          ),
          if (positive && impact.savedCo2Kg != null) ...[
            const SizedBox(height: 10),
            Co2Plain(tonnes: impact.savedCo2Kg! / 1000),
          ] else if (positive)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l.impactCo2NeedsReport, style: white.copyWith(fontSize: 12.5)),
            ),
          const SizedBox(height: 8),
          Text(l.impactCaveat, style: white.copyWith(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}

/// kWh per unit produced each month: grey before the first action, green after, with
/// the baseline (average before) as an orange line.
class _IntensityChart extends StatelessWidget {
  const _IntensityChart({required this.bills, required this.production, required this.start, required this.baseline});
  final List<Bill> bills;
  final List<ProductionEntry> production;
  final String start;
  final double baseline;

  @override
  Widget build(BuildContext context) {
    final fmt = Fmt.of(context);
    final units = <String, double>{};
    for (final p in production) {
      units[p.month] = (units[p.month] ?? 0) + p.unitsProduced;
    }
    final rows = [
      for (final e in monthlyElectricity(bills))
        if ((units[e.month] ?? 0) > 0) (e.month, e.kwh / units[e.month]!),
    ];
    final shown = rows.length > 18 ? rows.sublist(rows.length - 18) : rows;
    final step = (shown.length / 6).ceil().clamp(1, 12);
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: [
            for (var i = 0; i < shown.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: shown[i].$2,
                    width: 9,
                    borderRadius: BorderRadius.circular(3),
                    color: shown[i].$1.compareTo(start) > 0
                        ? FeatureColors.carbon
                        : (shown[i].$1 == start ? Colors.orange.shade300 : SeriesColors.expected.withValues(alpha: 0.6)),
                  ),
                ],
              ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(y: baseline, color: Colors.orange.shade700, strokeWidth: 2, dashArray: [6, 4]),
            ],
          ),
          gridData: const FlGridData(drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (g, _, rod, _) =>
                  BarTooltipItem('${fmt.month(shown[g.x].$1)}\n${fmt.number(rod.toY, decimals: 3)}', const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(fmt.number(v, decimals: 2), style: const TextStyle(fontSize: 10)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= shown.length || i % step != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(fmt.month(shown[i].$1), style: const TextStyle(fontSize: 9)),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stand-alone page (from Home) around [ImpactView].
class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.impactTitle)),
      body: const Column(
        children: [
          SyntheticBanner(),
          Expanded(child: ImpactView()),
        ],
      ),
    );
  }
}
