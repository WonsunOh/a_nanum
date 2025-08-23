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

    return Scaffold(
      appBar: AppBar(
        title: const Text('나눔 스토어'),
        actions: [
          IconButton(
            onPressed: () => context.go('/group-buy'), // 공동구매 목록으로 이동
            icon: const Icon(Icons.group_work_outlined),
            tooltip: '공동구매 보러가기',
          ),
          IconButton(
            onPressed: () => context.go('/mypage'), // 마이페이지로 이동
            icon: const Icon(Icons.person_outline),
            tooltip: '마이페이지',
          )
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('등록된 상품이 없습니다.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(shopViewModelProvider.future),
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () { /* TODO: 상품 상세 페이지 이동 */ },
                  child: ProductGridItem(product: product),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('에러 발생: $err')),
      ),
    );
  }
}