// nanum_admin/lib/features/shop_management.dart/inventory/viewmodel/inventory_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/inventory_model.dart';
import '../../../../data/repositories/inventory_repository.dart';

// 📌 상품 검색 Provider
final productSearchProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.isEmpty || query.length < 2) {
    return [];
  }
  
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.searchProducts(query);
});

// 📌 필터 상태 클래스
class InventoryFilter {
  final String? type; // null, 'in', 'out', 'adjust'
  final DateTime? startDate;
  final DateTime? endDate;
  final int? productId;

  InventoryFilter({
    this.type,
    this.startDate,
    this.endDate,
    this.productId,
  });

  InventoryFilter copyWith({
    String? Function()? type,
    DateTime? Function()? startDate,
    DateTime? Function()? endDate,
    int? Function()? productId,
  }) {
    return InventoryFilter(
      type: type != null ? type() : this.type,
      startDate: startDate != null ? startDate() : this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
      productId: productId != null ? productId() : this.productId,
    );
  }

  bool get hasActiveFilters =>
      type != null || startDate != null || endDate != null || productId != null;
}

// 📌 필터 Provider
final inventoryFilterProvider = StateProvider.autoDispose<InventoryFilter>((ref) {
  return InventoryFilter();
});

// 📌 재고 로그 Provider (필터 적용)
final inventoryLogsProvider = StateNotifierProvider.autoDispose<InventoryLogsNotifier, AsyncValue<List<InventoryLog>>>((ref) {
  final filter = ref.watch(inventoryFilterProvider);
  return InventoryLogsNotifier(ref.watch(inventoryRepositoryProvider), filter);
});

class InventoryLogsNotifier extends StateNotifier<AsyncValue<List<InventoryLog>>> {
  final InventoryRepository _repository;
  final InventoryFilter _filter;

  InventoryLogsNotifier(this._repository, this._filter) : super(const AsyncValue.loading()) {
    fetchLogs();
  }

  Future<void> fetchLogs({int? productId}) async {
    state = const AsyncValue.loading();
    
    try {
      final allLogs = await _repository.fetchInventoryLogs(
        productId: productId ?? _filter.productId,
      );
      
      // 필터 적용
      var filteredLogs = allLogs;
      
      // 타입 필터
      if (_filter.type != null) {
        filteredLogs = filteredLogs.where((log) => log.type == _filter.type).toList();
      }
      
      // 시작일 필터
      if (_filter.startDate != null) {
        filteredLogs = filteredLogs.where((log) {
          return log.createdAt.isAfter(_filter.startDate!) || 
                 log.createdAt.isAtSameMomentAs(_filter.startDate!);
        }).toList();
      }
      
      // 종료일 필터 (종료일 23:59:59까지 포함)
      if (_filter.endDate != null) {
        final endOfDay = DateTime(
          _filter.endDate!.year,
          _filter.endDate!.month,
          _filter.endDate!.day,
          23, 59, 59,
        );
        filteredLogs = filteredLogs.where((log) {
          return log.createdAt.isBefore(endOfDay) || 
                 log.createdAt.isAtSameMomentAs(endOfDay);
        }).toList();
      }
      
      state = AsyncValue.data(filteredLogs);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
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

// 📌 재고 부족 알림 Provider
final stockAlertsProvider = FutureProvider.autoDispose<List<StockAlert>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.fetchLowStockAlerts(threshold: 10);
});

// 📌 대시보드 통계 Provider
final dashboardStatsProvider = FutureProvider.autoDispose<InventoryDashboardStats>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.fetchDashboardStats();
});

// 📌 일별 통계 Provider
final dailyStatsProvider = FutureProvider.autoDispose<List<DailyInventoryStats>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.fetchDailyStats(days: 7);
});

// 📌 TOP 활동 상품 Provider
final topActivityProductsProvider = FutureProvider.autoDispose<List<ProductActivityStats>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.fetchTopActivityProducts(limit: 5, days: 7);
});