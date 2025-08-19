import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../data/models/group_buy_model.dart';
import '../../../data/models/my_participation_model.dart';
import '../../../providers/user_provider.dart';
import '../viewmodel/mypage_viewmodel.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProvider);

    // 💡 TabBar를 사용하기 위해 DefaultTabController로 Scaffold를 감쌉니다.
    return DefaultTabController(
      length: 2, // 탭은 '참여한 공구', '개설한 공구' 2개입니다.
      child: Scaffold(
        appBar: AppBar(
          title: const Text('마이페이지'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '참여한 공구'),
              Tab(text: '개설한 공구'),
            ],
          ),
        ),
        body: Column(
          children: [
            // --- 프로필 및 레벨 정보 카드 ---
            userProfileAsync.when(
              // 로딩 중일 때
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              // 에러 발생 시
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text('프로필 로딩 실패')),
              ),
              // 데이터 로딩 성공 시
              data: (userProfile) {
                if (userProfile == null) {
                  // 로그아웃 상태이거나, profiles 테이블에 데이터가 없는 경우
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('로그인 정보가 없습니다.')),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userProfile.username}님',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Lv. ${userProfile.level}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: userProfile.points / 1000,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${userProfile.points} / 1000 P',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            // --- 탭 화면 영역 ---
            Expanded(
              child: TabBarView(
                children: [
                  // '참여한 공구' 탭에 해당하는 위젯
                  _ParticipationList(),
                  // '개설한 공구' 탭에 해당하는 위젯
                  _HostedList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ## '참여한 공구' 목록을 보여주는 위젯
class _ParticipationList extends ConsumerWidget {
  const _ParticipationList();

  // status 값에 따라 아이콘과 텍스트를 반환하는 헬퍼 함수
  (IconData, String) _getStatusInfo(GroupBuyStatus status) {
    switch (status) {
      case GroupBuyStatus.recruiting:
        return (Icons.people_alt, '모집 중');
      case GroupBuyStatus.success:
      case GroupBuyStatus.preparing:
        return (Icons.inventory_2, '상품 준비 중');
      case GroupBuyStatus.shipped:
        return (Icons.local_shipping, '배송 중');
      case GroupBuyStatus.completed:
        return (Icons.check_circle, '배송 완료');
      case GroupBuyStatus.failed:
        return (Icons.cancel, '모집 실패');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 참여 목록 Provider를 watch합니다.
    final myParticipationsAsync = ref.watch(myPageViewModelProvider);

    return myParticipationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('참여 내역을 불러오지 못했습니다: $err')),
      data: (participations) {
        if (participations.isEmpty) {
          return const Center(child: Text('참여한 공동구매가 없습니다.'));
        }
        return RefreshIndicator(
          onRefresh: () => ref
              .read(myPageViewModelProvider.notifier)
              .fetchMyParticipations(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: participations.length,
            itemBuilder: (context, index) {
              final item = participations[index];
              final groupBuy = item.groupBuy;
              final product = groupBuy.product;

              if (product == null) {
                return const Card(
                  child: ListTile(title: Text('상품 정보를 불러오는 중...')),
                );
              }

              final (icon, statusText) = _getStatusInfo(groupBuy.status);
              final isActionable = groupBuy.status == GroupBuyStatus.recruiting;

              return InkWell(
                onTap: () {
                  context.goNamed(
                    AppRoute.groupBuyDetail.name,
                    pathParameters: {'id': groupBuy.id.toString()},
                    extra: groupBuy,
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  product.imageUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '주문 수량: ${item.quantity}개',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        icon,
                                        size: 18,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isActionable)
                          Column(
                            children: [
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    child: const Text('수량 변경'),
                                    onPressed: () =>
                                        _showQuantityDialog(context, ref, item),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('참여 취소'),
                                    onPressed: () => _showCancelConfirmDialog(
                                      context,
                                      ref,
                                      groupBuy.id,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 참여 취소 확인 다이얼로그
  void _showCancelConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    int groupBuyId,
  ) async {
    final viewModel = ref.read(myPageViewModelProvider.notifier);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('참여 취소'),
        content: const Text('정말로 참여를 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await viewModel.cancelParticipation(groupBuyId);
    }
  }

  // 수량 변경 다이얼로그
  void _showQuantityDialog(
    BuildContext context,
    WidgetRef ref,
    MyParticipation item,
  ) async {
    final viewModel = ref.read(myPageViewModelProvider.notifier);

    final newQuantity = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        final groupBuy = item.groupBuy;
        final otherParticipantsQuantity =
            groupBuy.currentParticipants - item.quantity;
        final maxQuantity =
            groupBuy.targetParticipants - otherParticipantsQuantity;
        final dialogQuantityProvider = StateProvider.autoDispose(
          (ref) => item.quantity,
        );

        return Consumer(
          builder: (context, ref, child) {
            final quantity = ref.watch(dialogQuantityProvider);
            final quantityNotifier = ref.read(dialogQuantityProvider.notifier);

            return AlertDialog(
              title: const Text('수량 변경'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: quantity > 1
                            ? () => quantityNotifier.state--
                            : null,
                      ),
                      Text(
                        quantity.toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: quantity < maxQuantity
                            ? () => quantityNotifier.state++
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '최대 $maxQuantity개까지 구매 가능합니다.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(quantity),
                  child: const Text('변경'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newQuantity != null) {
      await viewModel.editQuantity(item.groupBuy.id, newQuantity);
    }
  }
}

/// ## '개설한 공구' 목록을 보여주는 위젯
class _HostedList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 개설 목록 Provider를 watch합니다.
    final myHostedAsync = ref.watch(myHostedGroupBuysProvider);

    return myHostedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('개설 내역을 불러오지 못했습니다.')),
      data: (hostedBuys) {
        if (hostedBuys.isEmpty) {
          return const Center(child: Text('직접 개설한 공동구매가 없습니다.'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(myHostedGroupBuysProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: hostedBuys.length,
            itemBuilder: (context, index) {
              final groupBuy = hostedBuys[index];
              final product = groupBuy.product;

              return InkWell(
                onTap: () => context.goNamed(
                  AppRoute.groupBuyDetail.name,
                  pathParameters: {'id': groupBuy.id.toString()},
                  extra: groupBuy,
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: ListTile(
                    leading: product?.imageUrl != null
                        ? Image.network(
                            product!.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported, size: 50),
                    title: Text(product?.name ?? '상품 정보 없음'),
                    subtitle: Text(
                      '현재 상태: ${groupBuy.status.name} | 모집 현황: ${groupBuy.currentParticipants}/${groupBuy.targetParticipants}',
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
