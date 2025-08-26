// user_app/lib/features/shop/view/shop_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/shop_viewmodel.dart';
import '../widgets/product_grid_item.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(shopViewModelProvider);

    return productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('등록된 상품이 없습니다.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(shopViewModelProvider.future),
            // ⭐️ LayoutBuilder 대신 GridView를 바로 사용합니다.
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280), // ⭐️ 최대 너비를 1280px로 설정
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                // ⭐️ 더 똑똑한 SliverGridDelegateWithMaxCrossAxisExtent를 사용합니다.
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300.0, // 각 아이템의 최대 너비를 300으로 지정
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      context.go('/shop/${product.id}');
                    },
                    child: ProductGridItem(product: product),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('에러 발생: $err')),
      
    );
  }
}