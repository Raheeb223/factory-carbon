import 'api_models.dart';
import 'models.dart';
import 'requests.dart';
import 'solar_summary.dart';

/// One billed month, as it was and as it would have been with the solar plan.
class ScenarioMonth {
  const ScenarioMonth({required this.month, required this.gridBeforeKwh, required this.solarKwh, this.costBeforeBdt, this.costAfterBdt});
  final String month; // YYYY-MM
  final double gridBeforeKwh;

  /// Solar power the factory uses itself that month (never more than it used).
  final double solarKwh;
  final double? costBeforeBdt;
  final double? costAfterBdt;

  double get gridAfterKwh => gridBeforeKwh - solarKwh;
}

/// The factory's last 12 billed months of grid electricity, with and without the solar plan.
/// Year-1 generation by calendar month; exports are not counted (no net metering assumed),
/// so the bill only falls by the solar power used on site, at the plan's price per kWh.
class SolarScenario {
  SolarScenario._(this.months, this.gridFactorKgPerKwh, this.solarGenerationKwh);

  /// Null when there are no electricity bills to compare against.
  static SolarScenario? of(SolarResult r, List<Bill> bills) {
    final elec = monthlyElectricity(bills);
    if (elec.isEmpty) return null;
    final last = elec.length > 12 ? elec.sublist(elec.length - 12) : elec;
    final price = r.financials?.priceBdtPerKwh;
    final months = [
      for (final e in last)
        () {
          final gen = r.monthlyGenerationKwh[int.parse(e.month.substring(5, 7)) - 1];
          final solar = gen < e.kwh ? gen : e.kwh;
          final cost = e.costBdt;
          return ScenarioMonth(
            month: e.month,
            gridBeforeKwh: e.kwh,
            solarKwh: solar,
            costBeforeBdt: cost,
            costAfterBdt: cost == null || price == null ? null : (cost - solar * price).clamp(0, double.infinity).toDouble(),
          );
        }(),
    ];
    final gen = [for (final m in months) r.monthlyGenerationKwh[int.parse(m.month.substring(5, 7)) - 1]].fold(0.0, (a, b) => a + b);
    return SolarScenario._(months, SolarSummary(r).gridFactorKgPerKwh, gen);
  }

  final List<ScenarioMonth> months;
  final double? gridFactorKgPerKwh;

  /// Everything the panels would produce in these months, used on site or not.
  final double solarGenerationKwh;

  double get gridBeforeKwh => months.fold(0, (a, m) => a + m.gridBeforeKwh);
  double get solarKwh => months.fold(0, (a, m) => a + m.solarKwh);
  double get gridAfterKwh => gridBeforeKwh - solarKwh;

  /// Share of the electricity that would come from the roof instead of the grid.
  double get solarShare => gridBeforeKwh == 0 ? 0 : solarKwh / gridBeforeKwh;

  bool get hasCost => months.every((m) => m.costBeforeBdt != null && m.costAfterBdt != null);
  double? get costBeforeBdt => hasCost ? months.fold<double>(0, (a, m) => a + m.costBeforeBdt!) : null;
  double? get costAfterBdt => hasCost ? months.fold<double>(0, (a, m) => a + m.costAfterBdt!) : null;

  /// Grid electricity CO2 (Scope 2) in tonnes, before and after.
  double? get co2BeforeT => gridFactorKgPerKwh == null ? null : gridBeforeKwh * gridFactorKgPerKwh! / 1000;
  double? get co2AfterT => gridFactorKgPerKwh == null ? null : gridAfterKwh * gridFactorKgPerKwh! / 1000;
}
