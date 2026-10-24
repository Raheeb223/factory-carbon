import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart' as m;
import '../../domain/panel_layout.dart';
import '../../domain/solar_scenario.dart';
import '../../domain/solar_summary.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../loan/green_loan_screen.dart';

const _panelColor = Color(0xFF1E3A8A);

/// Solar Preview: the traced roof today and covered with panels, then the factory's own
/// billed months compared with and without solar (grid kWh, bill, CO2).
class SolarPreviewScreen extends ConsumerStatefulWidget {
  const SolarPreviewScreen({super.key, required this.result, required this.polygon, this.panelWatt});
  final SolarResult result;
  final List<m.LatLon> polygon;
  final int? panelWatt;

  @override
  ConsumerState<SolarPreviewScreen> createState() => _SolarPreviewScreenState();
}

class _SolarPreviewScreenState extends ConsumerState<SolarPreviewScreen> {
  var _after = true;
  late final _summary = SolarSummary(widget.result, panelWatt: widget.panelWatt);
  late final _panels = panelLayout(widget.polygon, maxPanels: _summary.panels);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final t = Theme.of(context).textTheme;
    final r = widget.result;
    final scenario = SolarScenario.of(r, ref.watch(billsProvider).value ?? const []);

    return Scaffold(
      appBar: AppBar(title: Text(l.previewTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const SyntheticBanner(),
          _RoofView(roof: widget.polygon, panels: _after ? _panels : const [], after: _after, onToggle: (v) => setState(() => _after = v)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              _panels.length < _summary.panels
                  ? l.previewFitNote(fmt.number(_panels.length.toDouble()), fmt.number(_summary.panels.toDouble()))
                  : l.previewPanels(fmt.number(_summary.panels.toDouble()), fmt.number(r.kwp, decimals: 1)),
              style: t.bodySmall,
            ),
          ),
          if (scenario == null)
            SoftCard(child: Text(l.previewNoBills, style: t.bodyLarge))
          else ...[
            _Headline(scenario: scenario),
            SectionTitle(l.previewCompare),
            Text(
              l.previewPeriod(_month(fmt, scenario.months.first.month), _month(fmt, scenario.months.last.month)),
              style: t.bodySmall,
            ),
            SoftCard(
              key: const Key('preview-compare'),
              child: Column(children: [
                _CompareRow(
                  label: l.previewGrid,
                  before: scenario.gridBeforeKwh,
                  after: scenario.gridAfterKwh,
                  text: (v) => '${fmt.number(v)} kWh',
                  color: SeriesColors.electricity,
                ),
                if (scenario.hasCost)
                  _CompareRow(
                    label: l.previewBill,
                    before: scenario.costBeforeBdt!,
                    after: scenario.costAfterBdt!,
                    text: (v) => l.valueTk(fmt.number(v)),
                    color: FeatureColors.bills,
                  ),
                if (scenario.co2BeforeT != null)
                  _CompareRow(
                    label: l.previewCo2,
                    before: scenario.co2BeforeT!,
                    after: scenario.co2AfterT!,
                    text: (v) => l.tonnesCo2(fmt.tonnes(v)),
                    color: FeatureColors.carbon,
                  ),
              ]),
            ),
            SectionTitle(l.previewMonthly),
            SoftCard(child: _MonthlyChart(scenario: scenario)),
          ],
          if (r.financials != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('preview-loan'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GreenLoanScreen(result: r))),
              icon: const Icon(Icons.account_balance_rounded),
              label: Text(l.loanOpen),
            ),
          ],
          const SizedBox(height: 12),
          Text(l.previewNote, style: t.bodySmall),
        ],
      ),
    );
  }
}

String _month(Fmt fmt, String ym) => DateFormat.yMMM(fmt.locale).format(DateTime(int.parse(ym.substring(0, 4)), int.parse(ym.substring(5, 7))));

