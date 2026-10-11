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
    final name = TextEditingController(text: plan?.name ?? '${l.solarTitle} ${Fmt.of(context).date(DateTime.now())}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.solarSavePlan),
        content: TextField(controller: name, decoration: InputDecoration(labelText: l.solarPlanName), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.actionSave)),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(solarPlanRepositoryProvider).save(SolarPlan(
            id: plan?.id ?? newId(),
            name: name.text.trim().isEmpty ? l.solarTitle : name.text.trim(),
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
    name.dispose();
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
      appBar: AppBar(title: Text(l.solarResultTitle), actions: [
        IconButton(
          tooltip: l.actionEdit,
          icon: const Icon(Icons.edit_location_alt_outlined),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => SolarMapScreen(
              plan: SolarPlan(id: plan?.id ?? newId(), name: plan?.name ?? l.solarNewPlan, polygon: polygon, params: params, resultJson: null, updatedAt: DateTime.now()),
            ),
          )),
        ),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          color: Colors.amber.withValues(alpha: 0.15),
          child: ListTile(key: const Key('solar-disclaimer'), leading: const Icon(Icons.engineering_outlined), title: Text(r.disclaimer)),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              LabeledValue(l.solarRoofArea, l.valueM2(fmt.number(r.roofAreaM2))),
              LabeledValue(l.solarUsableArea, l.valueM2(fmt.number(r.usableAreaM2)), trailing: placeholderParams ? const UnverifiedBadge() : null),
              LabeledValue(l.solarSize, l.valueKwp(fmt.number(r.kwp, decimals: 1))),
              LabeledValue(l.solarPsh, '${fmt.number(r.peakSunHoursAnnualAvg, decimals: 2)} (${r.irradianceSource == 'nasa_power' ? l.solarSourceNasa : l.solarSourceManual})'),
              const Divider(),
              LabeledValue(l.solarAnnualGen, l.valueKwhYear(fmt.number(r.annualGenerationKwh))),
              LabeledValue(l.solarOffset, r.offsetShare == null ? l.notAvailable : l.valuePercent(fmt.number(r.offsetShare! * 100, decimals: 1))),
              LabeledValue(
                l.solarCo2,
                r.co2AvoidedT == null ? l.notAvailable : l.tonnesCo2e(fmt.tonnes(r.co2AvoidedT)),
                trailing: gridPlaceholder && r.co2AvoidedT != null ? const UnverifiedBadge() : null,
              ),
            ]),
          ),
        ),
        SizedBox(
          height: 160,
          child: BarChart(BarChartData(
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, meta) => SideTitleWidget(meta: meta, child: Text('${fmt.number(v / 1000)}k', style: const TextStyle(fontSize: 10))))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) => SideTitleWidget(meta: meta, child: Text('${v.toInt() + 1}', style: const TextStyle(fontSize: 10))))),
            ),
            barGroups: [
              for (var i = 0; i < r.monthlyGenerationKwh.length; i++)
                BarChartGroupData(x: i, barRods: [BarChartRodData(toY: r.monthlyGenerationKwh[i], color: SeriesColors.gas, width: 10)]),
            ],
          )),
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
            child: LineChart(LineChartData(
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, meta) => SideTitleWidget(meta: meta, child: Text(fmt.number(v, decimals: 1), style: const TextStyle(fontSize: 10))))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 5, getTitlesWidget: (v, meta) => SideTitleWidget(meta: meta, child: Text('${v.toInt()}', style: const TextStyle(fontSize: 10))))),
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
            )),
          ),
        ],
        if (r.warnings.isNotEmpty) ...[
          SectionTitle(l.solarNotes),
          for (final w in r.warnings) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• ${solarWarningText(l, fmt, w)}')),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: () => _save(context, ref), icon: const Icon(Icons.save_outlined), label: Text(l.solarSavePlan)),
        const SizedBox(height: 24),
      ]),
    );
  }
}
