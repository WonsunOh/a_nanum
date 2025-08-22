import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/models/group_buy_model.dart';
import '../viewmodel/create_group_buy_viewmodel.dart';

final participantsControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final initialQuantityProvider = StateProvider.autoDispose<int>((ref) => 1);
final deadlineProvider = StateProvider.autoDispose<DateTime?>((ref) => null);

class ConfigureGroupBuyScreen extends ConsumerWidget {
  final Product product;
  const ConfigureGroupBuyScreen({super.key, required this.product});
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
   final participantsController = ref.watch(participantsControllerProvider);
    final quantity = ref.watch(initialQuantityProvider);
    final quantityNotifier = ref.read(initialQuantityProvider.notifier);

     final deadline = ref.watch(deadlineProvider);
    final deadlineNotifier = ref.read(deadlineProvider.notifier);
    // 💡 1. '명령'을 내릴 ViewModel을 준비합니다.
    final viewModel = ref.read(createGroupBuyViewModelProvider.notifier);
    // 💡 2. ViewModel의 '상태'를 감시하여 로딩 UI를 업데이트합니다.
    final viewModelState = ref.watch(createGroupBuyViewModelProvider);

    // 💡 3. ViewModel의 '상태 변화'를 감지하여 후속 처리를 하는 리스너입니다.
    ref.listen(createGroupBuyViewModelProvider, (previous, next) {
      // 로딩이 끝났고, 에러가 없는 '성공' 상태일 때
      if (previous is AsyncLoading && !next.isLoading && !next.hasError) {
        // 페이지 이동과 스낵바 표시는 여기서만 처리합니다.
        context.go('/home');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('새로운 공구가 개설되었습니다!')));
      } else if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: ${next.error}')));
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
              decoration: const InputDecoration(
                labelText: '총 모집 수량 (내 주문 포함)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return '모집 수량을 입력해주세요.';
                if (int.tryParse(value) == null || int.parse(value) <= 1) return '2개 이상을 입력해주세요.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 💡 '내 주문 수량' 입력 필드 추가
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('내 주문 수량', style: Theme.of(context).textTheme.titleMedium),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: quantity > 1 ? () => quantityNotifier.state-- : null,
                      ),
                      Text(quantity.toString(), style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final total = int.tryParse(participantsController.text);
                          if (total != null && quantity >= total) {
                            // 총 모집 인원을 넘을 수 없음
                            return;
                          }
                          quantityNotifier.state++;
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            // --- 👇 마감일 선택 UI 추가 ---
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('모집 마감일'),
              subtitle: Text(
                deadline == null ? '날짜를 선택해주세요' : DateFormat('yyyy년 MM월 dd일').format(deadline),
              ),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (selectedDate != null) {
                  deadlineNotifier.state = selectedDate;
                }
              },
            ),
            // --- 👆 여기까지 ---

            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: viewModelState.isLoading ? null : () async {
                if (formKey.currentState!.validate()) {
                 if (deadline == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('마감일을 선택해주세요.')));
                    return;
                  }
                  final success = await viewModel.createGroupBuy(
                    productId: product.id,
                    targetParticipants: int.parse(participantsController.text),
                    initialQuantity: quantity,
                    deadline: deadline, // 💡 deadline 전달
                  );
                  if (success && context.mounted) {
                    context.go('/home');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('새로운 공구가 개설되었습니다!')));
                  }
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