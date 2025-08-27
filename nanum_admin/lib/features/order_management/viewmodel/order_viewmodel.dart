import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

final orderViewModelProvider = StateNotifierProvider.autoDispose<OrderViewModel, AsyncValue<List<Order>>>((ref) {
  return OrderViewModel(ref.read(orderRepositoryProvider));
});

class OrderViewModel extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderRepository _repository;
  OrderViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchSuccessfulOrders());
  }

  /// 💡 엑셀 파일 업로드 및 처리를 위한 메소드
  Future<void> uploadAndProcessExcel(List<int> fileBytes) async {
    state = const AsyncValue.loading();
    try {
      final excel = Excel.decodeBytes(fileBytes);
      final sheet = excel.tables[excel.tables.keys.first]!;
      
      // 엑셀의 각 행을 DB 함수에 맞는 Map 형태로 변환 (헤더 제외)
      final List<Map<String, dynamic>> updates = sheet.rows.skip(1).map((row) {
        return {
          'p_id': row[0]?.value, // 첫 번째 컬럼: 주문번호
          't_num': row[6]?.value, // 일곱 번째 컬럼: 송장번호 (가정)
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