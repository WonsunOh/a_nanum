import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/group_buy_model.dart';
import '../../../providers/user_provider.dart';
import '../viewmodel/group_buy_detail_viewmodel.dart';
import 'package:go_router/go_router.dart';

class GroupBuyDetailScreen extends ConsumerWidget {
  final GroupBuy groupBuy;
  const GroupBuyDetailScreen({super.key, required this.groupBuy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = groupBuy.product!;
    final singlePrice = (product.totalPrice / groupBuy.targetParticipants / 100).ceil() * 100;

    // 💡 userProvider는 이제 AsyncValue<Profile?>를 반환합니다.
    final currentUserAsync = ref.watch(userProvider);
    
    // 💡 .value를 사용하여 AsyncValue 상자 안의 Profile 데이터를 꺼냅니다.
    final currentUser = currentUserAsync.value;
    final isHost = currentUser?.id == groupBuy.hostId;
    final isRecruiting = groupBuy.status == GroupBuyStatus.recruiting;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
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
              if (isRecruiting && !isHost) // 공구장이 아닐 때만 수량 선택 UI 표시
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
        child: _buildBottomButton(context, ref, isHost, isRecruiting, singlePrice),
      ),
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

  Widget _buildBottomButton(BuildContext context, WidgetRef ref, bool isHost, bool isRecruiting, int singlePrice) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    final quantity = ref.watch(quantityProvider);
    final totalPrice = singlePrice * quantity;
    final viewModel = ref.read(groupBuyDetailViewModelProvider.notifier);
    final viewModelState = ref.watch(groupBuyDetailViewModelProvider);

    // 💡 모집이 다 찼는지 확인하는 변수 추가
  final isFull = groupBuy.currentParticipants >= groupBuy.targetParticipants;

    if (isHost && isRecruiting) {
      // 공구장일 때
      return ElevatedButton.icon(
        icon: const Icon(Icons.edit),
        label: const Text('목표 수량 수정하기'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        onPressed: () {
          _showEditTargetDialog(context, groupBuy.targetParticipants, (newQuantity) async {
            await viewModel.updateTargetQuantity(groupBuyId: groupBuy.id, newQuantity: newQuantity);
          });
        },
      );
    }
    
    // 참여자 또는 방문자일 때
    if (isRecruiting) {
      // 💡 모집이 다 찼을 경우
    if (isFull) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
        child: const Text('모집이 완료되었습니다'),
      );
    }
    // 💡 모집 중일 경우 (기존 참여하기 버튼)
      return ElevatedButton(
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        onPressed: viewModelState.isLoading ? null : () async {
          await viewModel.joinGroupBuy(
            groupBuyId: groupBuy.id,
            quantity: quantity,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$quantity개 참여 완료!')),
            );
            context.pop(); // 💡 참여 완료 후 이전 화면으로 이동
          }
        },
        child: viewModelState.isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('${currencyFormat.format(totalPrice)} 참여하기'),
      );
    } else {
      // 모집이 끝났을 때
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('모집이 마감되었습니다'),
      );
    }
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