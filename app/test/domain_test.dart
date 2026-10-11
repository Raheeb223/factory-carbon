import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:factory_carbon/domain/csv_export.dart';
import 'package:factory_carbon/domain/api_models.dart';
import 'package:factory_carbon/domain/demo_data.dart';
import 'package:factory_carbon/domain/history_csv.dart';
import 'package:factory_carbon/domain/image_prep.dart';
import 'package:factory_carbon/domain/impact.dart';
import 'package:factory_carbon/domain/models.dart';
import 'package:factory_carbon/domain/private_text.dart';
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

    test('redaction burns black boxes into the pixels and leaves the rest', () {
      final white = img.Image(width: 400, height: 200);
      img.fill(white, color: img.ColorRgb8(255, 255, 255));
      final out = applyRedactions(Uint8List.fromList(img.encodeJpg(white)), const [RedactBox(0.1, 0.2, 0.5, 0.6)]);
      final d = img.decodeJpg(out)!;
      expect((d.width, d.height), (400, 200));
      expect(d.getPixel(120, 80).r, lessThan(30)); // inside the box: black
      expect(d.getPixel(300, 160).r, greaterThan(225)); // outside: still white
      final untouched = Uint8List.fromList([1, 2, 3]);
      expect(identical(applyRedactions(untouched, const []), untouched), isTrue); // no boxes: no re-encode
    });
  });

  group('measured savings', () {
    // 6 months at 0.5 kWh/unit, then an action in 2024-07, then 0.45 kWh/unit with
    // 20% more production: the extra output is not counted as extra use.
    final bills = <Bill>[];
    final production = <ProductionEntry>[];
    void month(String m, double units, double kwhPerUnit) {
      bills.add(testBill(id: m, month: m, units: units * kwhPerUnit, amount: units * kwhPerUnit * 10));
      production.add(ProductionEntry(id: m, month: m, unitsProduced: units, origin: DataOrigin.manual, updatedAt: DateTime(2024)));
    }

    for (var i = 1; i <= 6; i++) {
      month('2024-0$i', 10000, 0.5);
    }
    month('2024-07', 10000, 0.6); // action month: left out
    month('2024-08', 12000, 0.45);
    month('2024-09', 12000, 0.45);

    test('production-adjusted before/after with Tk and CO2', () {
      final r = measureSince('2024-07', bills: bills, production: production, gridKgPerKwh: 0.62);
      expect(r.status, ImpactStatus.measured);
      expect(r.baselineKwhPerUnit, closeTo(0.5, 1e-9));
      expect(r.monthsBefore, 6);
      expect(r.monthsAfter, 2);
      expect(r.settled, isFalse); // fewer than 3 months after: early result
      expect(r.savedKwh, closeTo(2 * 12000 * 0.05, 1e-6)); // 1,200 kWh
      expect(r.savedBdt, closeTo(12000, 1e-6)); // Tk 10/kWh
      expect(r.savedCo2Kg, closeTo(744, 1e-6));
      expect(r.changePct, closeTo(-10, 1e-9));
    });

    test('statuses: planned, too early, not enough history, no production', () {
      expect(measureSince(null, bills: bills, production: production).status, ImpactStatus.planned);
      expect(measureSince('2024-09', bills: bills, production: production).status, ImpactStatus.tooEarly);
      expect(measureSince('2024-03', bills: bills, production: production).status, ImpactStatus.noBaseline);
      expect(measureSince('2024-07', bills: bills, production: const []).status, ImpactStatus.noProduction);
      expect(
        firstDoneMonth([
          EnergyAction(id: 'a', code: 'led_lighting', doneMonth: '2024-08', origin: DataOrigin.manual, updatedAt: DateTime(2024)),
          EnergyAction(id: 'b', code: 'fix_air_leaks', doneMonth: '2024-05', origin: DataOrigin.manual, updatedAt: DateTime(2024)),
          EnergyAction(id: 'c', code: 'servo_motors', origin: DataOrigin.manual, updatedAt: DateTime(2024)),
        ]),
        '2024-05',
      );
    });

    test('bundled demo data has a done action with measurable savings', () {
      final demo = parseDemoData(File('assets/demo/demo_data.json').readAsStringSync(), newId: () => 'x');
      final done = demo.actions.where((a) => a.done).single;
      final production = [for (final (m, u) in demo.production) ProductionEntry(id: m, month: m, unitsProduced: u, origin: DataOrigin.demo, updatedAt: DateTime(2024))];
      final r = measureSince(done.doneMonth, bills: demo.bills, production: production, gridKgPerKwh: 0.62);
      expect(r.status, ImpactStatus.measured);
      expect(r.savedKwh, greaterThan(0));
      expect(r.changePct!, lessThan(-3));
    });
  });

  group('automatic name hiding', () {
    test('names and addresses are private; values, labels and misread Bangla are not', () {
      for (final t in ['MD. ROIS UDDIN', 'MD', 'MD ABDUL JALIL', 'Consumer Name: Karim', 'House 12, Road 5', 'FLAT NO-B/3', 'DHAKA-', 'Rahima Begum', 'Anwar Kabir']) {
        expect(looksPrivate(t), isTrue, reason: t);
      }
      for (final t in ['1097', 'Aug-26', '16054.45', 'Units Consumed: 12,450 kWh', 'Total Amount Payable', 'Bill Month', 'faer', 'jsteto', 'podpebd', 'C6 / 42', 'x', 'LT-E (Industrial)', 'Tariff: LT-E (Industrial)', 'LT-E (INDUSTRIAL)']) {
        expect(looksPrivate(t), isFalse, reason: t);
      }
    });

    // Lines the phone's text reader found on a real DPDC bill (boxes as fractions).
    const dpdc = [
      FoundText('MD', 0.07, 0.166, 0.098, 0.178),
      FoundText('ROIS DDIN', 0.117, 0.163, 0.223, 0.176),
      FoundText('MD ABDUL JAL IL', 0.072, 0.19, 0.219, 0.202),
      FoundText('ESKATON CARDEN', 0.1, 0.201, 0.251, 0.213),
      FoundText('AT NO-B/3', 0.091, 0.213, 0.184, 0.223),
      FoundText('FLA', 0.07, 0.218, 0.098, 0.226),
      FoundText('DHAK-', 0.077, 0.223, 0.133, 0.236),
      FoundText('T-A 11 05', 0.076, 0.248, 0.179, 0.264),
      FoundText('faer', 0.453, 0.132, 0.475, 0.145),
      FoundText('Aug-6', 0.422, 0.166, 0.489, 0.182),
      FoundText('ADESH PLEPy', 0.249, 0.308, 0.331, 0.343), // bank stamp over a value
      FoundText('tts. 95', 0.274, 0.332, 0.364, 0.346),
      FoundText('1097', 0.507, 0.281, 0.551, 0.297),
      FoundText('16054., 45', 0.269, 0.446, 0.357, 0.459),
    ];

    bool covers(RedactBox b, FoundText t) {
      final x = (t.left + t.right) / 2;
      final y = (t.top + t.bottom) / 2;
      return x >= b.left && x <= b.right && y >= b.top && y <= b.bottom;
    }

    bool touches(RedactBox b, FoundText t) => b.left < t.right && t.left < b.right && b.top < t.bottom && t.top < b.bottom;

    test('the name and address block of a real bill becomes one box; no value is touched', () {
      final boxes = privateBoxes(dpdc);
      expect(boxes, hasLength(1));
      for (final t in dpdc.take(7)) {
        expect(covers(boxes.single, t), isTrue, reason: '${t.text} (incl. "AT NO-B/3", which alone looks like a value)');
      }
      for (final t in dpdc.skip(7)) {
        expect(touches(boxes.single, t), isFalse, reason: t.text);
      }
    });

    test('a block box that would hide a value falls back to one box per line', () {
      const lines = [
        FoundText('MD KARIM', 0.1, 0.10, 0.3, 0.12),
        FoundText('1097', 0.12, 0.125, 0.2, 0.135), // sits inside the block
        FoundText('MIRPUR', 0.1, 0.14, 0.3, 0.16),
      ];
      final boxes = privateBoxes(lines);
      expect(boxes, hasLength(2));
      expect(boxes.any((b) => touches(b, lines[1])), isFalse);
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
