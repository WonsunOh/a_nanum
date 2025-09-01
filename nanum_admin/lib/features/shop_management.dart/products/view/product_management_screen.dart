// nanum_admin/lib/features/shop_management/products/view/product_management_screen.dart (전체 수정)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';
import '../viewmodel/product_viewmodel.dart';

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen> {
  final ScrollController _horizontalController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _searchController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productViewModelProvider);
    
    // 삭제 확인 다이얼로그
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 관리'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              context.go('/shop/products/new');
            },
            icon: const Icon(Icons.add),
            label: const Text('상품 추가'),
            style: ElevatedButton.styleFrom(
              // 버튼 배경색 및 텍스트 색상 조정
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 8), // 버튼과 드롭다운 사이 간격
          // ⭐️ 드롭다운 버튼 추가
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete_images') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('정말 삭제하시겠습니까?'),
                    content: const Text(
                        'products/public 폴더의 모든 이미지가 영구적으로 삭제됩니다. 되돌릴 수 없습니다.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소')),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('삭제')),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  showDialog(
                      context: context,
                      barrierDismissible: false, // 사용자가 닫을 수 없도록
                      builder: (_) => const Center(
                            child: CircularProgressIndicator(),
                          ));

                  await ref
                      .read(productRepositoryProvider)
                      .emptyPublicFolderInProducts();

                  Navigator.of(context).pop(); // 로딩 인디케이터 닫기

                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이미지 삭제 작업을 요청했습니다.')));
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'delete_images',
                // 텍스트 스타일을 통해 눈에 잘 띄게 하지만, 기본색은 어둡게
                child: Text(
                  '이미지 폴더 비우기 (Public)',
                  style: TextStyle(color: Colors.red), 
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert), // 드롭다운 아이콘
            tooltip: '추가 관리 기능',
          ),
          const SizedBox(width: 8), // AppBar 끝과의 간격
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100), 
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: '상품명으로 검색...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onSubmitted: (value) {
                         ref.read(productViewModelProvider.notifier).searchProducts(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('검색'),
                    onPressed: () {
                      ref.read(productViewModelProvider.notifier).searchProducts(_searchController.text);
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(productViewModelProvider.notifier).fetchAllProducts();
                    },
                    child: const Text('전체보기'),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
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
                        // ⭐️ 더 이상 categoriesProvider를 watch할 필요가 없습니다.
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('상품코드')),
                            DataColumn(label: Text('연관상품코드')),
                            DataColumn(label: Text('이미지')),
                            DataColumn(label: Text('카테고리')), // 컬럼은 그대로 유지
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
                              // ⭐️ product.categoryName을 직접 사용하여 카테고리 이름을 표시합니다.
                              DataCell(Text(product.categoryPath ?? '미지정')),
                              DataCell(Text(product.name)),
                              DataCell(
              (product.discountPrice != null && product.discountPrice! > 0)
                  ? Column(
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
                    )
                  : Text('${product.price}원'),
                  ),
                              DataCell(Switch(
                                value: product.isSoldOut,
                                onChanged: (value) {
                                  final updatedProduct = product.copyWith(isSoldOut: value);
                                  ref.read(productViewModelProvider.notifier).updateProductDetails(updatedProduct);
                                },
                              )),
                              DataCell(Switch(
                                value: product.isDisplayed,
                                onChanged: (value) {
                                  final updatedProduct = product.copyWith(isDisplayed: value);
                                  ref.read(productViewModelProvider.notifier).updateProductDetails(updatedProduct);
                                },
                              )),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    tooltip: '수정',
                                    onPressed: () {
                                      context.go('/shop/products/edit/${product.id}', extra: product);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    tooltip: '삭제',
                                    onPressed: () => showDeleteConfirmDialog(product),
                                  ),
                                ],
                              )),
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
            ),
          ],
        ),
      ),
    );
  }
}