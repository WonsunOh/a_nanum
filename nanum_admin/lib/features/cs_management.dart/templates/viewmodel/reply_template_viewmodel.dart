import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../data/models/reply_template_model.dart';
import '../../../../data/repositories/reply_template_repository.dart';

final replyTemplateViewModelProvider = StateNotifierProvider.autoDispose<ReplyTemplateViewModel, AsyncValue<List<ReplyTemplate>>>((ref) {
  return ReplyTemplateViewModel(ref.read(replyTemplateRepositoryProvider));
});

class ReplyTemplateViewModel extends StateNotifier<AsyncValue<List<ReplyTemplate>>> {
  final ReplyTemplateRepository _repository;
  ReplyTemplateViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchAllTemplates();
  }

  Future<void> fetchAllTemplates() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchAllTemplates());
  }
  
  Future<void> createTemplate({required String title, required String content}) async {
    await AsyncValue.guard(() => _repository.createTemplate(title: title, content: content));
    await fetchAllTemplates();
  }
  
  // update, delete 메소드도 위와 유사하게 구현
}