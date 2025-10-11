// nanum_admin/lib/features/shop_management.dart/inventory/viewmodel/inventory_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/inventory_model.dart';
import '../../../../data/repositories/inventory_repository.dart';

// 재고 로그 Provider
final inventoryLogsProvider = StateNotifierProvider.autoDispose<InventoryLogsNotifier, AsyncValue<List<InventoryLog>>>((ref) {
  return InventoryLogsNotifier(ref.watch(inventoryRepositoryProvider));
});

class InventoryLogsNotifier extends StateNotifier<AsyncValue<List<InventoryLog>>> {
  final InventoryRepository _repository;

  InventoryLogsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchLogs();
  }

  Future<void> fetchLogs({int? productId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchInventoryLogs(productId: productId));
  }

  Future<void> adjustStock({
    required int productId,
    required String type,
    required int quantity,
    String? reason,
  }) async {
    try {
      await _repository.adjustStock(
        productId: productId,
        type: type,
        quantity: quantity,
        reason: reason,
      );
      await fetchLogs();
    } catch (e) {
      rethrow;
    }
  }
}

// 재고 부족 알림 Provider
final stockAlertsProvider = FutureProvider.autoDispose<List<StockAlert>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.fetchLowStockAlerts(threshold: 10);
});