// user_app/lib/features/cart/view/cart_screen.dart (새 파일)

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
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    // ⭐️ 배송비 정책 (나중에 어드민에서 설정 가능하도록 변경)
    const int shippingFee = 3000;
    const int freeShippingThreshold = 50000; // 5만원 이상 무료배송

    return Scaffold(
      appBar: AppBar(
        title: const Text('장바구니'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: '쇼핑 계속하기',
            onPressed: () {
              // 쇼핑몰 메인 화면으로 이동합니다.
              context.go('/shop');
            },
          ),
        ],
      ),
      body: cartAsync.when(
        data: (cartState) {
          final cartItems = cartState.items;
          final selectedIds = cartState.selectedItemIds;
          if (cartItems.isEmpty) {
            return const Center(child: Text('장바구니가 비어있습니다.'));
          }

          // ⭐️ 선택된 상품들만 필터링
          final selectedItems = cartItems.where((item) => selectedIds.contains(item.id)).toList();


          // ⭐️ checkout_screen.dart와 동일한, 정확한 계산식으로 수정합니다.
          final int subtotal = selectedItems.fold(0, (sum, item) {
            // 1. 할인가가 있는지 확인합니다.
            final hasDiscount = item.product?.discountPrice != null && item.product!.discountPrice! < item.product!.price;
            // 2. 할인가가 있으면 할인가를, 없으면 원래 가격을 사용합니다.
            final priceToShow = hasDiscount ? item.product!.discountPrice! : item.product!.price;
            // 3. (상품 가격 * 수량)을 누적하여 합산합니다.
            return sum + (priceToShow * item.quantity);
          });

          // 2. 배송비 계산
          final int currentShippingFee = (subtotal >= freeShippingThreshold || subtotal == 0) ? 0 : shippingFee;
          
          // 3. 최종 결제 금액
          final int totalAmount = subtotal + currentShippingFee;

          return Column(
            children: [
              // ⭐️ 전체 선택 체크박스 추가
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: selectedIds.length == cartItems.length && cartItems.isNotEmpty,
                      onChanged: (value) {
                        ref.read(cartViewModelProvider.notifier).toggleSelectAll();
                      },
                    ),
                    Text('전체 선택 (${selectedIds.length}/${cartItems.length})'),
                    const Spacer(),
                    TextButton(onPressed: (){ /* TODO: 선택 삭제 */ }, child: const Text('선택삭제')),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${item.quantity}개'),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              ref.read(cartViewModelProvider.notifier).removeProduct(item.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // 하단 결제 정보 바
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPriceRow('상품 금액', currencyFormat.format(subtotal)),
                    const SizedBox(height: 8),
                    _buildPriceRow('배송비', currencyFormat.format(currentShippingFee)),
                    const Divider(height: 24),
                    _buildPriceRow('총 결제금액', currencyFormat.format(totalAmount), isTotal: true),
                  ],
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('장바구니를 불러오는 중 오류가 발생했습니다: $e')),
      ),
       bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: (cartAsync.value?.selectedItemIds.isEmpty ?? true)
              ? null
              : () => context.go('/shop/cart/checkout'),
          child: const Text('주문하기'),
        ),
      ),
    );
  }

  // 가격 행을 만드는 공통 위젯
  Widget _buildPriceRow(String title, String price, {bool isTotal = false}) {
    final style = TextStyle(
      fontSize: isTotal ? 20 : 16,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style),
        Text(price, style: style.copyWith(color: isTotal ? Colors.deepOrange : null)),
      ],
    );
  }
}