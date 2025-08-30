// nanum_admin/lib/features/shop_management.dart/products/view/discount_product_screen.dart (전체 수정)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/discount_product_viewmodel.dart';
import '../widgets/price_edit_dialog.dart';

// ⭐️ 날짜를 'YYYY-MM-DD' 형식으로 변환하는 헬퍼 함수
String _formatDate(DateTime? date) {
  if (date == null) return '';
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

class DiscountProductScreen extends ConsumerStatefulWidget {
  const DiscountProductScreen({super.key});

  @override
  ConsumerState<DiscountProductScreen> createState() =>
      _DiscountProductScreenState();
}

class _DiscountProductScreenState extends ConsumerState<DiscountProductScreen> {
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discountProductsAsync = ref.watch(discountProductViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('할인상품 관리'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
        // .future 없이 provider 자체를 refresh하거나,
        // notifier의 메서드를 직접 호출합니다.
        return ref.refresh(discountProductViewModelProvider);
      },
        child: discountProductsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return const Center(child: Text('할인 중인 상품이 없습니다.'));
            }
            return Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('상품코드')),
                    DataColumn(label: Text('이미지')),
                    DataColumn(label: Text('카테고리')),
                    DataColumn(label: Text('상품명')),
                    DataColumn(label: Text('가격 정보')),
                    DataColumn(label: Text('할인 기간')), // ⭐️ 컬럼 추가
                    DataColumn(label: Text('재고')),
                    DataColumn(label: Text('관리')),
                  ],
                  rows: products.map((product) {
                    return DataRow(cells: [
                      DataCell(Text(product.productCode ?? '-')),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: (product.imageUrl != null &&
                                  product.imageUrl!.isNotEmpty)
                              ? Image.network(product.imageUrl!,
                                  width: 40, height: 40, fit: BoxFit.cover)
                              : const Icon(Icons.image_not_supported,
                                  size: 24),
                        ),
                      ),
                      DataCell(Text(product.categoryPath ?? '미지정')),
                      DataCell(Text(product.name)),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${product.price}원',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${product.discountPrice}원',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          (product.discountStartDate != null || product.discountEndDate != null)
                            ? '${_formatDate(product.discountStartDate)}\n~ ${_formatDate(product.discountEndDate)}'
                            : '상시 할인'
                        )
                      ),
                      DataCell(Text(product.stockQuantity.toString())),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: '할인 정보 수정',
                          // ⭐️ [해결책] 올바른 파라미터와 함께 다이얼로그 호출
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => PriceEditDialog(
                                product: product,
                                source: PriceUpdateSource.discountList,
                              ),
                            );
                          },
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('오류: $e')),
        ),
      ),
    );
  }
}