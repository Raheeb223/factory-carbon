/// CSV exports generated on the device from local data (spec 6.5 / 8.8).
library;

import 'package:csv/csv.dart';

import 'api_models.dart';
import 'models.dart';

final _csv = Csv(lineDelimiter: '\n');

String _n(double? v) => v == null ? '' : _trim(v);
String _trim(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

/// Monthly emissions table from the (cached) carbon result. Empty cells mean no data.
String emissionsCsv(CarbonResult r, {required bool containsSynthetic}) {
  final rows = <List<Object?>>[
    ['month', 'electricity_kwh', 'diesel_litres', 'gas_m3', 'lpg_kg', 'furnace_oil_litres', 'scope1_tco2e', 'scope2_tco2e', 'total_tco2e', 'complete', 'missing', 'production_units', 'tco2e_per_1000_units'],
    for (final m in r.months)
      [m.month, _n(m.electricityKwh), _n(m.dieselLitres), _n(m.gasM3), _n(m.lpgKg), _n(m.furnaceOilLitres), _n(m.scope1T), _n(m.scope2T), _n(m.totalT), m.isComplete ? 'yes' : 'no', m.missing.join(';'), _n(m.productionUnits), _n(m.intensity)],
    [],
    ['factor', 'value', 'unit', 'source', 'year', 'status'],
    for (final f in r.factors.values) [f.name, _n(f.value), f.unit, f.source, f.year?.toString() ?? '', f.status],
    [],
    ['note'],
    for (final n in r.notes) [n.months.isEmpty ? n.message : '${n.message} (${n.months.join(', ')})'],
    if (r.placeholdersInUse.isNotEmpty) ['DRAFT: contains unverified emission factors'],
    if (containsSynthetic) ['SYNTHETIC DEMO DATA - not a real factory'],
  ];
  return _csv.encode(rows);
}

/// All confirmed bills and production entries as raw data.
String rawDataCsv(List<Bill> bills, List<ProductionEntry> production) {
  final rows = <List<Object?>>[
    ['record', 'month', 'type', 'quantity', 'unit', 'total_amount_bdt', 'tariff_code', 'origin', 'user_edited_fields', 'synthetic'],
    for (final b in bills)
      ['bill', b.billingMonth, b.billType.wire, _trim(b.consumedUnits), b.unit.wire, _n(b.totalAmountBdt), b.tariffCode ?? '', b.origin.wire, b.userEditedFields.join(';'), b.isSynthetic ? 'yes' : 'no'],
    for (final p in production) ['production', p.month, 'production', _trim(p.unitsProduced), 'units', '', '', p.origin.wire, '', p.isSynthetic ? 'yes' : 'no'],
  ];
  return _csv.encode(rows);
}
