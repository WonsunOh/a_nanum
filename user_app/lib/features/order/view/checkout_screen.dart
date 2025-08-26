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

    return Scaffold(
      appBar: AppBar(title: const Text('주문/결제')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 768;
          return isWideScreen
              ? _buildWideLayout() // 넓은 화면 UI
              : _buildNarrowLayout(); // 좁은 화면 UI
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return const SizedBox.shrink(); // 넓은 화면에서는 숨김
          }
          final orderState = ref.watch(orderViewModelProvider);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: orderState.isLoading ? null : _submitOrder,
              child: orderState.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('결제하기'),
            ),
          );
        },
      ),
    );
  }

  // 좁은 화면(모바일)용 레이아웃
  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildShippingForm(),
          const Divider(height: 48),
          _buildOrderSummary(),
        ],
      ),
    );
  }

  // 넓은 화면(웹)용 레이아웃
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 왼쪽: 배송지 정보 입력 폼
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: _buildShippingForm(),
          ),
        ),
        const VerticalDivider(width: 1),
        // 오른쪽: 주문 요약
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: _buildOrderSummary(),
                ),
              ),
              // ⭐️ 넓은 화면에서는 결제 버튼이 여기에 위치합니다.
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Consumer(
                  builder: (context, ref, child) {
                    final orderState = ref.watch(orderViewModelProvider);
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: orderState.isLoading ? null : _submitOrder,
                      child: orderState.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('결제하기'),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 공통 위젯: 배송지 정보 폼
  Widget _buildShippingForm() {
    return Form(
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
        ],
      ),
    );
  }

  // 공통 위젯: 주문 요약
  Widget _buildOrderSummary() {
    final cartAsync = ref.watch(cartViewModelProvider);
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return cartAsync.when(
      data: (cartState) {
        final selectedItems = cartState.items.where((item) => cartState.selectedItemIds.contains(item.id)).toList();
        if (selectedItems.isEmpty) return const Text('주문할 상품이 없습니다.');

        const int shippingFee = 3000;
        const int freeShippingThreshold = 50000;
        final int subtotal = selectedItems.fold(0, (sum, item) {
          final price = item.product?.discountPrice ?? item.product?.price ?? 0;
          return sum + (price * item.quantity);
        });
        final int currentShippingFee = (subtotal >= freeShippingThreshold || subtotal == 0) ? 0 : shippingFee;
        final int totalAmount = subtotal + currentShippingFee;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('주문 요약', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...selectedItems.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Image.network(item.product?.imageUrl ?? '', width: 40, fit: BoxFit.cover),
              title: Text(item.product?.name ?? ''),
              trailing: Text('${item.quantity}개'),
            )),
            const Divider(height: 32),
            _buildPriceRow('총 상품 금액', currencyFormat.format(subtotal)),
            const SizedBox(height: 8),
            _buildPriceRow('배송비', currencyFormat.format(currentShippingFee)),
            const Divider(height: 24),
            _buildPriceRow('최종 결제 금액', currencyFormat.format(totalAmount), isTotal: true),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Text('장바구니 정보를 불러올 수 없습니다.'),
    );
  }
  
  // 가격 행을 만드는 공통 위젯
  Widget _buildPriceRow(String title, String price, {bool isTotal = false}) {
    final style = TextStyle(
      fontSize: isTotal ? 18 : 14,
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