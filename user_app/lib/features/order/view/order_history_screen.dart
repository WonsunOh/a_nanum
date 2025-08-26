// user_app/lib/features/order/view/order_history_screen.dart (새 파일)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 주문 내역을 불러오는 ViewModel을 만들어 연결해야 합니다.
    // final ordersAsync = ref.watch(orderHistoryViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 내역'),
      ),
      body: Center(
        child: Text('주문 내역이 여기에 표시됩니다.'),
      ),
    );
  }
}