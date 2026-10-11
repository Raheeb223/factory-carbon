import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/drift_repositories.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'solar_map_screen.dart';

/// Localized text for a backend solar warning code (English server text as fallback).
String solarWarningText(AppLocalizations l, Fmt fmt, SolarWarning w) => switch (w.code) {
  'consumption_partial_year' => l.swConsumptionPartial(fmt.number(w.value)),
  'excess_not_counted' => l.swExcessNotCounted(fmt.number(w.value)),
  'no_consumption' => l.swNoConsumption,
  'grid_factor_not_set' => l.swGridFactorNotSet,
  'co2_needs_consumption' => l.swCo2NeedsConsumption,
  'grid_factor_placeholder' => l.swGridPlaceholder,
  'price_missing' => l.swPriceMissing,
  'financials_need_consumption' => l.swFinancialsNeedConsumption,
  'om_not_included' => l.swOmNotIncluded,
  'export_price_missing' => l.swExportPriceMissing,
  'financial_assumptions' => l.swFinancialAssumptions,
  'no_payback' => l.swNoPayback,
  'shading_not_assessed' => l.swShadingNotAssessed,
  'structure_unknown' => l.swStructureUnknown,
  'structure_needs_work' => l.swStructureNeedsWork,
  'tariff_average_price' => l.swTariffAverage,
  _ => w.message,
};

/// Solar pre-feasibility results (spec 6.4 / 8.7). Always shows the disclaimer.
class SolarResultScreen extends ConsumerWidget {
  const SolarResultScreen({super.key, required this.result, required this.polygon, required this.params, this.plan});
  final SolarResult result;
  final List<LatLon> polygon;
  final Map<String, dynamic> params;
  final SolarPlan? plan;

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _PlanNameDialog(initial: plan?.name ?? '${l.solarTitle} ${Fmt.of(context).date(DateTime.now())}'),
    );
    if (name == null) return;
    await ref.read(solarPlanRepositoryProvider).save(SolarPlan(
          id: plan?.id ?? newId(),
          name: name.trim().isEmpty ? l.solarTitle : name.trim(),
          polygon: polygon,
          params: params,
          resultJson: result.raw,
          updatedAt: DateTime.now(),
        ));
    if (context.mounted) {
      showSnack(context, l.solarPlanSaved);
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final r = result;
    final f = r.financials;
    final gridPlaceholder = r.factors['grid_electricity']?.isPlaceholder ?? false;
    final placeholderParams = r.params.where((p) => p.isPlaceholder && p.number != null).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.solarResultTitle),
        actions: [
          IconButton(
            tooltip: l.actionEdit,
            icon: const Icon(Icons.edit_location_alt_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SolarMapScreen(
                  plan: SolarPlan(
                    id: plan?.id ?? newId(),
                    name: plan?.name ?? l.solarNewPlan,
                    polygon: polygon,
                    params: params,
                    resultJson: null,
                    updatedAt: DateTime.now(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            gradient: BrandGradients.solar,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.solarSize,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l.valueKwp(fmt.number(r.kwp, decimals: 1)),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.valueKwhYear(fmt.number(r.annualGenerationKwh)),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.solar_power_rounded, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
          SoftCard(
            key: const Key('solar-disclaimer'),
            color: Colors.amber.withValues(alpha: 0.10),
            borderColor: Colors.amber.withValues(alpha: 0.4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.engineering_rounded, color: Colors.amber.shade900),
                const SizedBox(width: 12),
                Expanded(child: Text(r.disclaimer)),
              ],
            ),
          ),
          SoftCard(
            child: Column(
              children: [
                LabeledValue(l.solarRoofArea, l.valueM2(fmt.number(r.roofAreaM2))),
                LabeledValue(l.solarUsableArea, l.valueM2(fmt.number(r.usableAreaM2)), trailing: placeholderParams ? const UnverifiedBadge() : null),
                LabeledValue(l.solarSize, l.valueKwp(fmt.number(r.kwp, decimals: 1))),
                LabeledValue(
                  l.solarPsh,
                  '${fmt.number(r.peakSunHoursAnnualAvg, decimals: 2)} (${r.irradianceSource == 'nasa_power' ? l.solarSourceNasa : l.solarSourceManual})',
                ),
                const Divider(),
                LabeledValue(l.solarAnnualGen, l.valueKwhYear(fmt.number(r.annualGenerationKwh))),
                LabeledValue(l.solarOffset, r.offsetShare == null ? l.notAvailable : l.valuePercent(fmt.number(r.offsetShare! * 100, decimals: 1))),
                LabeledValue(
                  l.solarCo2,
                  r.co2AvoidedT == null ? l.notAvailable : l.tonnesCo2(fmt.tonnes(r.co2AvoidedT)),
                  trailing: gridPlaceholder && r.co2AvoidedT != null ? const UnverifiedBadge() : null,
                ),
              ],
            ),
          ),
          SoftCard(
            child: SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text('${fmt.number(v / 1000)}k', style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text('${v.toInt() + 1}', style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < r.monthlyGenerationKwh.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: r.monthlyGenerationKwh[i],
                            color: FeatureColors.solar,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          SectionTitle(l.solarFinancials),
          if (f == null)
            Text(l.solarNoFinancials)
          else ...[
            LabeledValue(l.solarCapex, l.valueTk(fmt.number(f.capexBdt))),
            LabeledValue(l.solarYear1Savings, l.valueTk(fmt.number(f.year1SavingsBdt))),
            LabeledValue(l.solarYear1Om, l.valueTk(fmt.number(f.year1OmBdt))),
            LabeledValue(l.solarPayback, f.paybackYears == null ? l.solarNoPayback : l.valueYears(fmt.number(f.paybackYears, decimals: 1))),
            const SizedBox(height: 12),
            Text(l.solarCashflow, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(fmt.number(v, decimals: 1), style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (v, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),
                  ),
                  extraLinesData: ExtraLinesData(horizontalLines: [HorizontalLine(y: 0, color: Colors.grey, strokeWidth: 1)]),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [for (final c in f.cashflow) FlSpot(c.year.toDouble(), c.cumulativeBdt / 1e6)],
                      color: SeriesColors.electricity,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (r.warnings.isNotEmpty) ...[
            SectionTitle(l.solarNotes),
            for (final w in r.warnings) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• ${solarWarningText(l, fmt, w)}')),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            onPressed: () => _save(context, ref),
            icon: const Icon(Icons.save_rounded),
            label: Text(l.solarSavePlan),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Asks for a plan name. Owns its text controller so it is disposed only after the
/// dialog's closing animation has finished.
class _PlanNameDialog extends StatefulWidget {
  const _PlanNameDialog({required this.initial});
  final String initial;

  @override
  State<_PlanNameDialog> createState() => _PlanNameDialogState();
}

class _PlanNameDialogState extends State<_PlanNameDialog> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.solarSavePlan),
      content: TextField(controller: _name, decoration: InputDecoration(labelText: l.solarPlanName), autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.actionCancel)),
        FilledButton(key: const Key('solar-plan-save'), onPressed: () => Navigator.pop(context, _name.text), child: Text(l.actionSave)),
      ],
    );
  }
}
