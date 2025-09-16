// user_app/lib/features/order/viewmodel/partial_cancel_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/partial_cancel_repository.dart';

class PartialCancelState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const PartialCancelState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  PartialCancelState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return PartialCancelState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class PartialCancelViewModel extends StateNotifier<PartialCancelState> {
  final PartialCancelRepository _repository;

  PartialCancelViewModel(this._repository) : super(const PartialCancelState());

  // 부분 취소 요청
  Future<bool> requestPartialCancellation({
    required int orderItemId,
    required String cancelReason,
    String? cancelDetail,
    required int cancelQuantity,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    try {
      await _repository.requestPartialCancellation(
        orderItemId: orderItemId,
        cancelReason: cancelReason,
        cancelDetail: cancelDetail,
        cancelQuantity: cancelQuantity,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '취소 요청에 실패했습니다: $e',
      );
      return false;
    }
  }

  void clearState() {
    state = const PartialCancelState();
  }
}

final partialCancelViewModelProvider = 
    StateNotifierProvider<PartialCancelViewModel, PartialCancelState>((ref) {
  final repository = ref.watch(partialCancelRepositoryProvider);
  return PartialCancelViewModel(repository);
});