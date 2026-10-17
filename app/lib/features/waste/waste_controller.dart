import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/models.dart';
import '../../domain/requests.dart';

final wasteResultProvider = Provider<({WasteResult result, DateTime updatedAt})?>((ref) {
  final cached = ref.watch(wasteCacheProvider).value;
  final response = cached?.json['response'];
  if (cached == null || response is! Map<String, dynamic>) return null;
  return (result: WasteResult.fromJson(response), updatedAt: cached.updatedAt);
});

/// Hash of the request the local data would make now; the cache stores the hash it was made from.
final wasteInputHashProvider = Provider<String>((ref) => inputHash(jsonEncode(wasteRequest(
      bills: ref.watch(billsProvider).value ?? const <Bill>[],
      production: ref.watch(productionProvider).value ?? const <ProductionEntry>[],
      productionUnitLabel: ref.watch(factoryProvider).value?.productionUnitLabel,
    ))));

/// True when there is no result yet, or local data changed since it was made.
final wasteStaleProvider = Provider<bool>((ref) {
  final cached = ref.watch(wasteCacheProvider).value;
  return cached == null || cached.json['input_hash'] != ref.watch(wasteInputHashProvider);
});

/// Calls /v1/waste/analyze with monthly kWh + production and caches the response.
class WasteController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> analyze() async {
    state = const AsyncLoading();
    // Stop quietly if the provider is disposed while the request is in flight.
    final result = await AsyncValue.guard(() async {
      final bills = await ref.read(billRepositoryProvider).all();
      if (!ref.mounted) return;
      final production = await ref.read(productionRepositoryProvider).all();
      if (!ref.mounted) return;
      final profile = await ref.read(factoryRepositoryProvider).get();
      if (!ref.mounted) return;
      final body = wasteRequest(bills: bills, production: production, productionUnitLabel: profile?.productionUnitLabel);
      final cache = ref.read(resultCacheRepositoryProvider);
      final json = await ref.read(apiClientProvider).analyzeWasteRaw(body);
      await cache.put(wasteCacheKey, {'input_hash': inputHash(jsonEncode(body)), 'response': json});
    });
    if (ref.mounted) state = result;
  }
}

final wasteControllerProvider = NotifierProvider<WasteController, AsyncValue<void>>(WasteController.new);
