// nanum_admin/lib/features/order_management/viewmodel/order_viewmodel.dart (전체 수정)

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

// ⭐️ 1. StateNotifierProvider를 .family로 변경하여 OrderType을 인자로 받습니다.
final orderViewModelProvider = StateNotifierProvider.autoDispose
    .family<OrderViewModel, AsyncValue<List<Order>>, OrderType>((ref, orderType) {
  return OrderViewModel(ref.read(orderRepositoryProvider), orderType: orderType);
});

class OrderViewModel extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderRepository _repository;
  final OrderType orderType; // ⭐️ 어떤 타입의 주문을 관리할지 저장

  OrderViewModel(this._repository, {required this.orderType})
      : super(const AsyncValue.loading()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
  state = const AsyncValue.loading();
  
  try {
    // ⭐️ 디버그 정보 먼저 출력
    if (orderType == OrderType.shop) {
      await _repository.debugTablesInfo(); // 위에서 만든 함수 호출
    }
    
    // 기존 로직
    if (orderType == OrderType.groupBuy) {
      state = await AsyncValue.guard(() => _repository.fetchGroupBuyOrders());
    } else {
      state = await AsyncValue.guard(() => _repository.fetchShopOrders());
    }
  } catch (e, s) {
    debugPrint('ViewModel error: $e');
    state = AsyncValue.error(e, s);
  }
}

  // 엑셀 파일 업로드 및 처리를 위한 메소드
  Future<void> uploadAndProcessExcel(List<int> fileBytes) async {
    // 주의: 이 기능은 현재 공동구매 주문(participants)에만 적용됩니다.
    // 쇼핑몰 주문에 대한 송장 업데이트는 별도 로직이 필요합니다.
    state = const AsyncValue.loading();
    try {
      final excel = Excel.decodeBytes(fileBytes);
      final sheet = excel.tables[excel.tables.keys.first]!;
      
      final List<Map<String, dynamic>> updates = sheet.rows.skip(1).map((row) {
        return {
          'p_id': row[0]?.value,
          't_num': row[6]?.value,
        };
      }).where((item) => item['p_id'] != null && item['t_num'] != null).toList();

      if (updates.isNotEmpty) {
        await _repository.batchUpdateTrackingNumbers(updates);
      }
      // 성공 후 주문 목록 새로고침
      await fetchOrders();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}