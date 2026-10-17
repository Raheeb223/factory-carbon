import 'api_models.dart';
import 'models.dart';

enum CarbonSource { electricity, diesel, gas, lpg, furnaceOil }

/// One line of "units × factor = tonnes" for an energy source in the report period.
class SourceLine {
  const SourceLine({required this.source, required this.amount, required this.tonnes, required this.months, this.factorKg});
  final CarbonSource source;

  /// kWh, litres or m³, summed over months that have a result for this source.
  final double amount;
  final double tonnes;
  final int months;

  /// kg CO2(e) per unit; null when the factor is not set.
  final double? factorKg;
}

const _factorNames = {
  CarbonSource.electricity: 'grid_electricity',
  CarbonSource.diesel: 'diesel',
  CarbonSource.gas: 'natural_gas',
  CarbonSource.lpg: 'lpg',
  CarbonSource.furnaceOil: 'furnace_oil',
};

/// Plain numbers behind the carbon report, all taken from the backend result.
class CarbonSummary {
  CarbonSummary(this.r) : lines = _lines(r);
  final CarbonResult r;
  final List<SourceLine> lines;

  static List<SourceLine> _lines(CarbonResult r) {
    final out = <SourceLine>[];
    for (final s in CarbonSource.values) {
      var amount = 0.0, tonnes = 0.0, months = 0;
      for (final m in r.months) {
        final (a, t) = switch (s) {
          CarbonSource.electricity => (m.electricityKwh, m.scope2ElectricityT),
          CarbonSource.diesel => (m.dieselLitres, m.scope1DieselT),
          CarbonSource.gas => (m.gasM3, m.scope1GasT),
          CarbonSource.lpg => (m.lpgKg, m.scope1LpgT),
          CarbonSource.furnaceOil => (m.furnaceOilLitres, m.scope1FurnaceOilT),
        };
        if (a == null || t == null) continue;
        amount += a;
        tonnes += t;
        months++;
      }
      if (months > 0) out.add(SourceLine(source: s, amount: amount, tonnes: tonnes, months: months, factorKg: r.factors[_factorNames[s]]?.value));
    }
    return out;
  }

  double get totalT => lines.fold(0, (a, l) => a + l.tonnes);

  /// The source with the most CO2, or null when nothing was calculated.
  SourceLine? get biggest => lines.isEmpty || totalT <= 0 ? null : lines.reduce((a, b) => b.tonnes > a.tonnes ? b : a);

  double share(SourceLine l) => totalT <= 0 ? 0 : l.tonnes / totalT;

  double? get perMonth {
    final n = r.totals.monthsWithData;
    final t = r.totals.totalT;
    return n > 0 && t != null ? t / n : null;
  }

  MonthEmissions? get peakMonth {
    MonthEmissions? best;
    for (final m in r.months) {
      if (m.totalT != null && (best == null || m.totalT! > best.totalT!)) best = m;
    }
    return best;
  }

  /// What using 10% less grid electricity for a year would save, from this report's bills.
  ({double kwh, double tonnes})? tenPercentLessElectricity() {
    SourceLine? e;
    for (final l in lines) {
      if (l.source == CarbonSource.electricity) e = l;
    }
    if (e == null || e.months == 0 || e.factorKg == null) return null;
    final kwh = e.amount / e.months * 12 * 0.1;
    return (kwh: kwh, tonnes: kwh * e.factorKg! / 1000);
  }
}

/// Which energy source each catalog action cuts.
/// Fuels burned in boilers; steam-side actions cut whichever of them the factory uses.
const boilerFuels = {CarbonSource.gas, CarbonSource.lpg, CarbonSource.furnaceOil};

/// The energy sources a catalog action cuts.
Set<CarbonSource> actionSources(String code) => actionSource(code) == CarbonSource.gas ? boilerFuels : {actionSource(code)};

/// The energy source a catalog action mainly cuts (gas stands for any boiler fuel).
CarbonSource actionSource(String code) => switch (code) {
  'steam_leaks' => CarbonSource.gas,
  'generator_hours' => CarbonSource.diesel,
  _ => CarbonSource.electricity,
};

enum ActionCost { free, low, medium, high }

/// Rough cost level of each catalog action, used only as a label.
ActionCost actionCost(String code) => switch (code) {
  'switch_off_idle' || 'lower_air_pressure' || 'generator_hours' => ActionCost.free,
  'fix_air_leaks' || 'steam_leaks' => ActionCost.low,
  'rooftop_solar' => ActionCost.high,
  _ => ActionCost.medium,
};

/// Catalog codes ordered for this factory: actions on the source with the most CO2
/// first, cheaper ones first within a source. Without a report, cheapest first.
List<String> rankActions(Iterable<String> codes, CarbonSummary? s) {
  final share = {for (final l in s?.lines ?? const <SourceLine>[]) l.source: s!.share(l)};
  final list = codes.toList();
  final index = {for (final (i, c) in list.indexed) c: i};
  return list
    ..sort((a, b) {
      double cut(String c) => actionSources(c).fold(0.0, (sum, s) => sum + (share[s] ?? 0));
      final bySource = cut(b).compareTo(cut(a));
      if (bySource != 0) return bySource;
      final byCost = actionCost(a).index.compareTo(actionCost(b).index);
      return byCost != 0 ? byCost : index[a]!.compareTo(index[b]!);
    });
}

/// Whether a catalog action can apply to this factory, from the energy sources in its
/// profile: no generator action without diesel, no steam action without a boiler fuel,
/// no rooftop solar suggestion when solar is already installed. Unknown profile: all apply.
bool actionFits(String code, FactoryProfile? profile) {
  if (profile == null) return true;
  return switch (code) {
    'generator_hours' => profile.uses('diesel'),
    'steam_leaks' => profile.uses('gas') || profile.uses('lpg') || profile.uses('furnace_oil'),
    'rooftop_solar' => !(profile.energySources?.contains('solar') ?? false),
    _ => true,
  };
}
