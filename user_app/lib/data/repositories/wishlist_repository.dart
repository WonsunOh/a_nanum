// user_app/lib/data/repositories/wishlist_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wishlist_item_model.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(Supabase.instance.client);
});

class WishlistRepository {
  final SupabaseClient _client;
  WishlistRepository(this._client);

  Future<List<WishlistItemModel>> fetchWishlistItems() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('wishlist_items')
        .select('*, products(*)') // 상품 정보와 함께 join
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map((item) => WishlistItemModel.fromJson(item)).toList();
  }

  Future<void> addToWishlist(int productId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    await _client.from('wishlist_items').insert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  Future<void> removeFromWishlist(int productId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    await _client
        .from('wishlist_items')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}