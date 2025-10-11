import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../data/models/inquiry_model.dart';
import '../../../../data/repositories/inquiry_repository.dart';

final inquiryViewModelProvider = StateNotifierProvider.autoDispose<InquiryViewModel, AsyncValue<List<Inquiry>>>((ref) {
  return InquiryViewModel(ref.read(inquiryRepositoryProvider));
});

class InquiryViewModel extends StateNotifier<AsyncValue<List<Inquiry>>> {
  final InquiryRepository _repository;
  InquiryViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchAllInquiries();
  }

  Future<void> fetchAllInquiries() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchAllInquiries());
  }

  Future<bool> submitReply({required int inquiryId, required String reply}) async {
    try {
      await _repository.submitReply(inquiryId: inquiryId, reply: reply);
      await fetchAllInquiries(); // 성공 후 목록 새로고침
      return true;
    } catch (e) {
      // 에러 상태를 외부에 알리기 위해 state 업데이트도 가능
      return false;
    }
  }
}