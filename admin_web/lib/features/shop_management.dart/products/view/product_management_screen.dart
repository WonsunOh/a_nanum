// admin_web/lib/features/shop_management/products/view/product_management_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/product_model.dart';
import '../../categories/viewmodel/category_viewmodel.dart';
import '../viewmodel/product_viewmodel.dart';
import '../widgets/add_edit_product_dialog.dart';

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen> {
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productViewModelProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

     void showProductDialog({ProductModel? product}) {

      // ⭐️ when을 사용하여 로딩, 데이터, 에러 상태를 명확하게 구분합니다.
      categoriesAsync.when(
        data: (categories) {
          // 데이터가 성공적으로 로드되었을 때만 다이얼로그를 보여줍니다.
          showDialog(
            context: context,
            builder: (_) => AddEditProductDialog(
              categories: categories,
              productToEdit: product,
            ),
          );
        },
        loading: () {
          // 아직 로딩 중일 때
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('카테고리 목록을 로딩 중입니다. 잠시 후 다시 시도해주세요.')),
          );
        },
        error: (error, stackTrace) {
          // 에러가 발생했을 때
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('카테고리 로딩 중 오류가 발생했습니다: $error'),
              backgroundColor: Colors.red,
            ),
          );
          
        },
      );
    }

    void showDeleteConfirmDialog(ProductModel product) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('상품 삭제'),
          content: Text('[${product.name}] 상품을 정말로 삭제하시겠습니까?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
            TextButton(
              onPressed: () {
                ref.read(productViewModelProvider.notifier).deleteProduct(product.id);
                Navigator.of(context).pop();
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    /// 이미지 미리보기 위젯
  Widget _buildImagePreview(XFile? localImage, ProductModel? existingProduct) {
    if (localImage != null) {
      return Image.network(localImage.path, fit: BoxFit.cover);
    }
    if (existingProduct?.imageUrl != null) {
      return Image.network(existingProduct!.imageUrl!, fit: BoxFit.cover);
    }
    return const Center(child: Text('이미지 선택'));
  }

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '새 상품 등록',
            onPressed: () => showProductDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(productViewModelProvider.future),
        child: productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return const Center(child: Text('등록된 상품이 없습니다.'));
            }
            return Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: categoriesAsync.when(
                data: (categories) {
                  // 카테고리 ID를 이름으로 변환하기 위한 맵 생성
                  final categoryMap = {for (var cat in categories) cat.id: cat.name};

                    return DataTable(
                      columns: const [
                        DataColumn(label: Text('상품코드')),
                      DataColumn(label: Text('연관상품코드')),
                      DataColumn(label: Text('이미지')),
                      DataColumn(label: Text('카테고리')),
                      DataColumn(label: Text('상품명')),
                      DataColumn(label: Text('가격')),
                      DataColumn(label: Text('품절')),
                      DataColumn(label: Text('진열')),
                      DataColumn(label: Text('관리')),
                      ],
                      rows: products.map((product) {
                        return DataRow(cells: [
                          DataCell(Text(product.productCode ?? '-')),
                        DataCell(Text(product.relatedProductCode ?? '-')),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                                ? Image.network(product.imageUrl!, width: 40, height: 40, fit: BoxFit.cover)
                                : const Icon(Icons.image_not_supported, size: 24),
                          ),
                        ),
                        // ⭐️ 카테고리 ID를 이름으로 표시
                        DataCell(Text(categoryMap[product.categoryId] ?? '미지정')),
                        DataCell(Text(product.name)),
                        DataCell(Text('${product.price}원')),
                        // ⭐️ '품절' 체크 스위치 추가
                        DataCell(Switch(
                          value: product.isSoldOut,
                          onChanged: (value) {
                            final updatedProduct = product.copyWith(isSoldOut: value);
                            ref.read(productViewModelProvider.notifier).updateProduct(updatedProduct);
                          },
                        )),
                        DataCell(Switch(
                          value: product.isDisplayed,
                          onChanged: (value) {
                            final updatedProduct = product.copyWith(isDisplayed: value);
                            ref.read(productViewModelProvider.notifier).updateProduct(updatedProduct);
                          },
                        )),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => showProductDialog(product: product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => showDeleteConfirmDialog(product),
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    );
                  },
                  // 카테고리 로딩 중/에러 시 처리
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('카테고리 로딩 실패: $e')),
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