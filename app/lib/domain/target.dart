/// Progress towards a CO2 reduction target (pure Dart, unit-tested).
///
/// Baseline = the chosen calendar year. "Now" = the latest 12 months with data, so the
/// figure is always a full year and seasons do not distort it. The reduction needed by
/// now follows a straight line from the end of the baseline year to the end of the
/// target year (the usual way targets are tracked, e.g. by the SBTi).
library;

import 'api_models.dart';
import 'models.dart';
import 'report_period.dart';

/// SBTi minimum ambition for 1.5°C-aligned near-term targets: 4.2% less per year (linear).
const sbtiAnnualPct = 4.2;

enum TargetStatus { onTrack, behind, notEnoughData }

class TargetProgress {
  const TargetProgress({
    required this.status,
    this.baselineValue,
    this.currentValue,
    this.achievedPct,
    required this.neededNowPct,
    this.incompleteData = false,
  });

  final TargetStatus status;
  final double? baselineValue;
  final double? currentValue;

  /// Reduction reached so far, percent (positive = less CO2 than the baseline).
  final double? achievedPct;

  /// Reduction that should have been reached by now to stay on the straight line.
  final double neededNowPct;

  /// True when the baseline year or the last 12 months have months without data.
  final bool incompleteData;
}

MonthSpan baselineSpan(ReductionTarget t) => (start: '${t.baselineYear}-01', end: '${t.baselineYear}-12');

/// The 12 months ending at the last month with data, or null without data.
MonthSpan? currentSpan(String? lastDataMonth) => lastDataMonth == null ? null : (start: shiftMonth(lastDataMonth, -11), end: lastDataMonth);

int _monthIndex(String m) => int.parse(m.substring(0, 4)) * 12 + int.parse(m.substring(5, 7));

/// Share of the way (0..1) from the end of the baseline year to the end of the target year
/// at the end of [current].
double _elapsed(ReductionTarget t, MonthSpan current) {
  final from = _monthIndex('${t.baselineYear}-12');
  final to = _monthIndex('${t.year}-12');
  if (to <= from) return 1;
  return ((_monthIndex(current.end) - from) / (to - from)).clamp(0.0, 1.0);
}

double? _value(ReductionTarget t, CarbonResult r) => t.perUnit ? r.totals.intensity : r.totals.totalT;

TargetProgress targetProgress(ReductionTarget t, {required CarbonResult? baseline, required CarbonResult? current, required MonthSpan? currentMonths}) {
  final needed = currentMonths == null ? 0.0 : t.pct * _elapsed(t, currentMonths);
  final b = baseline == null ? null : _value(t, baseline);
  final c = current == null ? null : _value(t, current);
  if (b == null || c == null || b <= 0 || currentMonths == null || currentMonths.end.compareTo(baselineSpan(t).end) <= 0) {
    return TargetProgress(status: TargetStatus.notEnoughData, baselineValue: b, currentValue: c, neededNowPct: needed);
  }
  final achieved = (b - c) / b * 100;
  bool gaps(CarbonResult r) => r.totals.monthsWithData < r.totals.monthsInPeriod;
  return TargetProgress(
    status: achieved + 1e-9 >= needed ? TargetStatus.onTrack : TargetStatus.behind,
    baselineValue: b,
    currentValue: c,
    achievedPct: achieved,
    neededNowPct: needed,
    incompleteData: gaps(baseline!) || gaps(current!),
  );
}

/// Years that can be a baseline: calendar years with at least one bill, newest first.
List<int> baselineYears(Iterable<String> billMonths) => ({for (final m in billMonths) int.parse(m.substring(0, 4))}.toList()..sort((a, b) => b.compareTo(a)));

/// Percent reduction for the SBTi pace between two years (linear, 4.2% a year).
double sbtiPct(int baselineYear, int targetYear) => (sbtiAnnualPct * (targetYear - baselineYear)).clamp(0, 100).toDouble();
