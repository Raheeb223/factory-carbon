import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart';
import '../../domain/requests.dart';

Map<String, dynamic> _currentRequest(Ref ref) => carbonRequest(
      bills: ref.watch(billsProvider).value ?? const <Bill>[],
      production: ref.watch(productionProvider).value ?? const <ProductionEntry>[],
      productionUnitLabel: ref.watch(factoryProvider).value?.productionUnitLabel,
    );

/// Parsed cached carbon result (works offline).
final carbonResultProvider = Provider<({CarbonResult result, DateTime updatedAt})?>((ref) {
  final cached = ref.watch(carbonCacheProvider).value;
  final response = cached?.json['response'];
  if (cached == null || response is! Map<String, dynamic>) return null;
  return (result: CarbonResult.fromJson(response), updatedAt: cached.updatedAt);
});

/// True when local data no longer matches the inputs of the cached result.
final carbonStaleProvider = Provider<bool>((ref) {
  final cached = ref.watch(carbonCacheProvider).value;
  if (cached == null) return false;
  return cached.json['input_hash'] != inputHash(jsonEncode(_currentRequest(ref)));
});

/// Calls /v1/carbon/calculate with local confirmed data and caches the response.
class CarbonController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final bills = await ref.read(billRepositoryProvider).all();
      final production = await ref.read(productionRepositoryProvider).all();
      final profile = await ref.read(factoryRepositoryProvider).get();
      final body = carbonRequest(bills: bills, production: production, productionUnitLabel: profile?.productionUnitLabel);
      final json = await ref.read(apiClientProvider).calculateCarbonRaw(body);
      await ref.read(resultCacheRepositoryProvider).put(carbonCacheKey, {'input_hash': inputHash(jsonEncode(body)), 'response': json});
    });
  }
}

final carbonControllerProvider = NotifierProvider<CarbonController, AsyncValue<void>>(CarbonController.new);
