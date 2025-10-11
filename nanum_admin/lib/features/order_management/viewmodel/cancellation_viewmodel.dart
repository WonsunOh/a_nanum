// File: nanum_admin/lib/features/order_management/viewmodel/cancellation_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/cancellation_model.dart';
import '../../../data/repositories/cancellation_repository.dart';

final cancellationViewModelProvider = StateNotifierProvider<CancellationViewModel,
    AsyncValue<List<CancellationModel>>>((ref) {
  return CancellationViewModel(ref.watch(cancellationRepositoryProvider));
});

class CancellationViewModel
    extends StateNotifier<AsyncValue<List<CancellationModel>>> {
  final CancellationRepository _repository;
  int _fullPage = 0;
  int _partialPage = 0;
  bool _hasMoreFull = true;
  bool _hasMorePartial = true;
  bool _isLoading = false;

  CancellationViewModel(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchCancellations(CancellationType type, {bool isRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;

    if (isRefresh) {
      if (type == CancellationType.full) {
        _fullPage = 0;
        _hasMoreFull = true;
      } else {
        _partialPage = 0;
        _hasMorePartial = true;
      }
      state = const AsyncValue.loading();
    }

    try {
      List<CancellationModel> newCancellations;
      if (type == CancellationType.full) {
        if (!_hasMoreFull) {
          _isLoading = false;
          return;
        }
        newCancellations = await _repository.getFullCancellations(page: _fullPage);
        if (newCancellations.isEmpty) _hasMoreFull = false;
        _fullPage++;
      } else {
        if (!_hasMorePartial) {
          _isLoading = false;
          return;
        }
        newCancellations = await _repository.getPartialCancellations(page: _partialPage);
        if (newCancellations.isEmpty) _hasMorePartial = false;
        _partialPage++;
      }
      
      final currentData = state.value ?? [];
      if (isRefresh) {
        state = AsyncValue.data(newCancellations);
      } else {
        state = AsyncValue.data([...currentData, ...newCancellations]);
      }
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    } finally {
      _isLoading = false;
    }
  }
}
