import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../domain/models.dart';

/// Practical energy-saving actions for garment factories, in the order they are
/// usually cheapest to do. [inspection] links an action to a check from the
/// unusual-use detector, so a flagged month leads straight to an action.
class ActionKind {
  const ActionKind(this.code, this.icon, {this.inspection});
  final String code;
  final IconData icon;
  final String? inspection;
}

const actionCatalog = [
  ActionKind('fix_air_leaks', Icons.air_rounded, inspection: 'compressed_air'),
  ActionKind('switch_off_idle', Icons.power_settings_new_rounded, inspection: 'idle_machines'),
  ActionKind('lower_air_pressure', Icons.compress_rounded, inspection: 'compressed_air'),
  ActionKind('steam_leaks', Icons.local_fire_department_rounded, inspection: 'boiler_steam'),
  ActionKind('generator_hours', Icons.electrical_services_rounded, inspection: 'generator'),
  ActionKind('led_lighting', Icons.lightbulb_rounded),
  ActionKind('servo_motors', Icons.settings_suggest_rounded),
  ActionKind('power_factor', Icons.tune_rounded),
  ActionKind('rooftop_solar', Icons.solar_power_rounded),
];

ActionKind? actionKind(String code) {
  for (final k in actionCatalog) {
    if (k.code == code) return k;
  }
  return null;
}

/// The first catalog action for a detector inspection code (null for "rule out
/// normal reasons", which is a check, not an action).
ActionKind? actionForInspection(String inspection) {
  for (final k in actionCatalog) {
    if (k.inspection == inspection) return k;
  }
  return null;
}

String actionTitle(AppLocalizations l, EnergyAction a) => a.code == 'custom' ? a.title : actionCodeTitle(l, a.code);

String actionCodeTitle(AppLocalizations l, String code) => switch (code) {
  'fix_air_leaks' => l.actFixAirLeaks,
  'switch_off_idle' => l.actSwitchOffIdle,
  'lower_air_pressure' => l.actLowerAirPressure,
  'steam_leaks' => l.actSteamLeaks,
  'generator_hours' => l.actGeneratorHours,
  'led_lighting' => l.actLedLighting,
  'servo_motors' => l.actServoMotors,
  'power_factor' => l.actPowerFactor,
  'rooftop_solar' => l.actRooftopSolar,
  _ => code,
};

/// Numbered steps for a catalog action (one line per step).
List<String> actionCodeSteps(AppLocalizations l, String code) => switch (code) {
  'fix_air_leaks' => l.actFixAirLeaksSteps,
  'switch_off_idle' => l.actSwitchOffIdleSteps,
  'lower_air_pressure' => l.actLowerAirPressureSteps,
  'steam_leaks' => l.actSteamLeaksSteps,
  'generator_hours' => l.actGeneratorHoursSteps,
  'led_lighting' => l.actLedLightingSteps,
  'servo_motors' => l.actServoMotorsSteps,
  'power_factor' => l.actPowerFactorSteps,
  'rooftop_solar' => l.actRooftopSolarSteps,
  _ => '',
}.split('\n').where((e) => e.trim().isNotEmpty).toList();

/// Localized inspection for a detector code; the server's English text as fallback.
(String, String) inspectionText(AppLocalizations l, String code, String title, String detail) => switch (code) {
  'confirm_cause' => (l.inspConfirmCause, l.inspConfirmCauseHow),
  'compressed_air' => (l.inspCompressedAir, l.inspCompressedAirHow),
  'idle_machines' => (l.inspIdleMachines, l.inspIdleMachinesHow),
  'boiler_steam' => (l.inspBoilerSteam, l.inspBoilerSteamHow),
  'generator' => (l.inspGenerator, l.inspGeneratorHow),
  _ => (title, detail),
};
