import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/api_models.dart';

/// Actual vs expected kWh with the 95% band; flagged months in red.
class WasteChart extends StatelessWidget {
  const WasteChart({super.key, required this.months});
  final List<WasteMonth> months;

  @override
  Widget build(BuildContext context) {
    final fmt = Fmt.of(context);
    final step = (months.length / 6).ceil().clamp(1, 12);
    FlSpot spot(int i, double? v) => v == null ? FlSpot.nullSpot : FlSpot(i.toDouble(), v);
    final band = Colors.blueGrey.withValues(alpha: 0.18);
    final lines = [
      LineChartBarData(spots: [for (var i = 0; i < months.length; i++) spot(i, months[i].upperKwh)], color: Colors.transparent, dotData: const FlDotData(show: false), barWidth: 0),
      LineChartBarData(spots: [for (var i = 0; i < months.length; i++) spot(i, months[i].lowerKwh)], color: Colors.transparent, dotData: const FlDotData(show: false), barWidth: 0),
      LineChartBarData(
        spots: [for (var i = 0; i < months.length; i++) spot(i, months[i].expectedKwh)],
        color: SeriesColors.expected,
        dashArray: [6, 4],
        barWidth: 1.5,
        dotData: const FlDotData(show: false),
      ),
      LineChartBarData(
        spots: [for (var i = 0; i < months.length; i++) spot(i, months[i].actualKwh)],
        color: SeriesColors.electricity,
        barWidth: 2,
        dotData: FlDotData(
          getDotPainter: (s, _, _, i) => FlDotCirclePainter(
            radius: months[i].flagged ? 5 : 2.5,
            color: months[i].flagged ? SeriesColors.flagged : SeriesColors.electricity,
            strokeWidth: 0,
          ),
        ),
      ),
    ];
    return SizedBox(
      height: 240,
      child: LineChart(LineChartData(
        lineBarsData: lines,
        betweenBarsData: [BetweenBarsData(fromIndex: 0, toIndex: 1, color: band)],
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final s in spots)
                s.barIndex == 3
                    ? LineTooltipItem('${fmt.month(months[s.x.toInt()].month)}\n${fmt.number(s.y)} kWh', const TextStyle(color: Colors.white, fontSize: 12))
                    : null,
            ],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 44, getTitlesWidget: (v, meta) => SideTitleWidget(meta: meta, child: Text('${fmt.number(v / 1000)}k', style: const TextStyle(fontSize: 10)))),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= months.length || i % step != 0 || v != i.toDouble()) return const SizedBox.shrink();
                return SideTitleWidget(meta: meta, child: Text(fmt.month(months[i].month), style: const TextStyle(fontSize: 9)));
              },
            ),
          ),
        ),
      )),
    );
  }
}
