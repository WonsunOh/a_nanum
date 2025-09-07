// user_app/lib/data/repositories/wishlist_repository.dart 수정

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wishlist_item_model.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(Supabase.instance.client);
});

class WishlistRepository {
  final SupabaseClient _client;
  WishlistRepository(this._client);

  Future<bool> isProductWishlisted(int productId) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) {
    print('사용자 ID가 null - 찜 상태 확인 불가');
    return false; // ✅ 에러 대신 false 반환 (조회는 로그인 없이도 가능)
  }

  try {
    final response = await _client
        .from('wishlist_items')
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .limit(1);

    final isWishlisted = response.isNotEmpty;
    print('찜 상태 확인 결과: 상품 $productId = $isWishlisted (사용자: $userId)');
    return isWishlisted;
  } catch (e) {
    print('찜 상태 확인 에러: $e');
    return false;
  }
}

  Future<List<WishlistItemModel>> fetchWishlistItems() async {
    final userId = _client.auth.currentUser?.id;
    print('🔍 현재 사용자 ID: $userId');

    if (userId == null) {
      print('❌ 사용자 ID가 null입니다.');
      return [];
    }

    try {
      print('📡 찜 목록 데이터 요청 시작...');

      final response = await _client
          .from('wishlist_items')
          .select('*, products(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('📊 응답 데이터: $response');
      print('📊 응답 길이: ${response.length}');

      if (response.isEmpty) {
        print('📭 찜한 상품이 없습니다.');
        return [];
      }

      final items = response.map((item) {
        print('🔍 개별 아이템: $item');
        return WishlistItemModel.fromJson(item);
      }).toList();

      print('✅ 변환된 찜 목록: ${items.length}개');
      return items;
    } catch (e, stackTrace) {
      print('🚨 찜 목록 조회 에러: $e');
      print('📍 스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  Future<void> addToWishlist(int productId) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('찜하기 기능을 사용하려면 로그인해주세요'); // ✅ 메시지 개선
  }

  print('찜 추가 시작: 사용자 $userId, 상품 $productId');

  try {
    await _client.from('wishlist_items').insert({
      'user_id': userId,
      'product_id': productId,
    });
    print('찜 추가 DB 완료: $productId');
  } catch (e) {
    print('찜 추가 DB 에러: $e');
    rethrow;
  }
}

Future<void> removeFromWishlist(int productId) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('찜하기 기능을 사용하려면 로그인해주세요'); // ✅ 메시지 개선
  }

  print('찜 제거 시작: 사용자 $userId, 상품 $productId');

  try {
    await _client
        .from('wishlist_items')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
    print('찜 제거 DB 완료: $productId');
  } catch (e) {
    print('찜 제거 DB 에러: $e');
    rethrow;
  }
}
}
