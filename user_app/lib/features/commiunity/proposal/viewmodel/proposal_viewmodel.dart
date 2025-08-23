import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/proposal_repository.dart';

// ViewModel Provider
final proposalViewModelProvider = StateNotifierProvider.autoDispose<ProposalViewModel, AsyncValue<void>>((ref) {
  return ProposalViewModel(ref.read(proposalRepositoryProvider));
});

class ProposalViewModel extends StateNotifier<AsyncValue<void>> {
  final ProposalRepository _repository;
  ProposalViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<bool> submitProposal({
    required String productName,
    String? productUrl,
    String? reason,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.submitProposal(
      productName: productName,
      productUrl: productUrl,
      reason: reason,
    ));
    return !state.hasError;
  }
}