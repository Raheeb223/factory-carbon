import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:factory_carbon/domain/csv_export.dart';
import 'package:factory_carbon/domain/api_models.dart';
import 'package:factory_carbon/domain/demo_data.dart';
import 'package:factory_carbon/domain/history_csv.dart';
import 'package:factory_carbon/domain/image_prep.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/domain/requests.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'helpers.dart';

void main() {
  var counter = 0;
  String id() => 'id-${counter++}';

  group('requests', () {
    test('carbonRequest sends only typed bills with canonical units', () {
      final body = carbonRequest(
        bills: [
          testBill(id: 'a'),
          testBill(id: 'b', type: BillType.unknown, unit: EnergyUnit.kWh),
          testBill(id: 'c', type: BillType.gas, unit: EnergyUnit.kWh),
          testBill(id: 'd', type: BillType.diesel, units: 50, origin: DataOrigin.imported, edited: ['consumed_units']),
        ],
        production: [ProductionEntry(id: 'p', month: '2024-05', unitsProduced: 1000, origin: DataOrigin.manual, updatedAt: DateTime(2026))],
        productionUnitLabel: 'pieces',
      );
      final bills = body['bills'] as List<dynamic>;
      expect(bills, hasLength(2));
      expect(bills.last, containsPair('origin', 'imported'));
      expect(bills.last, containsPair('user_edited_fields', ['consumed_units']));
      expect(body['production'], [
        {'month': '2024-05', 'units_produced': 1000.0, 'origin': 'manual'},
      ]);
    });

    test('monthly electricity cost is null unless every bill has an amount', () {
      final m = monthlyElectricity([
        testBill(id: '1', month: '2024-01', units: 100, amount: 1000),
        testBill(id: '2', month: '2024-01', units: 50, amount: 500),
        testBill(id: '3', month: '2024-02', units: 100, amount: 1000),
        testBill(id: '4', month: '2024-02', units: 100, amount: null),
        testBill(id: '5', type: BillType.diesel, month: '2024-02', units: 10),
      ]);
      expect(m.map((e) => (e.month, e.kwh, e.costBdt)).toList(), [('2024-01', 150.0, 1500.0), ('2024-02', 200.0, null)]);
    });

    test('wasteRequest joins production by month', () {
      final body = wasteRequest(
        bills: [testBill(month: '2024-01', units: 100)],
        production: [ProductionEntry(id: 'p', month: '2024-01', unitsProduced: 5, origin: DataOrigin.manual, updatedAt: DateTime(2026))],
      );
      expect((body['months'] as List<dynamic>).single, {'month': '2024-01', 'kwh': 100.0, 'production': 5.0, 'cost_bdt': 684.0});
    });

    test('editedFields detects changed values only', () {
      expect(editedFields({'a': 120.0, 'b': 'LT-B', 'c': null}, {'a': 120, 'b': 'LT-B', 'c': null}), isEmpty);
      expect(editedFields({'a': 100.0, 'b': 'LT-B', 'c': null}, {'a': 120.0, 'b': 'LT-A', 'c': 'x'}), ['a', 'b', 'c']);
    });

    test('findDuplicate matches month + type and skips the edited bill', () {
      final bills = [testBill(id: 'x', month: '2024-05')];
      expect(findDuplicate(bills, type: BillType.electricity, month: '2024-05')?.id, 'x');
      expect(findDuplicate(bills, type: BillType.gas, month: '2024-05'), isNull);
      expect(findDuplicate(bills, type: BillType.electricity, month: '2024-05', excludeId: 'x'), isNull);
    });

    test('inputHash is stable and sensitive', () {
      expect(inputHash('{"a":1}'), inputHash('{"a":1}'));
      expect(inputHash('{"a":1}'), isNot(inputHash('{"a":2}')));
      expect(inputHash(''), hasLength(8));
    });
  });

  group('history csv', () {
    const header = 'month,electricity_kwh,diesel_litres,gas_m3,production_units,electricity_cost_bdt';

    test('valid file parses, sorted, with optional cost', () {
      final p = parseHistoryCsv('$header\n2024-02,"12,000",100,,50000,120000\n2024-01,11000,,500,48000,\n');
      expect(p.canImport, isTrue);
      expect(p.rows.map((r) => r.month), ['2024-01', '2024-02']);
      expect(p.rows.last.electricityKwh, 12000);
      expect(p.rows.last.electricityCostBdt, 120000);
      expect(p.rows.first.gasM3, 500);
      expect(p.rows.first.dieselLitres, isNull);
    });

    test('errors: bad month, number, negative, duplicate', () {
      final p = parseHistoryCsv('$header\n2024-13,1,,,,\n2024-01,abc,,,,\n2024-02,-5,,,,\n2024-03,1,,,,\n2024-03,2,,,,\n');
      expect(p.canImport, isFalse);
      expect(p.errors.map((e) => (e.code, e.row)), [
        (ImportIssueCode.badMonth, 2),
        (ImportIssueCode.badNumber, 3),
        (ImportIssueCode.negativeNumber, 4),
        (ImportIssueCode.duplicateMonth, 6),
      ]);
    });

    test('missing columns and empty file', () {
      expect(parseHistoryCsv('month,kwh\n2024-01,5').errors.single.code, ImportIssueCode.missingColumns);
      expect(parseHistoryCsv('').errors.single.code, ImportIssueCode.noRows);
      expect(parseHistoryCsv('$header\n').errors.single.code, ImportIssueCode.noRows);
    });

    test('Bangla digits, BOM and semicolon delimiter are accepted', () {
      final p = parseHistoryCsv('﻿${header.replaceAll(',', ';')}\n২০২৪-০৫;১২০;;;;\n');
      expect(p.errors, isEmpty);
      expect(p.rows.single.month, '2024-05');
      expect(p.rows.single.electricityKwh, 120);
    });

    test('warnings: empty row skipped, cost without kWh', () {
      final p = parseHistoryCsv('$header\n2024-01,,,,,\n2024-02,,5,,,100\n');
      expect(p.warnings.map((w) => w.code), [ImportIssueCode.emptyRow, ImportIssueCode.costWithoutKwh]);
      expect(p.rows, hasLength(1));
    });

    test('rows become imported bills and production', () {
      final p = parseHistoryCsv('$header\n2024-01,100,10,20,300,1000\n');
      final data = importRowsToData(p.rows, newId: id);
      expect(data.bills.map((b) => (b.billType, b.unit, b.origin)), [
        (BillType.electricity, EnergyUnit.kWh, DataOrigin.imported),
        (BillType.diesel, EnergyUnit.litre, DataOrigin.imported),
        (BillType.gas, EnergyUnit.m3, DataOrigin.imported),
      ]);
      expect(data.bills.first.totalAmountBdt, 1000);
      expect(data.production, [('2024-01', 300.0)]);
    });

    test('bundled template has the expected header', () {
      final text = File('assets/templates/history_template.csv').readAsStringSync();
      expect(text.split('\n').first.trim(), historyColumns.join(','));
    });
  });

  group('csv export', () {
    test('emissions csv marks drafts and synthetic data, empty cells for no data', () {
      final r = CarbonResult.fromJson(_carbonJson());
      final text = emissionsCsv(r, containsSynthetic: true);
      final lines = text.split('\n');
      expect(lines.first, startsWith('month,electricity_kwh'));
      expect(lines[2], startsWith('2024-02,,')); // month without data stays empty, not 0
      expect(text, contains('DRAFT: contains unverified emission factors'));
      expect(text, contains('SYNTHETIC DEMO DATA'));
    });

    test('raw data csv lists bills and production', () {
      final text = rawDataCsv([testBill(origin: DataOrigin.demo)], [ProductionEntry(id: 'p', month: '2024-05', unitsProduced: 10, origin: DataOrigin.imported, updatedAt: DateTime(2026))]);
      expect(text, contains('bill,2024-05,electricity,120,kWh,684,,demo,,yes'));
      expect(text, contains('production,2024-05,production,10,units,,,imported,,no'));
    });
  });

  group('demo data', () {
    test('bundled asset is synthetic: 24 months, 72 bills, 2 anomalies', () {
      final demo = parseDemoData(File('assets/demo/demo_data.json').readAsStringSync(), newId: id);
      expect(demo.bills, hasLength(72));
      expect(demo.production, hasLength(24));
      expect(demo.anomalyMonths, hasLength(2));
      expect(demo.bills.every((b) => b.origin == DataOrigin.demo && b.isSynthetic), isTrue);
    });

    test('refuses data not marked synthetic', () {
      expect(() => parseDemoData(jsonEncode({'synthetic': false, 'months': <Object>[]}), newId: id), throwsFormatException);
    });
  });

  group('image prep', () {
    test('large image is resized to 1600px long edge and metadata stripped', () {
      final big = img.Image(width: 3200, height: 2000);
      big.exif.imageIfd['Make'] = img.IfdValueAscii('PhoneCo');
      final out = prepareForUpload(Uint8List.fromList(img.encodeJpg(big)));
      final decoded = img.decodeJpg(out)!;
      expect(decoded.width, 1600);
      expect(decoded.height, 1000);
      expect(decoded.exif.isEmpty, isTrue);
    });

    test('small portrait image keeps its size', () {
      final out = prepareForUpload(Uint8List.fromList(img.encodePng(img.Image(width: 600, height: 900))));
      final decoded = img.decodeJpg(out)!;
      expect((decoded.width, decoded.height), (600, 900));
    });

    test('garbage input throws', () {
      expect(() => prepareForUpload(Uint8List.fromList([1, 2, 3])), throwsA(isA<ImagePrepException>()));
    });
  });
}

