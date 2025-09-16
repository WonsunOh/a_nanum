// nanum_admin/lib/features/order_management/viewmodel/partial_cancel_viewmodel.dart (새 파일)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/order_item_cancellation_model.dart';
import '../../../data/repositories/order_repository.dart';

final partialCancellationViewModelProvider = 
    StateNotifierProvider<PartialCancellationViewModel, AsyncValue<List<OrderItemCancellation>>>(
  (ref) => PartialCancellationViewModel(ref.read(orderRepositoryProvider)),
);

class PartialCancellationViewModel extends StateNotifier<AsyncValue<List<OrderItemCancellation>>> {
  final OrderRepository _repository;
  
  PartialCancellationViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchPartialCancellations();
  }

  Future<void> fetchPartialCancellations() async {
    try {
      state = const AsyncValue.loading();
      final cancellations = await _repository.fetchPartialCancellations();
      state = AsyncValue.data(cancellations);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> approvePartialCancellation(int cancellationId, String adminNote) async {
    try {
      await _repository.approvePartialCancellation(cancellationId, adminNote);
      fetchPartialCancellations(); // 목록 새로고침
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectPartialCancellation(int cancellationId, String adminNote) async {
    try {
      await _repository.rejectPartialCancellation(cancellationId, adminNote);
      fetchPartialCancellations(); // 목록 새로고침
    } catch (e) {
      rethrow;
    }
  }
}