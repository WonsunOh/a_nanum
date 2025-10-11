// user_app/lib/features/order/viewmodel/order_history_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/order_history_model.dart';
import '../../../data/repositories/order_repository.dart';

part 'order_history_viewmodel.g.dart';

@riverpod
class OrderHistoryViewModel extends _$OrderHistoryViewModel {
  OrderRepository get _repository => ref.watch(orderRepositoryProvider);

  @override
  Future<List<OrderHistoryModel>> build() async {
    return await _fetchOrderHistory();
  }

  Future<List<OrderHistoryModel>> _fetchOrderHistory() async {
  try {
    // 캐시 무시하고 강제로 새 데이터 가져오기
    final result = await _repository.fetchOrderHistory();
    print('✅ 주문내역 조회 성공: ${result.length}개');
    return result;
  } catch (e) {
    print('❌ 주문내역 조회 실패: $e');
    rethrow;
  }
}

  // refresh 메서드 수정
Future<void> refresh() async {
  // 강제로 로딩 상태로 변경
  state = const AsyncValue.loading();
  
  // 약간의 딜레이를 주어 UI가 업데이트되도록 함
  await Future.delayed(const Duration(milliseconds: 100));
  
  try {
    final newData = await _fetchOrderHistory();
    state = AsyncValue.data(newData);
    print('✅ 주문내역 새로고침 완료: ${newData.length}개 주문');
  } catch (e, stackTrace) {
    state = AsyncValue.error(e, stackTrace);
    print('❌ 주문내역 새로고침 실패: $e');
  }
}

  // 🔥🔥🔥 전체 수정: 함수 이름 및 로직 변경
  Future<void> requestCancellation({
    required String orderNumber,
    required String reason,
    required int totalAmount,
  }) async {
    final previousState = state;
    state = const AsyncValue.loading();

    try {
      // 🔥🔥🔥 수정: 올바른 함수 이름으로 호출
      await _repository.requestCancellation(
        orderNumber: orderNumber,
        reason: reason,
        totalAmount: totalAmount,
      );
      // 성공 시 목록 새로고침
      await refresh();
    } catch (e, s) {
      // 에러가 발생하면 이전 상태로 되돌림
      state = AsyncValue<List<OrderHistoryModel>>.error(e, s)
          .copyWithPrevious(previousState);
      // 에러를 다시 던져서 UI단에서 처리할 수 있도록 함
      rethrow;
    }
  }
}

