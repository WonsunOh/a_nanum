// user_app/lib/features/cart/view/cart_screen.dart

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
                  ? _buildWideLayout(context, ref, cartState)
                  : _buildNarrowLayout(context, ref, cartState),
              bottomNavigationBar: _buildBottomBar(context, ref, cartState),
            );
          },
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('장바구니')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('장바구니')),
        body: Center(child: Text('오류: $e')),
      ),
    );
  }

  // 모바일용 레이아웃
  Widget _buildNarrowLayout(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    final cartItems = cartState.items;
    final selectedIds = cartState.selectedItemIds;
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    if (cartItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '장바구니가 비어있습니다.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSelectAllHeader(context, ref, cartState),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              final product = item.product;
              if (product == null) return const SizedBox.shrink();

              final basePrice = product.discountPrice ?? product.price;
              final variantPrice = item.variantAdditionalPrice ?? 0;
              final finalPrice = basePrice + variantPrice;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 체크박스
                      Checkbox(
                        value: selectedIds.contains(item.id),
                        onChanged: (value) {
                          ref
                              .read(cartViewModelProvider.notifier)
                              .toggleItemSelection(item.id);
                        },
                      ),

                      // 상품 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl ?? '',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 상품 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 상품명
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            // 옵션 정보
                            if (item.variantName != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Text(
                                  item.variantName!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (item.variantAdditionalPrice != null &&
                                  item.variantAdditionalPrice! > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '+${currencyFormat.format(item.variantAdditionalPrice)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                            ] else
                              const SizedBox(height: 8),

                            // 가격 및 수량
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currencyFormat.format(finalPrice),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      '합계: ${currencyFormat.format(finalPrice * item.quantity)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => ref
                                          .read(cartViewModelProvider.notifier)
                                          .updateQuantity(
                                            item.id,
                                            item.quantity - 1,
                                          ),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      iconSize: 22,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 30,
                                        minHeight: 30,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => ref
                                          .read(cartViewModelProvider.notifier)
                                          .updateQuantity(
                                            item.id,
                                            item.quantity + 1,
                                          ),
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      iconSize: 22,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 30,
                                        minHeight: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => ref
                                          .read(cartViewModelProvider.notifier)
                                          .removeProduct(item.id),
                                      icon: const Icon(Icons.close),
                                      iconSize: 20,
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 데스크탑용 레이아웃
  Widget _buildWideLayout(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    final cartItems = cartState.items;
    final selectedIds = cartState.selectedItemIds;
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    if (cartItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 120, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              '장바구니가 비어있습니다.',
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSelectAllHeader(context, ref, cartState),
          const SizedBox(height: 16),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 48,
              ),
              child: DataTable(
                columnSpacing: 16,
                headingRowHeight: 50,
                dataRowHeight: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                columns: const [
                  DataColumn(
                    label: SizedBox(
                      width: 500,
                      child: Text(
                        '상품 정보',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 80,
                      child: Text(
                        '판매가',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text(
                        '수량',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 80,
                      child: Text(
                        '합계',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 60,
                      child: Text(
                        '삭제',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                rows: cartItems.map((item) {
                  final product = item.product!;
                  final basePrice = product.discountPrice ?? product.price;
                  final variantPrice = item.variantAdditionalPrice ?? 0;
                  final finalPrice = basePrice + variantPrice;

                  return DataRow(
                    selected: selectedIds.contains(item.id),
                    onSelectChanged: (isSelected) {
                      ref
                          .read(cartViewModelProvider.notifier)
                          .toggleItemSelection(item.id);
                    },
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageUrl ?? '',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.variantName != null) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        item.variantName!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (item.variantAdditionalPrice != null &&
                                        item.variantAdditionalPrice! > 0) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '+${currencyFormat.format(item.variantAdditionalPrice)}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          currencyFormat.format(finalPrice),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => ref
                                  .read(cartViewModelProvider.notifier)
                                  .updateQuantity(item.id, item.quantity - 1),
                              icon: const Icon(Icons.remove_circle_outline),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => ref
                                  .read(cartViewModelProvider.notifier)
                                  .updateQuantity(item.id, item.quantity + 1),
                              icon: const Icon(Icons.add_circle_outline),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          currencyFormat.format(finalPrice * item.quantity),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.close),
                          iconSize: 20,
                          color: Colors.red,
                          onPressed: () => ref
                              .read(cartViewModelProvider.notifier)
                              .removeProduct(item.id),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 전체 선택 헤더
  Widget _buildSelectAllHeader(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    final isAllSelected =
        cartState.selectedItemIds.length == cartState.items.length &&
        cartState.items.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isAllSelected,
            onChanged: (value) {
              ref.read(cartViewModelProvider.notifier).toggleSelectAll();
            },
          ),
          Text(
            '전체 선택 (${cartState.selectedItemIds.length}/${cartState.items.length})',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          if (cartState.selectedItemIds.isNotEmpty)
            TextButton.icon(
              onPressed: () => _showDeleteConfirmDialog(context, ref),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('선택삭제'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

  // 하단 결제 바
  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    const int shippingFee = 3000;
    const int freeShippingThreshold = 50000;

    final selectedItems = cartState.items
        .where((item) => cartState.selectedItemIds.contains(item.id))
        .toList();

    int subtotal = 0;
    for (final item in selectedItems) {
      final basePrice = item.product?.discountPrice ?? item.product?.price ?? 0;
      final variantPrice = item.variantAdditionalPrice ?? 0;
      final finalPrice = basePrice + variantPrice;
      subtotal += finalPrice * item.quantity;
    }

    final int currentShippingFee =
        (subtotal >= freeShippingThreshold || subtotal == 0) ? 0 : shippingFee;
    final int totalAmount = subtotal + currentShippingFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 배송비 정보
            if (subtotal > 0 && subtotal < freeShippingThreshold)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${currencyFormat.format(freeShippingThreshold - subtotal)} 더 담으면 무료배송!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '총 ${selectedItems.length}개 상품 선택',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          currencyFormat.format(totalAmount),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                        ),
                        if (currentShippingFee > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(배송비 ${currencyFormat.format(currentShippingFee)} 포함)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedItems.isEmpty
                        ? Colors.grey
                        : Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: selectedItems.isEmpty
                      ? null
                      : () => context.go('/shop/cart/checkout'),
                  child: Text(
                    selectedItems.isEmpty ? '상품을 선택하세요' : '주문하기',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 선택 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('선택 상품 삭제'),
        content: const Text('선택한 상품들을 장바구니에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              final selectedIds =
                  ref.read(cartViewModelProvider).value?.selectedItemIds ?? {};
              for (final id in selectedIds) {
                ref.read(cartViewModelProvider.notifier).removeProduct(id);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
