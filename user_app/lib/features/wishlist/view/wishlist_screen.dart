// user_app/lib/features/wishlist/view/wishlist_screen.dart (새 파일)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodel/wishlist_viewmodel.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('찜한 목록'),
      ),
      body: wishlistAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('찜한 상품이 없습니다.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final product = item.product;
              if (product == null) return const SizedBox.shrink();

              return ListTile(
                leading: Image.network(product.imageUrl ?? '', width: 50, height: 50, fit: BoxFit.cover),
                title: Text(product.name),
                subtitle: Text('${product.price}원'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    // 찜 목록에서 삭제
                    ref.read(wishlistViewModelProvider.notifier).remove(product.id);
                  },
                ),
                onTap: () {
                  // 해당 상품의 상세 페이지로 이동
                  context.go('/shop/${product.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('찜 목록을 불러오는 중 오류 발생: $e')),
      ),
    );
  }
}