// File: nanum_admin/lib/features/order_management/viewmodel/order_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

final orderViewModelProvider =
    StateNotifierProvider<OrderViewModel, AsyncValue<List<OrderModel>>>((ref) {
  return OrderViewModel(ref.watch(orderRepositoryProvider));
});

class OrderViewModel extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderRepository _repository;
  int _page = 0;
  bool _hasMore = true;
  String _searchQuery = '';
  String _selectedStatus = '전체';
  String _selectedPeriod = 'all';
  DateTime? _startDate; // ✅ 추가
  DateTime? _endDate; // ✅ 추가
  bool isLoadingMore = false;

  OrderViewModel(this._repository) : super(const AsyncValue.loading());

  // 🔥🔥🔥 수정: 외부에서 접근할 수 있도록 public getter 추가
  String get selectedStatus => _selectedStatus;
  String get selectedPeriod => _selectedPeriod;
  DateTime? get startDate => _startDate; // ✅ 추가
  DateTime? get endDate => _endDate; // ✅ 추가

  void setSearchQuery(String query) {
    _searchQuery = query;
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
  }

  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    // 빠른 기간 선택 시 사용자 정의 날짜 초기화
    if (period != 'custom') {
      _startDate = null;
      _endDate = null;
    }
  }

  // ✅ 사용자 정의 날짜 설정
  void setCustomDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _selectedPeriod = 'custom';
  }

  Future<void> fetchOrders({bool isRefresh = false}) async {
    if (isRefresh) {
      _page = 0;
      _hasMore = true;
      state = const AsyncValue.loading();
    }

    if (isLoadingMore || !_hasMore) return;
    isLoadingMore = true;

    try {
      final newOrders = await _repository.getOrders(
        page: _page,
        query: _searchQuery,
        status: _selectedStatus,
        period: _selectedPeriod,
        startDate: _startDate, // ✅ 추가
        endDate: _endDate, // ✅ 추가
      );

      if (newOrders.isEmpty) {
        _hasMore = false;
      }

      if (isRefresh) {
        state = AsyncValue.data(newOrders);
      } else {
        state = AsyncValue.data([...(state.value ?? []), ...newOrders]);
      }
      _page++;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    } finally {
      isLoadingMore = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _repository.updateOrderStatus(orderId, newStatus.name);
      await fetchOrders(isRefresh: true);
    } catch (e) {
      // 에러 처리
    }
  }

  // ✅ 선택된 '결제완료' 주문들을 '상품준비중'으로 일괄 변경하는 함수
  Future<void> changeOrdersToPreparing(List<String> orderIds) async {
    final currentState = state.value;
    if (currentState == null || orderIds.isEmpty) return;

    final targetOrderIds = currentState
        .where((order) => orderIds.contains(order.orderId) && order.status == OrderStatus.confirmed)
        .map((order) => order.orderId)
        .toList();

    if (targetOrderIds.isEmpty) return;

    final updates = targetOrderIds.map((id) => {
      'order_number': id,
      'status': OrderStatus.preparing.name,
    }).toList();

    try {
      await _repository.batchUpdateOrders(updates);
      await fetchOrders(isRefresh: true);
    } catch(e, s) {
      state = AsyncValue.error(e, s);
    }
  }
  
  
  // 📌 송장번호 업데이트
Future<void> updateTrackingNumber({
  required String orderId,
  required String trackingNumber,
  String? courierCompany,
}) async {
  try {
    await _repository.updateTrackingNumber(
      orderId: orderId,
      trackingNumber: trackingNumber,
      courierCompany: courierCompany,
    );
    await fetchOrders(isRefresh: true);
  } catch (e) {
    rethrow;
  }
}

// 📌 일괄 송장번호 업데이트 (기존 메서드 수정)
Future<void> batchUpdateTrackingNumbers(List<Map<String, dynamic>> updates) async {
  state = const AsyncValue.loading();
  try {
    await _repository.batchUpdateTrackingNumbers(updates);
    await fetchOrders(isRefresh: true);
  } catch(e, s) {
    state = AsyncValue.error(e, s);
  }
}
}

