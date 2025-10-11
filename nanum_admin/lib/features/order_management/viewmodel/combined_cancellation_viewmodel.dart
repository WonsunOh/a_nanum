import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/order_cancellation_model.dart';
import '../../../data/models/order_item_cancellation_model.dart';
import '../../../data/repositories/order_repository.dart';

// 통합된 취소 상태를 관리하는 State 클래스
class CombinedCancellationState {
  final List<OrderCancellation> fullCancellations;
  final List<OrderItemCancellation> partialCancellations;
  final bool isLoading;
  final String? error;
  final String selectedStatus;

  CombinedCancellationState({
    this.fullCancellations = const [],
    this.partialCancellations = const [],
    this.isLoading = false,
    this.error,
    this.selectedStatus = '전체',
  });

  CombinedCancellationState copyWith({
    List<OrderCancellation>? fullCancellations,
    List<OrderItemCancellation>? partialCancellations,
    bool? isLoading,
    String? error,
    String? selectedStatus,
  }) {
    return CombinedCancellationState(
      fullCancellations: fullCancellations ?? this.fullCancellations,
      partialCancellations: partialCancellations ?? this.partialCancellations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

// ViewModel 클래스
class CombinedCancellationViewModel extends StateNotifier<CombinedCancellationState> {
  final OrderRepository _orderRepository;

  CombinedCancellationViewModel(this._orderRepository) : super(CombinedCancellationState()) {
    fetchCancellations();
  }

  Future<void> fetchCancellations({String? status, String? searchQuery}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final statusToFetch = (status == null || status == '전체') ? null : status;
      
      final fullCancellations = await _orderRepository.getOrderCancellations(status: statusToFetch, searchQuery: searchQuery);
      final partialCancellations = await _orderRepository.getOrderItemCancellations(status: statusToFetch, searchQuery: searchQuery);
      
      state = state.copyWith(
        fullCancellations: fullCancellations,
        partialCancellations: partialCancellations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void filterByStatus(String status) {
    state = state.copyWith(selectedStatus: status);
    fetchCancellations(status: status);
  }

  void search(String query) {
    fetchCancellations(status: state.selectedStatus, searchQuery: query);
  }

  Future<void> approveFullCancellation(String cancellationId) async {
    await _orderRepository.approveCancellation(cancellationId);
    fetchCancellations(status: state.selectedStatus);
  }

  Future<void> rejectFullCancellation(String cancellationId, String reason) async {
    await _orderRepository.rejectCancellation(cancellationId, reason);
    fetchCancellations(status: state.selectedStatus);
  }

  Future<void> approvePartialCancellation(String itemCancellationId) async {
    await _orderRepository.approvePartialCancellation(itemCancellationId);
    fetchCancellations(status: state.selectedStatus);
  }

  Future<void> rejectPartialCancellation(String itemCancellationId, String reason) async {
    await _orderRepository.rejectPartialCancellation(itemCancellationId, reason);
    fetchCancellations(status: state.selectedStatus);
  }
}

// Provider
final combinedCancellationViewModelProvider = StateNotifierProvider<CombinedCancellationViewModel, CombinedCancellationState>((ref) {
  return CombinedCancellationViewModel(ref.watch(orderRepositoryProvider));
});
