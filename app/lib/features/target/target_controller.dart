import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/repositories.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart';
import '../../domain/report_period.dart';
import '../../domain/requests.dart';
import '../../domain/target.dart';

const targetCacheKey = 'target';

final targetCacheProvider = StreamProvider<CachedResult?>((ref) => ref.watch(resultCacheRepositoryProvider).watch(targetCacheKey));

/// Request bodies for the baseline year and the latest 12 months; null without a target or data.
({Map<String, dynamic> baseline, Map<String, dynamic> current, MonthSpan currentMonths})? targetRequests({
  required ReductionTarget? target,
  required List<Bill> bills,
  required List<ProductionEntry> production,
  required String? productionUnitLabel,
}) {
  final now = currentSpan(lastDataMonth(bills, production));
  if (target == null || now == null) return null;
  Map<String, dynamic> body(MonthSpan s) => carbonRequest(bills: bills, production: production, productionUnitLabel: productionUnitLabel, period: s);
  return (baseline: body(baselineSpan(target)), current: body(now), currentMonths: now);
}

String _hash(ReductionTarget t, Map<String, dynamic> baseline, Map<String, dynamic> current) =>
    inputHash(jsonEncode({'target': [t.metric, t.pct, t.baselineYear, t.year], 'baseline': baseline, 'current': current}));

/// Hash of what the target check would send now; empty without a target or data.
final targetInputHashProvider = Provider<String>((ref) {
  final profile = ref.watch(factoryProvider).value;
  final req = targetRequests(
    target: profile?.target,
    bills: ref.watch(billsProvider).value ?? const [],
    production: ref.watch(productionProvider).value ?? const [],
    productionUnitLabel: profile?.productionUnitLabel,
  );
  return req == null ? '' : _hash(profile!.target!, req.baseline, req.current);
});

/// Progress from the cached results, or null when there is no target or nothing cached yet.
final targetProgressProvider = Provider<({TargetProgress progress, bool stale})?>((ref) {
  final target = ref.watch(factoryProvider).value?.target;
  final cached = ref.watch(targetCacheProvider).value;
  if (target == null || cached == null) return null;
  final b = cached.json['baseline'];
  final c = cached.json['current'];
  final months = cached.json['current_months'];
  if (b is! Map<String, dynamic> || c is! Map<String, dynamic> || months is! List) return null;
  return (
    progress: targetProgress(
      target,
      baseline: CarbonResult.fromJson(b),
      current: CarbonResult.fromJson(c),
      currentMonths: (start: months[0] as String, end: months[1] as String),
    ),
    stale: cached.json['input_hash'] != ref.watch(targetInputHashProvider),
  );
});

/// Calculates the baseline year and the latest 12 months and caches both.
class TargetController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> refresh() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final profile = await ref.read(factoryRepositoryProvider).get();
      if (!ref.mounted) return;
      final bills = await ref.read(billRepositoryProvider).all();
      if (!ref.mounted) return;
      final production = await ref.read(productionRepositoryProvider).all();
      if (!ref.mounted) return;
      final req = targetRequests(target: profile?.target, bills: bills, production: production, productionUnitLabel: profile?.productionUnitLabel);
      if (req == null) return;
      final api = ref.read(apiClientProvider);
      final cache = ref.read(resultCacheRepositoryProvider);
      final baseline = await api.calculateCarbonRaw(req.baseline);
      final current = await api.calculateCarbonRaw(req.current);
      await cache.put(targetCacheKey, {
        'input_hash': _hash(profile!.target!, req.baseline, req.current),
        'baseline': baseline,
        'current': current,
        'current_months': [req.currentMonths.start, req.currentMonths.end],
      });
    });
    if (ref.mounted) state = result;
  }

  /// Saves (or clears) the target on the factory profile.
  Future<void> setTarget(ReductionTarget? t) async {
    final repo = ref.read(factoryRepositoryProvider);
    final profile = await repo.get();
    if (profile == null) return;
    await repo.save(profile.withTarget(t));
  }
}

final targetControllerProvider = NotifierProvider<TargetController, AsyncValue<void>>(TargetController.new);
