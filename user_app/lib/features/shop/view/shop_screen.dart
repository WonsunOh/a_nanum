// user_app/lib/features/shop/view/shop_screen.dart (수정)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/product_model.dart';
import '../viewmodel/product_viewmodel.dart';
import '../widgets/product_grid.dart';
import '../providers/category_filter_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productViewModelProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth >= 1000) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        return Container(
          color: Colors.grey.shade50,
          child: productsAsync.when(
            data: (products) {
              // 카테고리 및 검색 필터링
              final filteredProducts = _filterProducts(
                products, 
                selectedCategoryId, 
                searchQuery,
              );

              if (filteredProducts.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '조건에 맞는 상품이 없습니다',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ProductGrid(
                products: filteredProducts,
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.7,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('상품 로드 실패: $e'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(productViewModelProvider.future),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<ProductModel> _filterProducts(
    List<ProductModel> products, 
    int? categoryId, 
    String searchQuery,
  ) {
    var filtered = products;

    // 카테고리 필터링
    if (categoryId != null) {
      filtered = filtered.where((product) => product.categoryId == categoryId).toList();
    }

    // 검색 필터링
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }
}