import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/api_models.dart';

/// Stacked monthly tCO2e by source. Months without data draw no bar (never zero).
class CarbonMonthlyChart extends StatelessWidget {
  const CarbonMonthlyChart({super.key, required this.months});
  final List<MonthEmissions> months;

  @override
  Widget build(BuildContext context) {
    final fmt = Fmt.of(context);
    final maxY = months.fold<double>(0, (m, e) => (e.totalT ?? 0) > m ? e.totalT! : m);
    final step = (months.length / 6).ceil().clamp(1, 12);
    return SizedBox(
      height: 220,
      child: BarChart(BarChartData(
        maxY: maxY == 0 ? 1 : maxY * 1.15,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, _) {
              final m = months[group.x];
              return BarTooltipItem('${fmt.month(m.month)}\n${fmt.tonnes(m.totalT)} t${m.isComplete ? '' : ' *'}', const TextStyle(color: Colors.white, fontSize: 12));
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, meta) => SideTitleWidget(meta: meta, child: Text(fmt.number(v, decimals: v < 10 ? 1 : 0), style: const TextStyle(fontSize: 10)))),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= months.length || i % step != 0) return const SizedBox.shrink();
                return SideTitleWidget(meta: meta, child: Text(fmt.month(months[i].month), style: const TextStyle(fontSize: 9)));
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < months.length; i++) _group(i, months[i]),
        ],
      )),
    );
  }

  BarChartGroupData _group(int x, MonthEmissions m) {
    final parts = <(double, Color)>[
      if (m.scope2ElectricityT != null) (m.scope2ElectricityT!, SeriesColors.electricity),
      if (m.scope1DieselT != null) (m.scope1DieselT!, SeriesColors.diesel),
      if (m.scope1GasT != null) (m.scope1GasT!, SeriesColors.gas),
    ];
    var y = 0.0;
    final stack = <BarChartRodStackItem>[];
    for (final (v, c) in parts) {
      stack.add(BarChartRodStackItem(y, y + v, c));
      y += v;
    }
    return BarChartGroupData(x: x, barRods: [
      if (parts.isNotEmpty)
        BarChartRodData(toY: y, rodStackItems: stack, width: months.length > 18 ? 6 : 10, borderRadius: BorderRadius.zero, color: Colors.transparent),
    ]);
  }
}
