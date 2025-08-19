import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/submit_inquiry_viewmodel.dart';

class InquiryScreen extends ConsumerWidget {
  const InquiryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final titleController = ref.watch(inquiryTitleControllerProvider);
    final contentController = ref.watch(inquiryContentControllerProvider);
    final viewModel = ref.read(submitInquiryViewModelProvider.notifier);
    final viewModelState = ref.watch(submitInquiryViewModelProvider);

    // ViewModel의 상태 변화를 감지하여 성공/실패 메시지를 보여줍니다.
    ref.listen(submitInquiryViewModelProvider, (previous, next) {
      if (!next.isLoading && !next.hasError) {
        // 첫 빌드 시에는 무시하고, 로딩 후 성공 상태일 때만 실행
        if (previous is AsyncLoading) {
          context.pop(); // 성공 시 이전 화면으로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('문의가 성공적으로 접수되었습니다.')),
          );
        }
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: ${next.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('1:1 문의하기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? '제목을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contentController,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: '문의 내용',
                  hintText: '궁금하거나 불편한 점을 자세히 적어주세요.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? '내용을 입력해주세요.' : null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: viewModelState.isLoading ? null : () {
            if (formKey.currentState!.validate()) {
              viewModel.submit(
                title: titleController.text,
                content: contentController.text,
              );
            }
          },
          child: viewModelState.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('문의 제출하기'),
        ),
      ),
    );
  }
}