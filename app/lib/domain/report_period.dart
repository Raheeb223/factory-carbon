/// Reporting periods for the carbon report: all data, a calendar year or a Bangladesh
/// fiscal year (July to June). Buyers and the Higg FEM ask for one year at a time.
/// Pure Dart (unit-tested).
library;

enum PeriodKind { all, calendarYear, fiscalYear }

/// A month span, both ends inclusive (YYYY-MM).
typedef MonthSpan = ({String start, String end});

String shiftMonth(String month, int by) {
  final i = int.parse(month.substring(0, 4)) * 12 + int.parse(month.substring(5, 7)) - 1 + by;
  return '${(i ~/ 12).toString().padLeft(4, '0')}-${(i % 12 + 1).toString().padLeft(2, '0')}';
}

class ReportPeriod {
  const ReportPeriod.all()
      : kind = PeriodKind.all,
        year = 0;
  const ReportPeriod.calendar(this.year) : kind = PeriodKind.calendarYear;

  /// The fiscal year that starts in July of [year] (FY [year]-[year+1]).
  const ReportPeriod.fiscal(this.year) : kind = PeriodKind.fiscalYear;

  final PeriodKind kind;
  final int year;

  String get key => switch (kind) {
        PeriodKind.all => 'all',
        PeriodKind.calendarYear => 'cy:$year',
        PeriodKind.fiscalYear => 'fy:$year',
      };

  static ReportPeriod parse(String? key) {
    final m = RegExp(r'^(cy|fy):(\d{4})$').firstMatch(key ?? '');
    if (m == null) return const ReportPeriod.all();
    final y = int.parse(m.group(2)!);
    return m.group(1) == 'cy' ? ReportPeriod.calendar(y) : ReportPeriod.fiscal(y);
  }

  /// The whole period; null for all data.
  MonthSpan? get fullSpan => switch (kind) {
        PeriodKind.all => null,
        PeriodKind.calendarYear => (start: '$year-01', end: '$year-12'),
        PeriodKind.fiscalYear => (start: '$year-07', end: '${year + 1}-06'),
      };

  /// The months to report: the period cut at the last month with data, so a year still
  /// in progress is not shown with empty future months. Null for all data, or when the
  /// period starts after the last data month.
  MonthSpan? reportSpan(String? lastDataMonth) {
    final full = fullSpan;
    if (full == null || lastDataMonth == null || lastDataMonth.compareTo(full.start) < 0) return full;
    return (start: full.start, end: lastDataMonth.compareTo(full.end) < 0 ? lastDataMonth : full.end);
  }

  /// The same months one year earlier (like-for-like comparison).
  MonthSpan? previousSpan(String? lastDataMonth) {
    final s = reportSpan(lastDataMonth);
    return s == null ? null : (start: shiftMonth(s.start, -12), end: shiftMonth(s.end, -12));
  }

  /// True when the report covers fewer months than the full period (year to date).
  bool isPartial(String? lastDataMonth) {
    final s = reportSpan(lastDataMonth);
    return s != null && s.end != fullSpan!.end;
  }

  @override
  bool operator ==(Object other) => other is ReportPeriod && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

/// Periods to choose from, given the months that have data: all data, then calendar
/// years and fiscal years that contain data, newest first.
List<ReportPeriod> availablePeriods(Iterable<String> dataMonths) {
  final months = dataMonths.toSet();
  if (months.isEmpty) return const [ReportPeriod.all()];
  final years = {for (final m in months) int.parse(m.substring(0, 4))}.toList()..sort((a, b) => b.compareTo(a));
  final fiscal = {for (final m in months) int.parse(m.substring(5, 7)) >= 7 ? int.parse(m.substring(0, 4)) : int.parse(m.substring(0, 4)) - 1}.toList()
    ..sort((a, b) => b.compareTo(a));
  return [
    const ReportPeriod.all(),
    for (final y in years) ReportPeriod.calendar(y),
    for (final y in fiscal) ReportPeriod.fiscal(y),
  ];
}

/// Change from [previous] to [current] in percent; null when either is missing or zero.
double? percentChange(double? previous, double? current) =>
    previous == null || current == null || previous <= 0 ? null : (current - previous) / previous * 100;