/// The roof on the satellite (or street) map, with or without the panel rows.
class _RoofView extends ConsumerWidget {
  const _RoofView({required this.roof, required this.panels, required this.after, required this.onToggle});
  final List<m.LatLon> roof;
  final List<List<m.LatLon>> panels;
  final bool after;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final pts = [for (final p in roof) LatLng(p.lat, p.lon)];
    LatLng ll(m.LatLon p) => LatLng(p.lat, p.lon);
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 320,
        child: Stack(children: [
          FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(bounds: LatLngBounds.fromPoints(pts), padding: const EdgeInsets.fromLTRB(28, 64, 28, 28), maxZoom: 20),
              maxZoom: 21,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            ),
            children: [
              TileLayer(
                urlTemplate: config.hasSatellite ? config.satelliteTileUrl : config.mapTileUrl,
                userAgentPackageName: config.userAgentPackageName,
                maxNativeZoom: 19,
              ),
              PolygonLayer(polygons: [
                Polygon(
                  points: pts,
                  color: after ? Colors.transparent : Colors.white.withValues(alpha: 0.12),
                  borderColor: after ? Colors.white.withValues(alpha: 0.8) : FeatureColors.solar,
                  borderStrokeWidth: 2,
                ),
                for (final p in panels)
                  Polygon(
                    points: [for (final c in p) ll(c)],
                    color: _panelColor.withValues(alpha: 0.92),
                    borderColor: Colors.white.withValues(alpha: 0.55),
                    borderStrokeWidth: 0.6,
                  ),
              ]),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    config.hasSatellite ? config.satelliteTileAttribution : config.mapTileAttribution,
                    style: const TextStyle(fontSize: 9, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Center(
              child: Material(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                child: SegmentedButton<bool>(
                  key: const Key('preview-toggle'),
                  segments: [
                    ButtonSegment(value: false, label: Text(l.previewBefore), icon: const Icon(Icons.factory_outlined)),
                    ButtonSegment(value: true, label: Text(l.previewAfter), icon: const Icon(Icons.solar_power_rounded)),
                  ],
                  selected: {after},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => onToggle(s.first),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.scenario});
  final SolarScenario scenario;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final s = scenario;
    final saved = s.hasCost ? s.costBeforeBdt! - s.costAfterBdt! : null;
    return SoftCard(
      key: const Key('preview-headline'),
      gradient: BrandGradients.solar,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          l.previewHeadline(fmt.number(s.solarShare * 100)),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        Row(children: [
          GlassStat(value: fmt.number(s.solarKwh), label: l.previewStatSolar),
          const SizedBox(width: 8),
          GlassStat(value: l.valuePercent(fmt.number(s.solarShare * 100)), label: l.previewStatGridCut),
          const SizedBox(width: 8),
          GlassStat(value: saved == null ? '–' : l.valueTk(fmt.number(saved)), label: l.previewStatSaved),
        ]),
      ]),
    );
  }
}

/// Two bars, now and with solar, scaled to the "now" value, and the change in percent.
class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.label, required this.before, required this.after, required this.text, required this.color});
  final String label;
  final double before;
  final double after;
  final String Function(double) text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final t = Theme.of(context).textTheme;
    final ratio = before <= 0 ? 0.0 : (after / before).clamp(0.0, 1.0);
    Widget bar(String name, double share, String value, Color c) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(children: [
            SizedBox(width: 78, child: Text(name, style: t.bodySmall)),
            Expanded(
              child: Stack(children: [
                Container(height: 22, decoration: BoxDecoration(color: c.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(6))),
                FractionallySizedBox(
                  widthFactor: share,
                  child: Container(height: 22, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6))),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12, shadows: [Shadow(blurRadius: 3)])),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: t.titleSmall)),
          if (before > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: FeatureColors.carbon.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
              child: Text('−${l.valuePercent(fmt.number((1 - ratio) * 100))}', style: const TextStyle(color: FeatureColors.carbon, fontWeight: FontWeight.w800)),
            ),
        ]),
        bar(l.previewNow, 1, text(before), color.withValues(alpha: 0.55)),
        bar(l.previewWithSolar, ratio, text(after), color),
      ]),
    );
  }
}

/// Each billed month's electricity, split into what still comes from the grid and what the roof gives.
class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.scenario});
  final SolarScenario scenario;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final months = scenario.months;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 14, children: [
        LegendDot(color: SeriesColors.electricity, label: l.previewFromGrid),
        LegendDot(color: FeatureColors.solar, label: l.previewFromSolar),
      ]),
      const SizedBox(height: 10),
      SizedBox(
        height: 200,
        child: BarChart(
          key: const Key('preview-chart'),
          BarChartData(
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, _, _, _) {
                  final mo = months[group.x];
                  return BarTooltipItem(
                    '${_month(fmt, mo.month)}\n${l.previewFromSolar}: ${fmt.number(mo.solarKwh)} kWh\n${l.previewFromGrid}: ${fmt.number(mo.gridAfterKwh)} kWh',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, meta) => SideTitleWidget(meta: meta, child: Text('${fmt.number(v / 1000)}k', style: const TextStyle(fontSize: 10))),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, meta) {
                    final ym = months[v.toInt()].month;
                    final name = DateFormat.MMM(fmt.locale).format(DateTime(2026, int.parse(ym.substring(5, 7))));
                    return SideTitleWidget(meta: meta, child: Text(name.characters.first, style: const TextStyle(fontSize: 10)));
                  },
                ),
              ),
            ),
            barGroups: [
              for (final (i, mo) in months.indexed)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: mo.gridBeforeKwh,
                    width: 14,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    rodStackItems: [
                      BarChartRodStackItem(0, mo.gridAfterKwh, SeriesColors.electricity),
                      BarChartRodStackItem(mo.gridAfterKwh, mo.gridBeforeKwh, FeatureColors.solar),
                    ],
                  ),
                ]),
            ],
          ),
        ),
      ),
    ]);
  }
}
