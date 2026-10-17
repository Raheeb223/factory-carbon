/// Recent months with no electricity bill or no production figure (Home reminder).
///
/// A month without data makes the carbon report understate the footprint and keeps
/// the electricity check from running, so the app points the gaps out. Pure Dart.
library;

import 'models.dart';

/// How many past months are checked.
const gapWindowMonths = 12;

class DataGaps {
  const DataGaps({this.electricity = const [], this.production = const []});

  /// Months (YYYY-MM, oldest first) without an electricity bill.
  final List<String> electricity;

  /// Months without a production figure.
  final List<String> production;

  bool get isEmpty => electricity.isEmpty && production.isEmpty;
}

String _shift(String month, int by) {
  final i = int.parse(month.substring(0, 4)) * 12 + int.parse(month.substring(5, 7)) - 1 + by;
  return '${(i ~/ 12).toString().padLeft(4, '0')}-${(i % 12 + 1).toString().padLeft(2, '0')}';
}

List<String> _missing(Set<String> have, String lastMonth) {
  if (have.isEmpty) return const [];
  final first = (have.toList()..sort()).first;
  final windowStart = _shift(lastMonth, -(gapWindowMonths - 1));
  var m = first.compareTo(windowStart) > 0 ? first : windowStart;
  final out = <String>[];
  while (m.compareTo(lastMonth) <= 0) {
    if (!have.contains(m)) out.add(m);
    m = _shift(m, 1);
  }
  return out;
}

/// Gaps up to the month before [now] (this month's bill is usually not out yet).
/// Each source is only checked once the factory has started entering it, and demo
/// data is ignored.
DataGaps findGaps(List<Bill> bills, List<ProductionEntry> production, {DateTime? now}) {
  final lastMonth = _shift(monthOf(now ?? DateTime.now()), -1);
  final kwh = {
    for (final b in bills)
      if (b.billType == BillType.electricity && !b.isSynthetic && b.billingMonth.compareTo(lastMonth) <= 0) b.billingMonth,
  };
  final units = {
    for (final p in production)
      if (!p.isSynthetic && p.month.compareTo(lastMonth) <= 0) p.month,
  };
  return DataGaps(electricity: _missing(kwh, lastMonth), production: _missing(units, lastMonth));
}

/// Month to suggest when adding production: the latest month that has a bill but no
/// production figure (so CO2 per unit can be worked out), otherwise last month (this
/// month is not finished yet).
String suggestedProductionMonth(List<Bill> bills, List<ProductionEntry> production, {DateTime? now}) {
  final have = {for (final p in production) p.month};
  final needed = ({for (final b in bills) if (!b.isSynthetic) b.billingMonth}.difference(have).toList()..sort());
  return needed.isNotEmpty ? needed.last : _shift(monthOf(now ?? DateTime.now()), -1);
}
