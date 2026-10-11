/// Builds API request bodies from local, confirmed data. Pure functions (unit-tested).
library;

import 'models.dart';

/// Bills whose type/unit can be sent to the carbon calculator.
Iterable<Bill> _usable(Iterable<Bill> bills) =>
    bills.where((b) => b.billType != BillType.unknown && b.unit == b.billType.canonicalUnit);

Map<String, dynamic> carbonRequest({
  required List<Bill> bills,
  required List<ProductionEntry> production,
  String? productionUnitLabel,
}) =>
    {
      'bills': [
        for (final b in _usable(bills))
          {
            'billing_month': b.billingMonth,
            'bill_type': b.billType.name,
            'consumed_units': b.consumedUnits,
            'unit': b.unit.wire,
            'total_amount_bdt': b.totalAmountBdt,
            'origin': b.origin.wire,
            'user_edited_fields': b.userEditedFields,
            'confirmed_at': b.confirmedAt.toUtc().toIso8601String(),
          },
      ],
      'production': [
        for (final p in production) {'month': p.month, 'units_produced': p.unitsProduced, 'origin': p.origin.wire},
      ],
      'production_unit_label': productionUnitLabel,
    };

class MonthlyElectricity {
  const MonthlyElectricity(this.month, this.kwh, this.costBdt);
  final String month;
  final double kwh;

  /// Null unless every electricity bill of the month has an amount.
  final double? costBdt;
}

List<MonthlyElectricity> monthlyElectricity(List<Bill> bills) {
  final kwh = <String, double>{};
  final cost = <String, double?>{};
  for (final b in bills.where((b) => b.billType == BillType.electricity && b.unit == EnergyUnit.kWh)) {
    kwh[b.billingMonth] = (kwh[b.billingMonth] ?? 0) + b.consumedUnits;
    final prev = cost.containsKey(b.billingMonth) ? cost[b.billingMonth] : 0.0;
    cost[b.billingMonth] = (prev == null || b.totalAmountBdt == null) ? null : prev + b.totalAmountBdt!;
  }
  final months = kwh.keys.toList()..sort();
  return [for (final m in months) MonthlyElectricity(m, kwh[m]!, cost[m])];
}

Map<String, dynamic> wasteRequest({
  required List<Bill> bills,
  required List<ProductionEntry> production,
  String? productionUnitLabel,
}) {
  final prod = <String, double>{};
  for (final p in production) {
    prod[p.month] = (prod[p.month] ?? 0) + p.unitsProduced;
  }
  return {
    'months': [
      for (final e in monthlyElectricity(bills)) {'month': e.month, 'kwh': e.kwh, 'production': prod[e.month], 'cost_bdt': e.costBdt},
    ],
    'production_unit_label': productionUnitLabel,
  };
}

List<Map<String, dynamic>> solarConsumption(List<Bill> bills) => [
      for (final e in monthlyElectricity(bills)) {'month': e.month, 'kwh': e.kwh, 'cost_bdt': e.costBdt},
    ];

/// Fields the user changed relative to what was extracted (spec 8.2: record edits).
List<String> editedFields(Map<String, Object?> extracted, Map<String, Object?> confirmed) {
  final out = <String>[];
  for (final key in confirmed.keys) {
    final a = extracted[key];
    final b = confirmed[key];
    if (a is num && b is num) {
      if ((a - b).abs() > 1e-9) out.add(key);
    } else if ((a?.toString() ?? '') != (b?.toString() ?? '')) {
      out.add(key);
    }
  }
  return out;
}

/// Existing active bill with the same month and type (duplicate warning, spec 8.3).
Bill? findDuplicate(List<Bill> existing, {required BillType type, required String month, String? excludeId}) {
  for (final b in existing) {
    if (b.id != excludeId && b.billType == type && b.billingMonth == month) return b;
  }
  return null;
}

/// Stable 32-bit FNV-1a hash of a JSON-encodable request, used to tell whether a
/// cached result still matches the local data (detects edits *and* deletions).
String inputHash(String jsonText) {
  var h = 0x811c9dc5;
  for (final unit in jsonText.codeUnits) {
    h ^= unit;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h.toRadixString(16).padLeft(8, '0');
}
