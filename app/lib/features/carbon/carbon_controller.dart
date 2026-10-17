import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart';
import '../../domain/report_period.dart';
import '../../domain/requests.dart';

/// The reporting period chosen on the carbon report (kept across restarts). Until the
/// user picks one, it is the latest year of the kind set in the factory profile
/// (calendar or fiscal), or all data when the profile does not say.
class ReportPeriodNotifier extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() {
    final stored = ref.watch(settingsStoreProvider).reportPeriod;
    if (stored != null) return ReportPeriod.parse(stored);
    final kind = switch (ref.watch(factoryProvider).value?.reportingYear) {
      'calendar' => PeriodKind.calendarYear,
      'fiscal' => PeriodKind.fiscalYear,
      _ => null,
    };
    if (kind == null) return const ReportPeriod.all();
    final months = [
      for (final b in ref.watch(billsProvider).value ?? const <Bill>[]) b.billingMonth,
      for (final p in ref.watch(productionProvider).value ?? const <ProductionEntry>[]) p.month,
    ];
    return availablePeriods(months).firstWhere((p) => p.kind == kind, orElse: () => const ReportPeriod.all());
  }

  Future<void> set(ReportPeriod p) async {
    state = p;
    await ref.read(settingsStoreProvider).setReportPeriod(p.key);
  }
}

final reportPeriodProvider = NotifierProvider<ReportPeriodNotifier, ReportPeriod>(ReportPeriodNotifier.new);

/// Request bodies for the chosen period and, for a year, the same months a year earlier
/// (null when there are no bills then).
({Map<String, dynamic> current, Map<String, dynamic>? previous}) carbonRequests({
  required List<Bill> bills,
  required List<ProductionEntry> production,
  required String? productionUnitLabel,
  required ReportPeriod period,
}) {
  final last = lastDataMonth(bills, production);
  final prev = period.previousSpan(last);
  Map<String, dynamic> body(MonthSpan? span) =>
      carbonRequest(bills: bills, production: production, productionUnitLabel: productionUnitLabel, period: span);
  return (current: body(period.reportSpan(last)), previous: prev != null && hasBillsIn(bills, prev) ? body(prev) : null);
}

Map<String, dynamic> _currentRequest(Ref ref) => carbonRequests(
      bills: ref.watch(billsProvider).value ?? const <Bill>[],
      production: ref.watch(productionProvider).value ?? const <ProductionEntry>[],
      productionUnitLabel: ref.watch(factoryProvider).value?.productionUnitLabel,
      period: ref.watch(reportPeriodProvider),
    ).current;

/// Parsed cached carbon result (works offline), with the previous-year result when the
/// report is for one year.
final carbonResultProvider = Provider<({CarbonResult result, CarbonResult? previous, DateTime updatedAt})?>((ref) {
  final cached = ref.watch(carbonCacheProvider).value;
  final response = cached?.json['response'];
  if (cached == null || response is! Map<String, dynamic>) return null;
  final previous = cached.json['previous'];
  return (
    result: CarbonResult.fromJson(response),
    previous: previous is Map<String, dynamic> ? CarbonResult.fromJson(previous) : null,
    updatedAt: cached.updatedAt,
  );
});

/// Hash of the request the local data (and chosen period) would make now.
final carbonInputHashProvider = Provider<String>((ref) => inputHash(jsonEncode(_currentRequest(ref))));

/// True when local data (or the chosen period) no longer matches the cached result.
final carbonStaleProvider = Provider<bool>((ref) {
  final cached = ref.watch(carbonCacheProvider).value;
  if (cached == null) return false;
  return cached.json['input_hash'] != ref.watch(carbonInputHashProvider);
});

/// Calls /v1/carbon/calculate with local confirmed data and caches the response.
class CarbonController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> refresh() async {
    state = const AsyncLoading();
    // The provider can be disposed while a request is in flight (screen closed, data
    // deleted): stop quietly instead of touching a dead Ref.
    final result = await AsyncValue.guard(() async {
      final bills = await ref.read(billRepositoryProvider).all();
      if (!ref.mounted) return;
      final production = await ref.read(productionRepositoryProvider).all();
      if (!ref.mounted) return;
      final profile = await ref.read(factoryRepositoryProvider).get();
      if (!ref.mounted) return;
      final req = carbonRequests(
        bills: bills,
        production: production,
        productionUnitLabel: profile?.productionUnitLabel,
        period: ref.read(reportPeriodProvider),
      );
      final api = ref.read(apiClientProvider);
      final cache = ref.read(resultCacheRepositoryProvider);
      final json = await api.calculateCarbonRaw(req.current);
      final previous = req.previous == null ? null : await api.calculateCarbonRaw(req.previous!);
      await cache.put(carbonCacheKey, {
        'input_hash': inputHash(jsonEncode(req.current)),
        'response': json,
        'previous': ?previous,
      });
    });
    if (ref.mounted) state = result;
  }
}

final carbonControllerProvider = NotifierProvider<CarbonController, AsyncValue<void>>(CarbonController.new);
