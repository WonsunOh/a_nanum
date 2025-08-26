// user_app/lib/features/cart/view/cart_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../viewmodel/cart_viewmodel.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartViewModelProvider);

    return cartAsync.when(
      data: (cartState) {
        // ⭐️ LayoutBuilder를 사용하여 화면 너비에 따라 다른 UI를 반환합니다.
        return LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth > 768;
            return Scaffold(
              appBar: AppBar(
                title: const Text('장바구니'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.home_outlined),
                    tooltip: '쇼핑 계속하기',
                    onPressed: () => context.go('/shop'),
                  ),
                ],
              ),
              body: isWideScreen
                  ? _buildWideLayout(ref, cartState) // 넓은 화면용 UI
                  : _buildNarrowLayout(ref, cartState), // 좁은 화면용 UI
              bottomNavigationBar: _buildBottomBar(context, ref, cartState),
            );
          },
        );
      },
      loading: () => Scaffold(body: const Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('오류: $e'))),
    );
  }

  // ⭐️ 좁은 화면(모바일)용 레이아웃: ListView
  Widget _buildNarrowLayout(WidgetRef ref, CartState cartState) {
    final cartItems = cartState.items;
    final selectedIds = cartState.selectedItemIds;
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    if (cartItems.isEmpty) {
      return const Center(child: Text('장바구니가 비어있습니다.'));
    }

    return Column(
      children: [
        _buildSelectAllHeader(ref, cartState),
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              final product = item.product;
              if (product == null) return const SizedBox.shrink();

              return ListTile(
                leading: Checkbox(
                  value: selectedIds.contains(item.id),
                  onChanged: (value) {
                    ref.read(cartViewModelProvider.notifier).toggleItemSelection(item.id);
                  },
                ),
                title: Text(product.name),
                subtitle: Text(currencyFormat.format(product.price)),
                trailing: Text('${item.quantity}개'),
              );
            },
          ),
        ),
      ],
    );
  }

  // ⭐️ 넓은 화면(웹)용 레이아웃: DataTable
  Widget _buildWideLayout(WidgetRef ref, CartState cartState) {
    final cartItems = cartState.items;
    final selectedIds = cartState.selectedItemIds;
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    if (cartItems.isEmpty) {
      return const Center(child: Text('장바구니가 비어있습니다.'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSelectAllHeader(ref, cartState),
          DataTable(
            columns: const [
              DataColumn(label: Text('상품 정보')),
              DataColumn(label: Text('판매가')),
              DataColumn(label: Text('수량')),
              DataColumn(label: Text('합계')),
              DataColumn(label: Text('삭제')),
            ],
            rows: cartItems.map((item) {
              final product = item.product!;
              final price = product.discountPrice ?? product.price;
              return DataRow(
                selected: selectedIds.contains(item.id),
                onSelectChanged: (isSelected) {
                  ref.read(cartViewModelProvider.notifier).toggleItemSelection(item.id);
                },
                cells: [
                  DataCell(Row(
                    children: [
                      Image.network(product.imageUrl ?? '', width: 50, height: 50, fit: BoxFit.cover),
                      const SizedBox(width: 16),
                      Expanded(child: Text(product.name)),
                    ],
                  )),
                  DataCell(Text(currencyFormat.format(price))),
                  DataCell(Text('${item.quantity}')),
                  DataCell(Text(currencyFormat.format(price * item.quantity))),
                  DataCell(IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref.read(cartViewModelProvider.notifier).removeProduct(item.id);
                    },
                  )),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 공통 위젯: 전체 선택 헤더
  Widget _buildSelectAllHeader(WidgetRef ref, CartState cartState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: cartState.selectedItemIds.length == cartState.items.length && cartState.items.isNotEmpty,
            onChanged: (value) {
              ref.read(cartViewModelProvider.notifier).toggleSelectAll();
            },
          ),
          Text('전체 선택 (${cartState.selectedItemIds.length}/${cartState.items.length})'),
          const Spacer(),
          const Spacer(),
          TextButton(onPressed: () { /* TODO: 선택 삭제 */ }, child: const Text('선택삭제')),
        ],
      ),
    );
  }

  // 공통 위젯: 하단 결제 바
  Widget _buildBottomBar(BuildContext context, WidgetRef ref, CartState cartState) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    const int shippingFee = 3000;
    const int freeShippingThreshold = 50000;

    final selectedItems = cartState.items.where((item) => cartState.selectedItemIds.contains(item.id)).toList();
    final int subtotal = selectedItems.fold(0, (sum, item) {
      final price = item.product?.discountPrice ?? item.product?.price ?? 0;
      return sum + (price * item.quantity);
    });
    final int currentShippingFee = (subtotal >= freeShippingThreshold || subtotal == 0) ? 0 : shippingFee;
    final int totalAmount = subtotal + currentShippingFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('총 ${selectedItems.length}개 상품 선택'),
              Text(
                currencyFormat.format(totalAmount),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
            onPressed: selectedItems.isEmpty ? null : () => context.go('/shop/cart/checkout'),
            child: const Text('주문하기'),
          ),
        ],
      ),
    );
  }
}