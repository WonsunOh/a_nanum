// user_app/lib/data/repositories/cart_repository.dart (새 파일)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item_model.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(Supabase.instance.client);
});

class CartRepository {
  final SupabaseClient _client;
  CartRepository(this._client);

  // 현재 사용자의 장바구니 목록을 상품 정보와 함께 가져옵니다.
  Future<List<CartItemModel>> fetchCartItems() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('cart_items')
        .select('*, products(*)') // ⭐️ products 테이블과 join하여 상품 정보를 함께 가져옵니다.
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map((item) => CartItemModel.fromJson(item)).toList();
  }

  // 장바구니에 상품을 추가합니다. (이미 존재하면 수량을 더합니다)
  Future<void> addProductToCart({required int productId, required int quantity}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    // Supabase의 RPC(Remote Procedure Call)를 사용하여 upsert 로직을 실행합니다.
    // upsert: 이미 상품이 있으면 quantity를 업데이트(update), 없으면 새로 추가(insert)
    await _client.rpc('add_to_cart', params: {
      'p_user_id': userId,
      'p_product_id': productId,
      'p_quantity': quantity,
    });
  }

  // 장바구니 상품 수량을 업데이트합니다.
  Future<void> updateCartItemQuantity({required int cartItemId, required int newQuantity}) async {
    await _client
        .from('cart_items')
        .update({'quantity': newQuantity})
        .eq('id', cartItemId);
  }

  // 장바구니에서 상품을 삭제합니다.
  Future<void> removeCartItem(int cartItemId) async {
    await _client
        .from('cart_items')
        .delete()
        .eq('id', cartItemId);
  }
}