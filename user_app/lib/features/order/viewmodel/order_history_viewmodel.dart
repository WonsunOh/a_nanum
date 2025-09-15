// user_app/lib/features/order/viewmodel/order_history_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/order_history_model.dart';
import '../../../data/repositories/order_repository.dart';

part 'order_history_viewmodel.g.dart';

@riverpod
class OrderHistoryViewModel extends _$OrderHistoryViewModel {
  // ✅ late final 제거하고 getter로 변경
  OrderRepository get _repository => ref.watch(orderRepositoryProvider);

  @override
  Future<List<OrderHistoryModel>> build() async {
    // ✅ 초기화 코드 제거하고 직접 호출
    return await _fetchOrderHistory();
  }

  /// 주문내역을 조회합니다.
  Future<List<OrderHistoryModel>> _fetchOrderHistory() async {
    try {
      return await _repository.fetchOrderHistory();
    } catch (e) {
      // 에러 발생 시 빈 리스트 반환
      print('주문내역 조회 실패: $e');
      rethrow;
    }
  }

 // refresh 메서드에 디버깅 추가
  Future<void> refresh() async {
    print('🔄 OrderHistoryViewModel refresh 시작');
    state = const AsyncValue.loading();
    try {
      final newData = await _fetchOrderHistory();
      state = AsyncValue.data(newData);
      print('✅ OrderHistoryViewModel refresh 성공 - ${newData.length}개 주문');
    } catch (e, stackTrace) {
      print('❌ OrderHistoryViewModel refresh 실패: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 주문을 취소합니다.
  Future<bool> cancelOrder(int orderId) async {
    try {
      final success = await _repository.cancelOrder(orderId);
      if (success) {
        // 주문 취소 성공 시 목록 새로고침
        await refresh();
      }
      return success;
    } catch (e) {
      print('주문 취소 실패: $e');
      return false;
    }
  }
}