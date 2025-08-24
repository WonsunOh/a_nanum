// user_app/lib/features/order/view/checkout_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../cart/viewmodel/cart_viewmodel.dart';
import '../viewmodel/order_viewmodel.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // ⭐️ ref.read를 사용해 현재 장바구니 상태를 한 번만 읽어옵니다.
    final cartState = ref.read(cartViewModelProvider).valueOrNull;
    if (cartState == null || cartState.selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주문할 상품을 선택해주세요.')),
      );
      return;
    }

    // ⭐️ 선택된 아이템만 필터링하여 주문
    final selectedItems = cartState.items.where((item) => cartState.selectedItemIds.contains(item.id)).toList();


    // ⭐️ CartScreen의 계산 로직을 동일하게 적용합니다.
    const int shippingFee = 3000;
    const int freeShippingThreshold = 50000;
    final int subtotal = selectedItems.fold(0, (sum, item) {
            // 1. 할인가가 있는지 확인합니다.
            final hasDiscount = item.product?.discountPrice != null && item.product!.discountPrice! < item.product!.price;
            // 2. 할인가가 있으면 할인가를, 없으면 원래 가격을 사용합니다.
            final priceToShow = hasDiscount ? item.product!.discountPrice! : item.product!.price;
            // 3. (상품 가격 * 수량)을 누적하여 합산합니다.
            return sum + (priceToShow * item.quantity);
          });
    final int currentShippingFee = (subtotal >= freeShippingThreshold || subtotal == 0) ? 0 : shippingFee;
    final int totalAmount = subtotal + currentShippingFee;

    final success = await ref.read(orderViewModelProvider.notifier).createOrder(
      cartItems: selectedItems, // ⭐️ 선택된 아이템만 전달
      totalAmount: totalAmount,
      shippingFee: currentShippingFee,
      recipientName: _nameController.text,
      recipientPhone: _phoneController.text,
      shippingAddress: _addressController.text,
    );

    if (success && mounted) {
      context.go('/shop');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주문이 성공적으로 완료되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartViewModelProvider);
    final orderState = ref.watch(orderViewModelProvider);
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return Scaffold(
      appBar: AppBar(title: const Text('주문/결제')),
      body: cartAsync.when(
        data: (cartState) {
          // ⭐️ 선택된 아이템만 필터링
          final selectedItems = cartState.items.where((item) => cartState.selectedItemIds.contains(item.id)).toList();

          if (selectedItems.isEmpty) {
            return const Center(child: Text('주문할 상품을 선택해주세요.'));
          }
          final int subtotal = selectedItems.fold(0, (sum, item) => sum + ((item.product?.price ?? 0) * item.quantity));
          final int shippingFee = 3000; // Example
          final int totalAmount = subtotal + shippingFee;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('배송지 정보', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: '받는 사람'), validator: (v) => v!.isEmpty ? '필수' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: '연락처'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? '필수' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: '배송 주소'), validator: (v) => v!.isEmpty ? '필수' : null),
                  const Divider(height: 48),
                  Text('주문 상품 (${selectedItems.length}건)', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  // 주문 상품 목록 요약
                  ...selectedItems.map((item) => ListTile(
                    leading: Image.network(item.product?.imageUrl ?? '', width: 40, height: 40, fit: BoxFit.cover),
                    title: Text(item.product?.name ?? '상품명 없음'),
                    subtitle: Text('${currencyFormat.format(item.product?.price ?? 0)} / ${item.quantity}개'),
                  )),
                  const Divider(height: 48),
                  Text('결제 정보', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  // 결제 정보 요약
                  ListTile(title: const Text('총 상품 금액'), trailing: Text(currencyFormat.format(subtotal))),
                  ListTile(title: const Text('배송비'), trailing: Text(currencyFormat.format(shippingFee))),
                  ListTile(title: const Text('총 결제 금액'), trailing: Text(currencyFormat.format(totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('오류: $e')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: orderState.isLoading ? null : _submitOrder,
          child: orderState.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('결제하기'),
        ),
      ),
    );
  }
}