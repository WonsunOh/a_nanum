import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/group_buy_model.dart';
import '../../../providers/user_provider.dart';
import '../viewmodel/group_buy_detail_viewmodel.dart';

class GroupBuyDetailScreen extends ConsumerWidget {
  final int groupBuyId;
  const GroupBuyDetailScreen({super.key, required this.groupBuyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final groupBuyAsync = ref.watch(groupBuyDetailProvider(groupBuyId));
    

    // 💡 userProvider는 이제 AsyncValue<Profile?>를 반환합니다.
    final currentUserAsync = ref.watch(userProvider);
    
    // 💡 .value를 사용하여 AsyncValue 상자 안의 Profile 데이터를 꺼냅니다.
    final currentUser = currentUserAsync.value;
    

    return groupBuyAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('데이터 로딩 실패'))),
      data: (groupBuy) {
        if (groupBuy == null) {
          return const Scaffold(body: Center(child: Text('존재하지 않는 공구입니다.')));
        }

        final product = groupBuy.product!;
        final singlePrice = (product.totalPrice / groupBuy.targetParticipants / 100).ceil() * 100;
        final isHost = currentUser?.id == groupBuy.hostId;
        final isRecruiting = groupBuy.status == GroupBuyStatus.recruiting;
        // --- groupBuy 데이터가 성공적으로 로드된 후의 기존 Scaffold UI ---
        // final product = groupBuy.product!; ... 등
        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
            // 💡 공구장일 때만 '목표 수량 수정' 버튼을 AppBar에 표시
            actions: [
              if (isHost && isRecruiting)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: '목표 수량 수정',
                  onPressed: () {
                    _showEditTargetDialog(
                      context, 
                      groupBuy.targetParticipants, // 현재 목표 수량
                      (newQuantity) { // 수정 완료 시 실행될 콜백 함수
                        ref.read(groupBuyDetailViewModelProvider.notifier)
                            .updateTargetQuantity(groupBuyId: groupBuy.id, newQuantity: newQuantity);
                      }
                    );
                  },
                )
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(product.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: 250),
                    ),
                  const SizedBox(height: 24),
                  Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildPriceInfo(context, singlePrice, product.totalPrice, groupBuy.targetParticipants),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  if (isRecruiting) 
                    _buildQuantitySelector(context, ref, groupBuy),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  _buildProgressInfo(context, groupBuy),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBottomButton(context, ref, groupBuy, isHost, isRecruiting, singlePrice),
          ),
        );
      }
    );
  }

  Widget _buildPriceInfo(BuildContext context, int singlePrice, int totalPrice, int targetParticipants) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${currencyFormat.format(singlePrice)} / 1인',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        Text(
          '총 ${currencyFormat.format(totalPrice)} ($targetParticipants인 기준)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildProgressInfo(BuildContext context, GroupBuy groupBuy) {
    final progress = groupBuy.currentParticipants / groupBuy.targetParticipants;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('모집 현황', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress,
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(height: 8),
        Text('${groupBuy.currentParticipants} / ${groupBuy.targetParticipants} 개 모집 중'),
      ],
    );
  }

  Widget _buildQuantitySelector(BuildContext context, WidgetRef ref, GroupBuy groupBuy) {
    final quantity = ref.watch(quantityProvider);
    final quantityNotifier = ref.read(quantityProvider.notifier);
    
    // 더 추가할 수 있는 최대 수량
    final remainingQuantity = groupBuy.targetParticipants - groupBuy.currentParticipants;
    
    // 현재 선택한 수량이 남은 수량보다 클 수 없도록 함. (단, 최소 1개는 선택 가능)
    final canIncrease = remainingQuantity > 0 && quantity < remainingQuantity;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('구매 수량', style: Theme.of(context).textTheme.titleLarge),
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
              Text(quantity.toString(), style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: canIncrease ? () => quantityNotifier.state++ : null,
              ),
            ],
          ),
        )
      ],
    );
  }

 // 💡 _buildBottomButton의 파라미터가 단순해집니다.
  Widget _buildBottomButton(BuildContext context, WidgetRef ref, GroupBuy groupBuy, bool isHost, bool isRecruiting, int singlePrice) {
    final quantity = ref.watch(quantityProvider);
    final viewModel = ref.read(groupBuyDetailViewModelProvider.notifier);
    final viewModelState = ref.watch(groupBuyDetailViewModelProvider);

    // 💡 모집이 다 찼는지 확인
    final isFull = groupBuy.currentParticipants >= groupBuy.targetParticipants;

    // 모집 기간이 끝났거나, 모집이 다 찼을 경우
    if (!isRecruiting || isFull) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
        child: Text(isFull ? '모집이 완료되었습니다' : '모집이 마감되었습니다'),
      );
    }

    // 모집 중인 경우 (공구장, 참여자 모두 동일한 버튼)
    return ElevatedButton(
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
      onPressed: viewModelState.isLoading ? null : () async {
        await viewModel.joinGroupBuy(
          groupBuyId: groupBuy.id,
          quantity: quantity,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$quantity개 추가 참여 완료!')));
          // 참여 후 홈 화면으로 돌아가거나, 현재 화면에 머무를 수 있습니다.
          // context.pop(); 
        }
      },
      child: const Text('수량 추가하여 참여하기'), // 버튼 텍스트 변경
    );
  }

  void _showEditTargetDialog(BuildContext context, int currentTarget, ValueChanged<int> onConfirm) {
    final controller = TextEditingController(text: currentTarget.toString());
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 수량 수정'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '새로운 목표 수량'),
            validator: (value) {
              if (value == null || value.isEmpty) return '수량을 입력해주세요.';
              final n = int.tryParse(value);
              if (n == null) return '숫자만 입력해주세요.';
              if (n <= 0) return '1 이상의 값을 입력해주세요.';
              // TODO: 현재 모집된 수량보다 적게 수정할 수 없도록 방어 로직 추가
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                onConfirm(int.parse(controller.text));
                Navigator.of(context).pop();
              }
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }
}