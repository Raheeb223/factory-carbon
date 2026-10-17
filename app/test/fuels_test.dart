import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/domain/api_models.dart';
import 'package:factory_carbon/domain/carbon_summary.dart';
import 'package:factory_carbon/domain/history_csv.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/domain/requests.dart';
import 'package:flutter_test/flutter_test.dart';

import 'domain_test.dart' show carbonJsonFixture;
import 'helpers.dart';

void main() {
  test('LPG and furnace oil use the backend names and units', () {
    expect(BillType.furnaceOil.wire, 'furnace_oil');
    expect(BillType.parse('furnace_oil'), BillType.furnaceOil);
    expect(BillType.parse('lpg'), BillType.lpg);
    expect(BillType.lpg.canonicalUnit, EnergyUnit.kg);
    expect(BillType.furnaceOil.canonicalUnit, EnergyUnit.litre);
    final body = carbonRequest(bills: [testBill(id: 'f', type: BillType.furnaceOil, units: 900)], production: const []);
    expect((body['bills'] as List<dynamic>).single, allOf(containsPair('bill_type', 'furnace_oil'), containsPair('unit', 'litre')));
  });

  test('history import reads the optional LPG and furnace oil columns; old templates still work', () {
    final p = parseHistoryCsv('month,electricity_kwh,diesel_litres,gas_m3,production_units,lpg_kg,furnace_oil_litres\n2026-01,1000,,,,450,1200\n2026-02,,,,,90,\n');
    expect(p.canImport, isTrue);
    final bills = importRowsToData(p.rows, newId: () => 'x').bills;
    expect([for (final b in bills) (b.billType, b.consumedUnits, b.unit)], [
      (BillType.electricity, 1000.0, EnergyUnit.kWh),
      (BillType.lpg, 450.0, EnergyUnit.kg),
      (BillType.furnaceOil, 1200.0, EnergyUnit.litre),
      (BillType.lpg, 90.0, EnergyUnit.kg),
    ]);
    expect(parseHistoryCsv('month,electricity_kwh,diesel_litres,gas_m3,production_units\n2026-01,1000,,,\n').canImport, isTrue);
  });

  test('a furnace oil bill is stored and read back with its type', () async {
    final db = memoryDb();
    await DriftBillRepository(db).save(testBill(id: 'fo', type: BillType.furnaceOil, units: 500));
    expect((await DriftBillRepository(db).all()).single.billType, BillType.furnaceOil);
    await db.close();
  });

  test('summary lines include LPG, and steam actions count for any boiler fuel', () {
    final json = carbonJsonFixture();
    final month = (json['months'] as List<dynamic>).first as Map<String, dynamic>;
    month['lpg_kg'] = 1000.0;
    month['scope1_lpg_t'] = 50.0;
    json['factors'] = <String, dynamic>{...(json['factors'] as Map<String, dynamic>), 'lpg': <String, dynamic>{
      'name': 'lpg',
      'value': 2.93936,
      'unit': 'kg_CO2e_per_kg',
      'source': 'DESNZ 2026',
      'year': 2026,
      'status': 'verified',
    }};
    final s = CarbonSummary(CarbonResult.fromJson(json));
    final lpg = s.lines.singleWhere((l) => l.source == CarbonSource.lpg);
    expect(lpg.amount, 1000);
    expect(lpg.factorKg, 2.93936);
    expect(actionSources('steam_leaks'), containsAll([CarbonSource.gas, CarbonSource.lpg, CarbonSource.furnaceOil]));
    expect(s.biggest?.source, CarbonSource.lpg);
    expect(rankActions(['led_lighting', 'steam_leaks'], s).first, 'steam_leaks');
  });
}