Map<String, dynamic> _carbonJson() => {
      'period_start': '2024-01',
      'period_end': '2024-02',
      'months': [
        {
          'month': '2024-01', 'electricity_kwh': 1000, 'diesel_litres': null, 'gas_m3': null, 'scope2_electricity_t': null,
          'scope1_diesel_t': null, 'scope1_gas_t': null, 'scope1_t': null, 'scope2_t': null, 'total_t': null,
          'is_complete': false, 'missing': ['electricity:factor_not_set'], 'production_units': null, 'intensity_t_per_1000_units': null,
        },
        {
          'month': '2024-02', 'electricity_kwh': null, 'diesel_litres': null, 'gas_m3': null, 'scope2_electricity_t': null,
          'scope1_diesel_t': null, 'scope1_gas_t': null, 'scope1_t': null, 'scope2_t': null, 'total_t': null,
          'is_complete': false, 'missing': ['electricity:no_data'], 'production_units': null, 'intensity_t_per_1000_units': null,
        },
      ],
      'totals': {
        'scope1_t': null, 'scope2_t': null, 'total_t': null, 'production_units': null, 'intensity_t_per_1000_units': null,
        'months_in_period': 2, 'months_with_data': 1, 'complete_months': 0,
      },
      'factors': {
        'grid_electricity': {'name': 'grid_electricity', 'value': null, 'unit': 'kg_CO2e_per_kWh', 'source': '', 'year': null, 'status': 'PLACEHOLDER'},
      },
      'placeholders_in_use': ['diesel'],
      'errors': [
        {'code': 'factor_not_set', 'factor': 'grid_electricity', 'message': 'not set'},
      ],
      'data_quality_notes': [
        {'code': 'missing_electricity_data', 'message': 'gap', 'months': ['2024-02']},
      ],
      'production_unit_label': 'pieces',
      'methodology': ['x'],
    };

/// Exposed for widget tests.
Map<String, dynamic> carbonJsonFixture() => _carbonJson();
