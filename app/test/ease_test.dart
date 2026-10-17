import 'package:factory_carbon/core/format.dart';
import 'package:factory_carbon/core/l10n/gen/app_localizations.dart';
import 'package:factory_carbon/data/drift_repositories.dart';
import 'package:factory_carbon/domain/api_models.dart';
import 'package:factory_carbon/features/carbon/carbon_screen.dart';
import 'package:factory_carbon/features/waste/waste_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'domain_test.dart' show carbonJsonFixture;
import 'helpers.dart';

final _en = lookupAppLocalizations(const Locale('en'));
final _bn = lookupAppLocalizations(const Locale('bn'));

Map<String, dynamic> _insufficient() => {
      'status': 'insufficient_data',
      'method': null,
      'confidence_label': null,
      'month_count': 1,
      'required_months': 6,
      'months': <Object>[],
      'flagged_months': <Object>[],
      'avg_bdt_per_kwh': null,
      'messages': <Object>['Only 1 month(s) of electricity data.'],
      'limitations': <Object>[],
      'model_summary': <String, Object>{},
    };

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  test('electricity cost only when every bill in the period has an amount', () {
    final bills = [testBill(id: 'a', month: '2024-05', amount: 1000), testBill(id: 'b', month: '2024-06', amount: 2000), testBill(id: 'c', month: '2024-09', amount: null)];
    expect(electricityCostIn(bills, '2024-05', '2024-06'), 3000);
    expect(electricityCostIn(bills, '2024-05', '2024-12'), isNull, reason: 'September has no amount');
    expect(electricityCostIn(bills, '2025-01', '2025-12'), isNull);
    expect(electricityCostIn(bills, null, null), isNull);
  });

  test('share text: plain sentences, change from last year, cost, draft note, in both languages', () {
    CarbonResult withTotal(double t) {
      final j = carbonJsonFixture();
      j['totals'] = {...(j['totals'] as Map<String, dynamic>), 'total_t': t};
      return CarbonResult.fromJson(j);
    }

    final r = withTotal(50);
    final prev = withTotal(100);
    final text = shareSummaryText(_en, Fmt('en'), r, prev, 'pieces', factoryName: 'Rahman Knit', electricityCostBdt: 125000);
    expect(text, startsWith('Rahman Knit\nCO₂ report from our utility bills'));
    expect(text, contains('50% lower than'));
    expect(text, contains('Tk 125,000'));
    expect(text, endsWith('Made with BillToGreen.'));
    final bn = shareSummaryText(_bn, Fmt('bn'), r, null, 'পিস');
    expect(bn, contains('আমাদের ইউটিলিটি বিল থেকে CO₂ রিপোর্ট'));
    expect(bn, isNot(contains('lower')));
  });

  testWidgets('the electricity check runs by itself when opened with new data, and not again', (tester) async {
    final db = memoryDb();
    await tester.runAsync(() => DriftBillRepository(db).save(testBill(month: '2024-05')));
    final adapter = FakeAdapter((o) => jsonBody(_insufficient()));
    await tester.pumpWidget(testApp(const Scaffold(body: WasteView()), overrides: testOverrides(db: db, api: fakeApi(adapter))));
    await waitFor(tester, find.byKey(const Key('waste-insufficient')));
    await settle(tester);
    expect(adapter.requests.where((r) => r.path == '/v1/waste/analyze'), hasLength(1));
    await teardownDb(tester, db);
  });
}
