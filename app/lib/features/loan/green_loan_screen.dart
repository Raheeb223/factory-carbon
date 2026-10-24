import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/loan.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../carbon/carbon_controller.dart';
import '../export/export_service.dart';

/// Green Loan Ready: can the solar plan's savings repay a loan for it, and is the
/// factory ready to ask a bank? Ends in a PDF summary for the lender.
class GreenLoanScreen extends ConsumerStatefulWidget {
  const GreenLoanScreen({super.key, required this.result});
  final SolarResult result;

  @override
  ConsumerState<GreenLoanScreen> createState() => _GreenLoanScreenState();
}

class _GreenLoanScreenState extends ConsumerState<GreenLoanScreen> {
  var _terms = const LoanTerms();
  var _exporting = false;

  Future<void> _exportPdf() async {
    final l = AppLocalizations.of(context);
    setState(() => _exporting = true);
    try {
      await ref.read(exportServiceProvider).exportLoanPdf(widget.result.raw, _terms);
    } catch (e) {
      if (mounted) showSnack(context, errorText(l, e));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final t = Theme.of(context).textTheme;
    final r = widget.result;
    final plan = LoanPlan.of(r.financials, _terms);
    String tk(double v) => l.valueTk(fmt.number(v));

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.loanTitle)),
        body: ListView(padding: const EdgeInsets.all(16), children: [SoftCard(child: Text(l.loanNoFinancials, style: t.bodyLarge))]),
      );
    }

    final carbon = ref.watch(carbonResultProvider)?.result;
    final profile = ref.watch(factoryProvider).value;
    final months = carbon?.totals.monthsWithData ?? 0;
    final structure = r.warnings.any((w) => w.code == 'structure_unknown' || w.code == 'structure_needs_work');
    final checks = <(String, bool, String?)>[
      (l.loanCheckBills, months >= 12, l.loanCheckBillsDetail(fmt.number(months.toDouble()))),
      (l.loanCheckOwnUse, r.annualConsumptionKwh != null, null),
      (l.loanCheckCover, plan.paysItself, null),
      (l.loanCheckRoof, !structure, null),
      (l.loanCheckFactors, carbon != null && carbon.placeholdersInUse.isEmpty, null),
      (l.loanCheckProfile, (profile?.location.isNotEmpty ?? false) && profile?.workers != null, null),
    ];
    final ready = checks.where((c) => c.$2).length;
    final coverage = plan.minCoverage;

    return Scaffold(
      appBar: AppBar(title: Text(l.loanTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const SyntheticBanner(),
          SoftCard(
            key: const Key('loan-verdict'),
            gradient: plan.paysItself ? BrandGradients.primary : BrandGradients.solar,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(plan.paysItself ? Icons.verified_rounded : Icons.balance_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.paysItself ? l.loanPaysItself : l.loanCovers(fmt.number(plan.year1Cover * 100)),
                    style: t.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Text(
                l.loanVs(fmt.number(plan.monthlySavingsBdt), fmt.number(plan.monthlyInstalmentBdt)),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              Row(children: [
                GlassStat(value: tk(plan.monthlySavingsBdt), label: l.loanStatSave),
                const SizedBox(width: 8),
                GlassStat(value: tk(plan.monthlyInstalmentBdt), label: l.loanStatEmi),
                const SizedBox(width: 8),
                GlassStat(value: coverage == null ? '–' : '${fmt.number(coverage, decimals: 2)}×', label: l.loanStatCover),
              ]),
            ]),
          ),
          SectionTitle(l.loanTerms),
          SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.loanShare(fmt.number(_terms.loanShare * 100)), style: t.titleSmall),
              Slider(
                key: const Key('loan-share'),
                value: _terms.loanShare,
                min: 0.3,
                max: 1,
                divisions: 14,
                onChanged: (v) => setState(() => _terms = _terms.copyWith(loanShare: v)),
              ),
              Text(l.loanYears(fmt.number(_terms.years.toDouble())), style: t.titleSmall),
              Slider(
                key: const Key('loan-years'),
                value: _terms.years.toDouble(),
                min: 1,
                max: 15,
                divisions: 14,
                onChanged: (v) => setState(() => _terms = _terms.copyWith(years: v.round())),
              ),
              Text(l.loanRate(fmt.number(_terms.annualRatePct, decimals: 1)), style: t.titleSmall),
              Slider(
                key: const Key('loan-rate'),
                value: _terms.annualRatePct,
                min: 0,
                max: 20,
                divisions: 40,
                onChanged: (v) => setState(() => _terms = _terms.copyWith(annualRatePct: v)),
              ),
              Text(l.loanRateNote, style: t.bodySmall),
              const Divider(height: 24),
              LabeledValue(l.solarCapex, tk(plan.capexBdt)),
              LabeledValue(l.loanAmount, tk(plan.loanBdt)),
              LabeledValue(l.loanOwnMoney, tk(plan.ownMoneyBdt)),
              LabeledValue(l.loanInterestTotal, tk(plan.totalInterestBdt)),
            ]),
          ),
          if (plan.yearsAfterLoan > 0)
            SoftCard(
              color: FeatureColors.carbon.withValues(alpha: 0.08),
              borderColor: FeatureColors.carbon.withValues(alpha: 0.3),
              child: Row(children: [
                const IconBlob(Icons.savings_rounded, color: FeatureColors.carbon, filled: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.loanAfter(fmt.number(plan.yearsAfterLoan.toDouble()), fmt.number(plan.savingsAfterLoanBdt)),
                    style: t.titleSmall,
                  ),
                ),
              ]),
            ),
          SectionTitle(l.loanReadyTitle(fmt.number(ready.toDouble()), fmt.number(checks.length.toDouble()))),
          SoftCard(
            key: const Key('loan-checklist'),
            child: Column(children: [
              for (final (label, ok, detail) in checks)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    Icon(
                      ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: ok ? FeatureColors.carbon : FeatureColors.solar,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(label, style: t.bodyMedium)),
                    if (detail != null && !ok) Text(detail, style: t.bodySmall),
                  ]),
                ),
            ]),
          ),
          SectionTitle(l.loanWhereTitle),
          Text(l.loanWhere, style: t.bodyMedium?.copyWith(height: 1.4)),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('loan-pdf'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            onPressed: _exporting ? null : _exportPdf,
            icon: _exporting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_rounded),
            label: Text(l.loanPdf),
          ),
          const SizedBox(height: 10),
          Text(l.loanDisclaimer, style: t.bodySmall),
        ],
      ),
    );
  }
}
