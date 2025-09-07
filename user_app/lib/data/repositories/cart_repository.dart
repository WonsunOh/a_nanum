// user_app/lib/data/repositories/cart_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item_model.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(Supabase.instance.client);
});

class CartRepository {
  final SupabaseClient _client;
  CartRepository(this._client);

Future<List<CartItemModel>> fetchCartItems() async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) return [];

  try {
    final response = await _client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<CartItemModel> cartItems = [];
    
    for (final item in response) {

      final variantId = item['variant_id'];
      Map<String, dynamic>? variantData;
      
      // ✅ variant_id가 있으면 별도로 조회
      if (variantId != null) {
        try {
          variantData = await _client
              .from('product_variants')
              .select('name, additional_price')
              .eq('id', variantId)
              .single();
        } catch (e) {
          print('Variant 조회 에러 (ID: $variantId): $e');
        }
      } 
      
      // variant 정보를 item에 추가
       final itemWithVariant = Map<String, dynamic>.from(item);
      if (variantData != null) {
        itemWithVariant['product_variants'] = variantData;
      } 
      
      final cartItem = CartItemModel.fromJson(itemWithVariant);
      
      cartItems.add(cartItem);
    }

    return cartItems;
  } catch (error) {
    print('장바구니 조회 에러: $error');
    return [];
  }
}

// user_app/lib/data/repositories/cart_repository.dart

Future<void> addProductToCart({
  required int productId, 
  required int quantity,
  int? variantId,
}) async {
  
  final userId = _client.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('로그인이 필요합니다.');
  }

  try {
    // ✅ 모든 해당 상품을 가져온 후 variant_id로 필터링
    final allItems = await _client
        .from('cart_items')
        .select('id, quantity, variant_id')
        .eq('user_id', userId)
        .eq('product_id', productId);


    // variant_id가 일치하는 아이템 찾기
    Map<String, dynamic>? existingItem;
    for (final item in allItems) {
      if (item['variant_id'] == variantId) {
        existingItem = item;
        break;
      }
    }


    if (existingItem != null) {
      // 기존 아이템 수량 업데이트
      await _client
          .from('cart_items')
          .update({'quantity': existingItem['quantity'] + quantity})
          .eq('id', existingItem['id']);
    } else {
      // 새 아이템 추가
      final insertData = {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      };
      
      if (variantId != null) {
        insertData['variant_id'] = variantId;
      }
      
      await _client.from('cart_items').insert(insertData);
    }
    
  } catch (error) {
    rethrow;
  }
}


  // ✅ 누락된 메서드 추가
  Future<void> updateCartItemQuantity({
    required int cartItemId, 
    required int newQuantity
  }) async {
    try {
      print('장바구니 수량 업데이트: ID $cartItemId, 새 수량 $newQuantity');
      
      await _client
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', cartItemId);
          
      print('수량 업데이트 완료');
    } catch (error) {
      print('수량 업데이트 에러: $error');
      throw error;
    }
  }

  // ✅ 누락된 메서드 추가
  Future<void> removeCartItem(int cartItemId) async {
    try {
      print('장바구니 아이템 삭제: ID $cartItemId');
      
      await _client
          .from('cart_items')
          .delete()
          .eq('id', cartItemId);
          
      print('아이템 삭제 완료');
    } catch (error) {
      print('아이템 삭제 에러: $error');
      throw error;
    }
  }
}