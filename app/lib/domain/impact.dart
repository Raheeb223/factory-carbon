/// Measured savings of energy-saving actions, from the factory's own bills (Feature 4).
///
/// Method (whole-factory, production-adjusted, like IPMVP Option C):
/// - Baseline = kWh per unit produced over up to 12 months before the action month.
/// - Each later month: expected kWh = baseline x units produced that month.
/// - Saved kWh = expected - actual (negative when more was used).
/// The action month itself is left out (the change happened part-way through it).
/// Pure Dart so it is unit tested.
library;

import 'models.dart';
import 'requests.dart';

const int maxBaselineMonths = 12;
const int minBaselineMonths = 3;

/// Months after the action needed before the result is called settled.
const int settledAfterMonths = 3;

enum ImpactStatus { planned, noProduction, noBaseline, tooEarly, measured }

class ImpactMonth {
  const ImpactMonth(this.month, this.actualKwh, this.expectedKwh, this.units);
  final String month;
  final double actualKwh;
  final double expectedKwh;
  final double units;
  double get savedKwh => expectedKwh - actualKwh;
  double get kwhPerUnit => actualKwh / units;
}

class Impact {
  const Impact({
    required this.status,
    this.startMonth,
    this.baselineKwhPerUnit,
    this.monthsBefore = 0,
    this.months = const [],
    this.priceBdtPerKwh,
    this.gridKgPerKwh,
  });

  final ImpactStatus status;
  final String? startMonth;
  final double? baselineKwhPerUnit;
  final int monthsBefore;

  /// Months after the action, oldest first.
  final List<ImpactMonth> months;
  final double? priceBdtPerKwh;
  final double? gridKgPerKwh;

  int get monthsAfter => months.length;
  bool get settled => monthsAfter >= settledAfterMonths;

  double get savedKwh => months.fold(0.0, (s, m) => s + m.savedKwh);
  double? get savedBdt => priceBdtPerKwh == null ? null : savedKwh * priceBdtPerKwh!;
  double? get savedCo2Kg => gridKgPerKwh == null ? null : savedKwh * gridKgPerKwh!;

  double? get afterKwhPerUnit {
    final units = months.fold(0.0, (s, m) => s + m.units);
    return units <= 0 ? null : months.fold(0.0, (s, m) => s + m.actualKwh) / units;
  }

  /// Change in kWh per unit, in percent (negative = less electricity per unit).
  double? get changePct {
    final after = afterKwhPerUnit;
    final base = baselineKwhPerUnit;
    return after == null || base == null || base <= 0 ? null : (after - base) / base * 100;
  }
}

/// Average electricity price over bills that have an amount (Tk per kWh).
double? averagePrice(List<Bill> bills) {
  var kwh = 0.0;
  var bdt = 0.0;
  for (final e in monthlyElectricity(bills)) {
    if (e.costBdt != null && e.kwh > 0) {
      kwh += e.kwh;
      bdt += e.costBdt!;
    }
  }
  return kwh > 0 ? bdt / kwh : null;
}

/// Savings since [startMonth] (the month an action was completed).
Impact measureSince(String? startMonth, {required List<Bill> bills, required List<ProductionEntry> production, double? gridKgPerKwh}) {
  if (startMonth == null) return const Impact(status: ImpactStatus.planned);
  final kwh = {for (final e in monthlyElectricity(bills)) e.month: e.kwh};
  final units = <String, double>{};
  for (final p in production) {
    units[p.month] = (units[p.month] ?? 0) + p.unitsProduced;
  }
  bool usable(String m) => (kwh[m] ?? 0) > 0 && (units[m] ?? 0) > 0;

  final before = (kwh.keys.where((m) => m.compareTo(startMonth) < 0 && usable(m)).toList()..sort()).reversed.take(maxBaselineMonths).toList();
  final after = kwh.keys.where((m) => m.compareTo(startMonth) > 0 && usable(m)).toList()..sort();
  final price = averagePrice(bills);

  if (units.isEmpty) return Impact(status: ImpactStatus.noProduction, startMonth: startMonth);
  if (before.length < minBaselineMonths) return Impact(status: ImpactStatus.noBaseline, startMonth: startMonth, monthsBefore: before.length);
  final baseKwh = before.fold(0.0, (s, m) => s + kwh[m]!);
  final baseUnits = before.fold(0.0, (s, m) => s + units[m]!);
  final baseline = baseKwh / baseUnits;
  final months = [for (final m in after) ImpactMonth(m, kwh[m]!, baseline * units[m]!, units[m]!)];
  return Impact(
    status: months.isEmpty ? ImpactStatus.tooEarly : ImpactStatus.measured,
    startMonth: startMonth,
    baselineKwhPerUnit: baseline,
    monthsBefore: before.length,
    months: months,
    priceBdtPerKwh: price,
    gridKgPerKwh: gridKgPerKwh,
  );
}

/// The month of the first completed action (all savings are counted from there).
String? firstDoneMonth(List<EnergyAction> actions) {
  final done = actions.where((a) => a.done).map((a) => a.doneMonth!).toList()..sort();
  return done.isEmpty ? null : done.first;
}
