// File: nanum_admin/lib/features/order_management/view/order_cancellation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/cancellation_model.dart';
import '../viewmodel/cancellation_viewmodel.dart';

class OrderCancellationScreen extends ConsumerStatefulWidget {
  const OrderCancellationScreen({super.key});

  @override
  ConsumerState<OrderCancellationScreen> createState() =>
      _OrderCancellationScreenState();
}

class _OrderCancellationScreenState extends ConsumerState<OrderCancellationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cancellationViewModelProvider.notifier).fetchCancellations(CancellationType.full, isRefresh: true);
    });
  }
  
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final type = _tabController.index == 0 ? CancellationType.full : CancellationType.partial;
    ref.read(cancellationViewModelProvider.notifier).fetchCancellations(type, isRefresh: true);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 취소/반품 관리'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체 취소'),
            Tab(text: '부분 취소'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCancellationList(CancellationType.full),
          _buildCancellationList(CancellationType.partial),
        ],
      ),
    );
  }

  Widget _buildCancellationList(CancellationType type) {
    final cancellationState = ref.watch(cancellationViewModelProvider);

    return cancellationState.when(
      data: (cancellations) {
        final filteredList = cancellations.where((c) => c.type == type).toList();
        if (filteredList.isEmpty) {
          return Center(child: Text('${type == CancellationType.full ? '전체' : '부분'} 취소 내역이 없습니다.'));
        }
        return ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final item = filteredList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('주문 ID: ${item.orderId}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('요청일: ${item.formattedRequestedAt}'),
                    Text('사유: ${item.reason}'),
                    if (item.type == CancellationType.partial)
                      Text('취소 상품: ${item.productName} (${item.quantity}개)'),
                  ],
                ),
                trailing: item.type == CancellationType.full
                    ? Text('${item.refundedAmount}원 환불', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),)
                    : const Icon(Icons.info_outline),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('오류 발생: $error')),
    );
  }
}