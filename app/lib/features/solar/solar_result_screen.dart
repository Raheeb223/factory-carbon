import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/drift_repositories.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart';
import '../../domain/solar_summary.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../loan/green_loan_screen.dart';
import 'solar_map_screen.dart';
import 'solar_preview_screen.dart';

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

/// Years the cash flow covers (the panels' assumed life).
int lifeYears(SolarFinancials f) => f.cashflow.isEmpty ? 0 : f.cashflow.last.year;

/// Payback later than the panels last: shown as "over N years", not a meaningless number.
bool paybackBeyondLife(SolarFinancials f) => f.paybackYears != null && f.paybackYears! > lifeYears(f);

String paybackText(AppLocalizations l, Fmt fmt, SolarFinancials? f) {
  if (f?.paybackYears == null) return f == null ? '–' : l.solarNoPayback;
  if (paybackBeyondLife(f!)) return l.solarPaybackOver(fmt.number(lifeYears(f).toDouble()));
  return l.valueYears(fmt.number(f.paybackYears, decimals: 1));
}

String _monthName(Fmt fmt, int index) => DateFormat.MMMM(fmt.locale).format(DateTime(2026, index + 1));

/// The result in a few plain sentences, for owners who do not read kWp.
List<String> plainWords(AppLocalizations l, Fmt fmt, SolarSummary s) {
  final r = s.r;
  final f = r.financials;
  return [
    l.solarSay1(fmt.number(s.panels.toDouble()), fmt.number(s.panelWatt.toDouble()), fmt.number(r.kwp)),
    l.solarSay2(fmt.number(s.unitsPerMonth)),
    if (s.usePerMonth != null && r.offsetShare != null)
      l.solarSay3(fmt.number(s.usePerMonth), fmt.number(r.offsetShare! * 100))
    else
      l.solarSayNoBills,
    if (f == null)
      l.solarSayNoPrice
    else if (f.paybackYears == null)
      l.swNoPayback
    else if (paybackBeyondLife(f))
      l.solarSayTooLong(fmt.number(f.year1SavingsBdt), fmt.number(f.capexBdt), fmt.number(lifeYears(f).toDouble()))
    else
      l.solarSay4(fmt.number(f.year1SavingsBdt), fmt.number(f.capexBdt), fmt.number(f.paybackYears, decimals: 1)),
  ];
}

/// The calculation chain from roof area to CO2, with the numbers the backend used.
List<(String, String)> workedSteps(AppLocalizations l, Fmt fmt, SolarSummary s) {
  final r = s.r;
  String pct(double? v) => fmt.number(v == null ? null : v * 100);
  final kw = fmt.number(r.kwp, decimals: 1);
  final factor = s.gridFactorKgPerKwh;
  return [
    (l.solarStep1, l.valueM2(fmt.number(r.roofAreaM2))),
    (l.solarStep2(pct(s.usableShare)), l.valueM2(fmt.number(r.usableAreaM2))),
    (l.solarStep3(fmt.number(r.usableAreaM2), fmt.number(s.m2PerKwp, decimals: 1)), l.valueKwp(kw)),
    (l.solarStep4(kw, fmt.number(s.panelWatt / 1000, decimals: 2)), l.solarPanelsCount(fmt.number(s.panels.toDouble()))),
    (
      r.irradianceSource == 'nasa_power' ? l.solarStep5Nasa : l.solarStep5Manual,
      l.valueHoursDay(fmt.number(r.peakSunHoursAnnualAvg, decimals: 2)),
    ),
    (
      l.solarStep6(kw, fmt.number(r.peakSunHoursAnnualAvg, decimals: 2), pct(s.efficiency), s.shade > 0 ? l.solarStepShade(pct(1 - s.shade)) : ''),
      l.valueKwhYear(fmt.number(r.annualGenerationKwh)),
    ),
    if (r.co2AvoidedT != null && factor != null && factor > 0)
      (l.solarStep7(fmt.number(r.co2AvoidedT! * 1000 / factor), fmt.number(factor, decimals: 2)), l.tonnesCo2(fmt.tonnes(r.co2AvoidedT))),
  ];
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.label, required this.value});
  final String number;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: FeatureColors.solar.withValues(alpha: 0.18),
            child: Text(number, style: t.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: t.bodyMedium),
                Text(value, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    final s = SolarSummary(r, panelWatt: (params['panel_watt'] as num?)?.toInt());

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
            key: const Key('solar-panels'),
            gradient: BrandGradients.solar,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.solarPanelsFit, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l.solarPanelsCount(fmt.number(s.panels.toDouble())),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                            ),
                          ),
                          Text(
                            l.solarPanelsEach(fmt.number(s.panelWatt.toDouble()), fmt.number(r.kwp, decimals: 1)),
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    GlassStat(value: fmt.number(s.unitsPerMonth), label: l.solarStatUnits),
                    const SizedBox(width: 8),
                    GlassStat(value: r.offsetShare == null ? '–' : l.valuePercent(fmt.number(r.offsetShare! * 100)), label: l.solarStatCovers),
                    const SizedBox(width: 8),
                    GlassStat(
                      value: f?.paybackYears == null ? '–' : paybackText(l, fmt, f),
                      label: l.solarStatPayback,
                    ),
                  ],
                ),
              ],
            ),
          ),
          FilledButton.icon(
            key: const Key('solar-preview'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => SolarPreviewScreen(result: r, polygon: polygon, panelWatt: s.panelWatt)),
            ),
            icon: const Icon(Icons.roofing_rounded),
            label: Text(l.previewOpen),
          ),
          SoftCard(
            key: const Key('solar-summary'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.chat_bubble_outline_rounded, color: FeatureColors.solar),
                  const SizedBox(width: 10),
                  Text(l.solarSummaryTitle, style: Theme.of(context).textTheme.titleMedium),
                ]),
                const SizedBox(height: 8),
                for (final line in plainWords(l, fmt, s))
                  Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(line, style: Theme.of(context).textTheme.bodyLarge)),
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
          SectionTitle(l.solarChartTitle),
          SoftCard(
            child: SizedBox(
              height: 170,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                        '${_monthName(fmt, group.x)}\n${fmt.number(rod.toY)} kWh',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
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
                          child: Text('${fmt.number(v / 1000)}k', style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(_monthName(fmt, v.toInt()).characters.first, style: const TextStyle(fontSize: 10)),
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
            LabeledValue(l.solarPayback, paybackText(l, fmt, f)),
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
          Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.only(top: 16),
            child: ExpansionTile(
              key: const Key('solar-worked'),
              leading: const Icon(Icons.calculate_outlined),
              title: Text(l.solarWorkedTitle),
              subtitle: Text(l.solarWorkedHint),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [
                for (final (i, (label, value)) in workedSteps(l, fmt, s).indexed) _Step(number: fmt.number((i + 1).toDouble()), label: label, value: value),
                const SizedBox(height: 6),
                Text(l.solarStepNote, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (r.warnings.isNotEmpty) ...[
            SectionTitle(l.solarNotes),
            for (final w in r.warnings) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• ${solarWarningText(l, fmt, w)}')),
          ],
          if (f != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const Key('solar-loan'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GreenLoanScreen(result: r))),
              icon: const Icon(Icons.account_balance_rounded),
              label: Text(l.loanOpen),
            ),
          ],
          const SizedBox(height: 12),
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
