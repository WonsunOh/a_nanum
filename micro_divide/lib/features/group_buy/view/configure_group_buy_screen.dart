import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/group_buy_model.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/configure_group_buy_viewmodel.dart';

class ConfigureGroupBuyScreen extends ConsumerWidget {
  final Product product;
  const ConfigureGroupBuyScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final participantsController = TextEditingController();
    final viewModel = ref.read(configureGroupBuyViewModelProvider.notifier);
    final viewModelState = ref.watch(configureGroupBuyViewModelProvider);

    ref.listen(configureGroupBuyViewModelProvider, (prev, next) {
      if (!next.isLoading && !next.hasError) {
        if (prev is AsyncLoading) {
          context.go('/home'); // 성공 시 홈으로 이동
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('새로운 공구가 개설되었습니다!')));
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('공구 조건 설정')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('선택한 상품', style: Theme.of(context).textTheme.titleMedium),
            ListTile(
              leading: product.imageUrl != null ? Image.network(product.imageUrl!) : null,
              title: Text(product.name),
              subtitle: Text('${product.totalPrice}원'),
            ),
            const Divider(height: 32),
            TextFormField(
              controller: participantsController,
              decoration: const InputDecoration(labelText: '모집 인원 (숫자만)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return '모집 인원을 입력해주세요.';
                if (int.tryParse(value) == null || int.parse(value) <= 1) return '2명 이상을 입력해주세요.';
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: viewModelState.isLoading ? null : () {
                if (formKey.currentState!.validate()) {
                  viewModel.createGroupBuy(
                    productId: product.id,
                    targetParticipants: int.parse(participantsController.text),
                  );
                }
              },
              child: viewModelState.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('공동구매 개설하기'),
            )
          ],
        ),
      ),
    );
  }
}