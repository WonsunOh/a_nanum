import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/inquiry_repository.dart';

/// ## Form Text Controllers
final inquiryTitleControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final inquiryContentControllerProvider = Provider.autoDispose((ref) => TextEditingController());

/// ## Submit Inquiry ViewModel Provider
final submitInquiryViewModelProvider = StateNotifierProvider.autoDispose<SubmitInquiryViewModel, AsyncValue<void>>((ref) {
  return SubmitInquiryViewModel(ref.read(inquiryRepositoryProvider));
});

class SubmitInquiryViewModel extends StateNotifier<AsyncValue<void>> {
  final InquiryRepository _repository;

  SubmitInquiryViewModel(this._repository) : super(const AsyncValue.data(null));

  /// ## 문의 제출 실행
  Future<void> submit({required String title, required String content}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return _repository.submitInquiry(title: title, content: content);
    });
  }
}