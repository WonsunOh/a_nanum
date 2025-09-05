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
    print('=== 장바구니 조회 시작 ===');
    final response = await _client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    print('장바구니 기본 데이터: $response');

    final List<CartItemModel> cartItems = [];
    
    for (final item in response) {
      print('--- 아이템 처리 시작 ---');
      print('아이템 ID: ${item['id']}');
      print('상품 ID: ${item['product_id']}');
      print('variant_id: ${item['variant_id']}');

      final variantId = item['variant_id'];
      Map<String, dynamic>? variantData;
      
      // ✅ variant_id가 있으면 별도로 조회
      if (variantId != null) {
        try {
          print('Variant 조회 시작: ID $variantId');
          variantData = await _client
              .from('product_variants')
              .select('name, additional_price')
              .eq('id', variantId)
              .single();
              print('Variant 조회 성공: $variantData');
        } catch (e) {
          print('Variant 조회 에러 (ID: $variantId): $e');
        }
      } else {
        print('variant_id가 null임');
      }
      
      // variant 정보를 item에 추가
       final itemWithVariant = Map<String, dynamic>.from(item);
      if (variantData != null) {
        itemWithVariant['product_variants'] = variantData;
        print('Variant 데이터 추가됨: $variantData');
      } else {
        print('Variant 데이터 없음');
      }
      
      final cartItem = CartItemModel.fromJson(itemWithVariant);
      print('CartItemModel 생성 완료:');
      print('- variantId: ${cartItem.variantId}');
      print('- variantName: ${cartItem.variantName}');
      print('- variantAdditionalPrice: ${cartItem.variantAdditionalPrice}');
      
      cartItems.add(cartItem);
      print('--- 아이템 처리 완료 ---');
    }

    print('=== 장바구니 조회 완료: ${cartItems.length}개 ===');
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
  print('=== addProductToCart 호출 ===');
  print('productId: $productId, quantity: $quantity, variantId: $variantId');
  
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

    print('기존 아이템들: $allItems');

    // variant_id가 일치하는 아이템 찾기
    Map<String, dynamic>? existingItem;
    for (final item in allItems) {
      if (item['variant_id'] == variantId) {
        existingItem = item;
        break;
      }
    }

    print('일치하는 기존 아이템: $existingItem');

    if (existingItem != null) {
      // 기존 아이템 수량 업데이트
      print('기존 아이템 수량 업데이트');
      await _client
          .from('cart_items')
          .update({'quantity': existingItem['quantity'] + quantity})
          .eq('id', existingItem['id']);
    } else {
      // 새 아이템 추가
      print('새 아이템 추가');
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
    
    print('=== addProductToCart 성공 ===');
  } catch (error) {
    print('addProductToCart 에러: $error');
    throw error;
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