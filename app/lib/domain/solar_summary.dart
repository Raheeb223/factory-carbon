import 'api_models.dart';

/// Panel sizes offered as one-tap answers. Most panels sold for factory roofs
/// are 540–600 W; 550 W is the default when the user does not choose.
const panelWattChoices = [450, 550, 600];
const defaultPanelWatt = 550;

/// Whole panels that fit in the estimated system size (rounded down, so they fit).
int panelCount(double kwp, int panelWatt) => panelWatt <= 0 ? 0 : (kwp * 1000 / panelWatt + 1e-9).floor();

/// Plain numbers behind the solar result screen, all derived from the backend estimate.
class SolarSummary {
  SolarSummary(this.r, {int? panelWatt}) : panelWatt = panelWatt ?? defaultPanelWatt;
  final SolarResult r;
  final int panelWatt;

  int get panels => panelCount(r.kwp, panelWatt);
  double get unitsPerMonth => r.annualGenerationKwh / 12;
  double? get usePerMonth => r.annualConsumptionKwh == null ? null : r.annualConsumptionKwh! / 12;

  double? param(String name) {
    for (final p in r.params) {
      if (p.name == name) return p.number;
    }
    return null;
  }

  double? get usableShare => param('usable_roof_fraction');
  double? get m2PerKwp => param('m2_per_kwp');
  double? get efficiency => param('performance_ratio');
  double get shade => param('shading_loss') ?? 0;
  double? get gridFactorKgPerKwh => r.factors['grid_electricity']?.value;
}
