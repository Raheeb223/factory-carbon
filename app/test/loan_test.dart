import 'package:factory_carbon/domain/api_models.dart';
import 'package:factory_carbon/domain/loan.dart';
import 'package:factory_carbon/features/loan/green_loan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';
import 'ux_test.dart' show solarResultFixture;

/// 10 lakh capex, 3 lakh net savings a year for 25 years.
Map<String, dynamic> loanFinancialsFixture({double net = 300000}) => {
      'capex_bdt': 1000000.0,
      'electricity_price_bdt_per_kwh': 10.0,
      'year1_savings_bdt': net + 10000,
      'year1_om_bdt': 10000.0,
      'year1_net_bdt': net,
      'simple_payback_years': 1000000 / net,
      'cashflow': [
        {'year': 0, 'net_bdt': -1000000.0, 'cumulative_bdt': -1000000.0},
        for (var y = 1; y <= 25; y++) {'year': y, 'net_bdt': net, 'cumulative_bdt': -1000000 + net * y},
      ],
    };

SolarResult _result({double net = 300000}) => SolarResult.fromJson({...solarResultFixture(), 'financials': loanFinancialsFixture(net: net)});

void main() {
  test('instalment matches the annuity formula (same as the backend)', () {
    expect(monthlyInstalment(1000000, 9, 5), closeTo(20758.36, 0.01));
    expect(monthlyInstalment(120000, 0, 1), 10000);
  });

  test('loan plan skips the capex year and sums savings after the loan', () {
    final plan = LoanPlan.of(_result().financials, const LoanTerms(loanShare: 0.8, years: 5, annualRatePct: 9))!;
    expect(plan.loanBdt, 800000);
    expect(plan.ownMoneyBdt, 200000);
    expect(plan.minCoverage, closeTo(300000 / (plan.monthlyInstalmentBdt * 12), 1e-9));
    expect(plan.paysItself, isTrue);
    expect(plan.yearsAfterLoan, 20);
    expect(plan.savingsAfterLoanBdt, 20 * 300000);
    expect(LoanPlan.of(null, const LoanTerms()), isNull);
    // Small savings on a short loan do not cover it.
    final tight = LoanPlan.of(_result(net: 50000).financials, const LoanTerms(loanShare: 1, years: 2, annualRatePct: 12))!;
    expect(tight.paysItself, isFalse);
    expect(tight.year1Cover, lessThan(1));
  });

  testWidgets('screen shows the verdict, checklist, and sends the plan to the bank PDF', (tester) async {
    final db = memoryDb();
    final adapter = FakeAdapter((o) => o.path.endsWith('/v1/report/loan-pdf') ? jsonBody({}) : defaultHandler(o));
    await tester.pumpWidget(testApp(GreenLoanScreen(result: _result()), overrides: testOverrides(db: db, api: fakeApi(adapter))));
    await settle(tester);
    expect(find.text('Solar pays its own loan'), findsOneWidget);

    await tester.drag(find.byKey(const Key('loan-years')), const Offset(-2000, 0)); // 1 year
    await tester.pump();
    expect(find.text('Solar pays its own loan'), findsNothing);
    expect(find.textContaining('of the loan payment'), findsOneWidget);

    await tester.scrollUntilVisible(find.byKey(const Key('loan-checklist')), 200, scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Ready for the bank?'), findsOneWidget);
    await tapScrolled(tester, find.byKey(const Key('loan-pdf')));
    await settle(tester);
    final sent = adapter.requests.singleWhere((r) => r.path.endsWith('/v1/report/loan-pdf'));
    final body = sent.data as Map<String, dynamic>;
    expect((body['loan'] as Map)['years'], 1);
    expect((body['solar'] as Map)['financials'], isNotNull);
    await teardownDb(tester, db);
  });

  testWidgets('a plan without financials explains what is missing', (tester) async {
    final db = memoryDb();
    await tester.pumpWidget(testApp(GreenLoanScreen(result: SolarResult.fromJson(solarResultFixture())), overrides: testOverrides(db: db)));
    await settle(tester);
    expect(find.textContaining('no savings estimate yet'), findsOneWidget);
    await teardownDb(tester, db);
  });
}
