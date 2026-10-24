import 'dart:math' as math;

import 'api_models.dart';

/// Financing the owner assumes for the solar plan. Mirrors the backend's LoanTerms
/// (backend/app/report/loan.py), which builds the bank PDF from the same numbers.
class LoanTerms {
  const LoanTerms({this.loanShare = 0.8, this.years = 5, this.annualRatePct = 9});
  final double loanShare;
  final int years;
  final double annualRatePct;

  LoanTerms copyWith({double? loanShare, int? years, double? annualRatePct}) =>
      LoanTerms(loanShare: loanShare ?? this.loanShare, years: years ?? this.years, annualRatePct: annualRatePct ?? this.annualRatePct);

  Map<String, dynamic> toJson() => {'loan_share': loanShare, 'years': years, 'annual_rate_pct': annualRatePct};
}

double monthlyInstalment(double principal, double annualRatePct, int years) {
  final n = years * 12;
  final r = annualRatePct / 100 / 12;
  if (r == 0) return principal / n;
  return principal * r / (1 - math.pow(1 + r, -n));
}

/// Can the plan's savings repay a loan for it?
class LoanPlan {
  LoanPlan._({
    required this.capexBdt,
    required this.loanBdt,
    required this.monthlyInstalmentBdt,
    required this.totalInterestBdt,
    required this.monthlySavingsBdt,
    required this.minCoverage,
    required this.savingsAfterLoanBdt,
    required this.yearsAfterLoan,
  });

  /// Null when the plan has no financials (no electricity price or consumption).
  static LoanPlan? of(SolarFinancials? f, LoanTerms t) {
    if (f == null) return null;
    final loan = f.capexBdt * t.loanShare;
    final emi = monthlyInstalment(loan, t.annualRatePct, t.years);
    // Year 0 of the cash flow is the capex itself.
    final net = [for (final c in f.cashflow) if (c.year >= 1) c.netBdt];
    final during = net.take(t.years).toList();
    final after = net.skip(t.years).toList();
    return LoanPlan._(
      capexBdt: f.capexBdt,
      loanBdt: loan,
      monthlyInstalmentBdt: emi,
      totalInterestBdt: emi * t.years * 12 - loan,
      monthlySavingsBdt: f.year1NetBdt / 12,
      minCoverage: during.isEmpty ? null : during.map((n) => n / (emi * 12)).reduce(math.min),
      savingsAfterLoanBdt: after.fold(0, (a, b) => a + b),
      yearsAfterLoan: after.length,
    );
  }

  final double capexBdt;
  final double loanBdt;
  final double monthlyInstalmentBdt;
  final double totalInterestBdt;
  final double monthlySavingsBdt;

  /// Lowest yearly net savings / yearly repayment over the loan years.
  final double? minCoverage;
  final double savingsAfterLoanBdt;
  final int yearsAfterLoan;

  double get ownMoneyBdt => capexBdt - loanBdt;
  bool get paysItself => minCoverage != null && minCoverage! >= 1;

  /// Share of the first-year instalment the savings cover (0..).
  double get year1Cover => monthlyInstalmentBdt == 0 ? 0 : monthlySavingsBdt / monthlyInstalmentBdt;
}
