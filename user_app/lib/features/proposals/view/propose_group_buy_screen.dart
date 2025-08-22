import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/proposal_viewmodel.dart';

class ProposeGroupBuyScreen extends ConsumerWidget {
  const ProposeGroupBuyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final reasonController = TextEditingController();

    final viewModel = ref.read(proposalViewModelProvider.notifier);
    final viewModelState = ref.watch(proposalViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('공동구매 신청하기')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              '원하는 상품이 없으신가요?\n관리자에게 공구 개설을 요청해보세요!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '상품명',
                hintText: '정확한 상품명을 입력해주세요',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.isEmpty) ? '상품명을 입력해주세요.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: '참고 링크 (선택)',
                hintText: '상품을 확인할 수 있는 URL을 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: '신청 이유 (선택)',
                hintText: '이 상품을 공구하고 싶은 이유를 알려주세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: viewModelState.isLoading ? null : () async {
                if (formKey.currentState!.validate()) {
                  final success = await viewModel.submitProposal(
                    productName: nameController.text,
                    productUrl: urlController.text,
                    reason: reasonController.text,
                  );
                  if (success && context.mounted) {
                    context.pop(); // 신청 후 이전 화면으로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('신청이 완료되었습니다. 관리자 검토 후 알려드릴게요!')),
                    );
                  }
                }
              },
              child: viewModelState.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('신청하기'),
            ),
          ],
        ),
      ),
    );
  }
}