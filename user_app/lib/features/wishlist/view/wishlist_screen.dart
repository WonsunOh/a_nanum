// user_app/lib/features/wishlist/view/wishlist_screen.dart (새 파일)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/wishlist_item_model.dart';
import '../viewmodel/wishlist_viewmodel.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistViewModelProvider);

  // 에러 상태 감시
  ref.listen<AsyncValue<List<WishlistItemModel>>>(wishlistViewModelProvider, (previous, next) {
    if (next.hasError && !next.isLoading) {
      final error = next.error.toString();
      String errorMessage;
      
      if (error.contains('로그인')) {
        errorMessage = '찜 목록을 보려면 로그인해주세요';
      } else {
        errorMessage = '찜 목록을 불러오는 중 오류가 발생했습니다';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(milliseconds: 2000),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.blue[600],
          action: error.contains('로그인') 
              ? SnackBarAction(
                  label: '로그인',
                  textColor: Colors.white,
                  onPressed: () => context.go('/login'),
                )
              : null,
        ),
      );
    }
  });

   return Scaffold(
    appBar: AppBar(
      title: const Text('찜한 목록'),
      actions: [
        // 디버깅용 새로고침 버튼 추가
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            print('🔄 찜 목록 새로고침');
            ref.invalidate(wishlistViewModelProvider);
          },
        ),
      ],
    ),
    body: wishlistAsync.when(
      data: (items) {
        print('📊 받은 찜 목록 데이터: ${items.length}개');
        
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  '찜한 상품이 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '마음에 드는 상품을 찜해보세요!',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/shop'),
                  child: const Text('쇼핑하러 가기'),
                ),
              ],
            ),
          );
        }

          return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final product = item.product;
            
            print('🔍 아이템 $index: ${product?.name ?? "상품 정보 없음"}');
            
            if (product == null) {
              return Card(
                child: ListTile(
                  title: Text('상품 정보가 없습니다 (ID: ${item.productId})'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref.read(wishlistViewModelProvider.notifier)
                          .removeFromWishlist(item.productId);
                    },
                  ),
                ),
              );
            }
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${product.price}원',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      _showDeleteDialog(context, ref, product.id, product.name);
                    },
                  ),
                  onTap: () {
                    context.go('/shop/${product.id}');
                  },
                ),
              );
            },
          );
        },
        loading: () {
        print('⏳ 찜 목록 로딩 중...');
        return const Center(child: CircularProgressIndicator());
      },
      error: (e, st) {
        print('🚨 찜 목록 에러: $e');
        print('📍 스택 트레이스: $st');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('찜 목록을 불러오는 중 오류 발생'),
              Text('$e'),
              ElevatedButton(
                onPressed: () => ref.invalidate(wishlistViewModelProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        );}
        ),
      );
    
  }

  // 삭제 확인 다이얼로그 추가
  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    int productId,
    String productName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('찜 삭제'),
        content: Text('"$productName"을(를) 찜 목록에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(wishlistViewModelProvider.notifier)
                  .removeFromWishlist(productId);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
