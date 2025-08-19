import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/configure_group_buy_viewmodel.dart';
import 'configure_group_buy_screen.dart'; // 다음 화면 import

class SelectProductScreen extends ConsumerWidget {
  const SelectProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(masterProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('공구할 상품 선택')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('상품 목록을 불러오지 못했습니다: $e')),
        data: (products) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return InkWell(
                onTap: () {
                  // 선택한 상품 정보를 다음 화면으로 전달하며 이동
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ConfigureGroupBuyScreen(product: product),
                    ),
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.imageUrl != null)
                        Image.network(product.imageUrl!, fit: BoxFit.cover, height: 180, width: double.infinity),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(product.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}