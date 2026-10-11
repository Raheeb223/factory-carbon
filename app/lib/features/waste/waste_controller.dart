import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/api_models.dart';
import '../../domain/requests.dart';

final wasteResultProvider = Provider<({WasteResult result, DateTime updatedAt})?>((ref) {
  final cached = ref.watch(wasteCacheProvider).value;
  final response = cached?.json['response'];
  if (cached == null || response is! Map<String, dynamic>) return null;
  return (result: WasteResult.fromJson(response), updatedAt: cached.updatedAt);
});

/// Calls /v1/waste/analyze with monthly kWh + production and caches the response.
class WasteController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> analyze() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final bills = await ref.read(billRepositoryProvider).all();
      final production = await ref.read(productionRepositoryProvider).all();
      final profile = await ref.read(factoryRepositoryProvider).get();
      final body = wasteRequest(bills: bills, production: production, productionUnitLabel: profile?.productionUnitLabel);
      final json = await ref.read(apiClientProvider).analyzeWasteRaw(body);
      await ref.read(resultCacheRepositoryProvider).put(wasteCacheKey, {'response': json});
    });
  }
}

final wasteControllerProvider = NotifierProvider<WasteController, AsyncValue<void>>(WasteController.new);
