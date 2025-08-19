import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/group_buy_model.dart';
import '../models/my_participation_model.dart';

class GroupBuyRepository {
  final SupabaseClient _client;
  GroupBuyRepository(this._client);

  // 공동구매 목록을 가져오는 함수
   // ✅ 새로운 Stream 방식
  Stream<List<GroupBuy>> watchGroupBuys() {
    // 1. .stream()을 사용하여 데이터 변경을 감지하는 Stream을 생성합니다.
    // 2. primaryKey: ['id']는 Supabase가 각 행을 고유하게 식별하는 기준입니다.
    return _client
        .from('group_buys')
        .stream(primaryKey: ['id'])
        // 3. 최신 데이터가 위로 오도록 정렬합니다.
        .order('created_at', ascending: false)
        // 4. Stream이 반환하는 JSON 리스트를 List<GroupBuy>로 변환합니다.
        .map((listOfMaps) =>
            listOfMaps.map((map) => GroupBuy.fromJson(map)).toList());
  }

  // 이미지를 업로드하고 공개 URL을 반환하는 메소드
  Future<String> uploadProductImage({
    required Uint8List imageBytes,
    required String imageName,
    }) async {
    try {
      final fileExt = imageName.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // 💡 .upload() 대신 .uploadBinary()를 사용합니다.
      await _client.storage.from('products').uploadBinary(
            fileName,
            imageBytes,
            // 웹에서 파일 타입을 명시해주는 것이 안정성에 도움이 됩니다.
             fileOptions: FileOptions(contentType: 'image/$fileExt'), // 💡 올바른 contentType
          );
      
      final publicUrl = _client.storage.from('products').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('이미지 업로드 에러: $e');
      rethrow;
    }
  }

  // 새로운 공동구매를 생성하는 메소드 (곧 사용하게 됩니다)
  Future<void> createGroupBuy({
    required int productId,
    required int targetParticipants,
    required DateTime expiresAt,
  }) async {
    // 다음 단계를 위한 임시 코드
  }

  // 💡 공구 개설 메소드를 새로운 RPC 호출 방식으로 완전히 교체합니다.
  Future<void> createNewGroupBuy({
    required String name,
    required int totalPrice,
    required int targetParticipants,
    required String imageUrl,
    String? description,
    int? categoryId,
    String? externalProductId,
  }) async {
    try {
      // 새로 만든 DB 함수를 한 번만 호출하여 상품 생성, 공구 개설, 포인트 지급을 처리합니다.
      await _client.rpc('handle_create_group_buy', params: {
        'p_name': name,
        'p_total_price': totalPrice,
        'p_target_participants': targetParticipants,
        'p_image_url': imageUrl,
        'p_description': description,
        'p_category_id': categoryId,
        'p_external_product_id': externalProductId,
      });
    } catch (e) {
      print('공동구매 생성 에러: $e');
      rethrow;
    }
  }

  // 💡 ID로 단일 상품 정보를 가져옵니다.
  Future<Product> fetchProductById(int id) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', id)
          .single();
      return Product.fromJson(response);
    } catch (e) {
      print('ID로 상품 가져오기 에러 $id: $e');
      rethrow;
    }
  }

  // 💡 공동구매 참여하기 메소드
  Future<void> joinGroupBuy({
    required int groupBuyId, 
    required int quantity
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw Exception('로그인이 필요합니다.');
      
      // 💡 rpc를 이용해 데이터베이스 함수 호출
      await _client.rpc('handle_join_group_buy', params: {
        'p_group_buy_id': groupBuyId,
        'p_user_id': currentUser.id,
        'p_quantity': quantity, // 💡 수량 전달
      });
    } catch (e) {
      print('공동구매 참여 에러: $e');
      rethrow;
    }
  }

  // 💡 특정 공동구매의 참여자 ID 목록을 가져오는 메소드
  Future<List<String>> getParticipantUids(int groupBuyId) async {
    try {
      final response = await _client
          .from('participants')
          .select('user_id')
          .eq('group_buy_id', groupBuyId);
      
      // List<Map<String, dynamic>> 형태를 List<String>으로 변환
      return (response as List).map((e) => e['user_id'] as String).toList();

    } catch(e) {
      print('참여자 목록 가져오기 에러: $e');
      rethrow;
    }
  }

  // 💡 공구 상태를 'failed'로 변경하여 취소 처리
  Future<void> cancelGroupBuy(int groupBuyId) async {
    try {
      await _client
          .from('group_buys')
          .update({'status': 'failed'})
          .eq('id', groupBuyId);
    } catch (e) {
      print('공구 취소 에러: $e');
      rethrow;
    }
  }
  
  // TODO: 수정 기능은 별도의 수정 페이지에서 상세 정보를 받아 처리
  // Future<void> updateGroupBuy(...) async { ... }

   /// 참여 취소 RPC 호출
  Future<void> cancelParticipation(int groupBuyId) async {
    try {
      await _client.rpc('handle_cancel_participation', params: {
        'p_group_buy_id': groupBuyId,
        'p_user_id': _client.auth.currentUser!.id,
      });
    } catch (e) {
      print('참여 취소 에러: $e');
      rethrow;
    }
  }

  /// 수량 변경 RPC 호출
  Future<void> editQuantity(int groupBuyId, int newQuantity) async {
    try {
      await _client.rpc('handle_edit_quantity', params: {
        'p_group_buy_id': groupBuyId,
        'p_user_id': _client.auth.currentUser!.id,
        'p_new_quantity': newQuantity,
      });
    } catch (e) {
      print('수량 변경 에러: $e');
      rethrow;
    }
  }

  // 💡 반환 타입을 List<MyParticipation>으로 변경
  Future<List<MyParticipation>> fetchMyParticipations() async {
    try {
      final userId = _client.auth.currentUser!.id;
      // participants에 join된 group_buys와 그 안의 products까지 모든 정보를 가져옵니다.
      final response = await _client
          .from('participants')
          .select('quantity, group_buys!inner(*, products(*))') // !inner JOIN 사용
          .eq('user_id', userId)
          .order('created_at', referencedTable: 'group_buys', ascending: false);
      
      return (response as List)
          .map((item) => MyParticipation.fromJson(item))
          .toList();
    } catch (e) {
      print('내 참여 목록 조회 에러: $e');
      rethrow;
    }
  }

// 💡 관리자가 등록한 '공구 가능 상품' 목록을 가져오는 함수
  Future<List<Product>> fetchMasterProducts() async {
    final response = await _client.from('products').select().order('created_at', ascending: false);
    return (response as List).map((item) => Product.fromJson(item)).toList();
  }

  // 💡 사용자가 선택한 상품으로 공구를 개설하는 RPC 호출 메소드
  Future<void> createGroupBuyFromMaster({
    required int productId,
    required int targetParticipants,
  }) async {
    // 이 로직을 처리할 새로운 DB 함수 'handle_create_group_buy_from_master'가 필요합니다.
    await _client.rpc('...');
  }

// 💡 공구 목표 수량을 수정하는 메소드
Future<void> updateTargetQuantity({required int groupBuyId, required int newQuantity}) async {
  await _client
      .from('group_buys')
      .update({'target_participants': newQuantity})
      .eq('id', groupBuyId);
       // RLS 정책에 의해 host_id가 일치하는 사용자만 이 쿼리를 실행할 수 있습니다.
}

 // 💡 내가 '개설한' 공구 목록을 가져오는 메소드
  Future<List<GroupBuy>> fetchMyHostedGroupBuys() async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('group_buys')
        .select('*, products(*)') // 개설한 공구와 상품 정보를 함께 가져옴
        .eq('host_id', userId)
        .order('created_at', ascending: false);
    
    return (response as List).map((item) => GroupBuy.fromJson(item)).toList();
  }
  
}

// Riverpod Provider
final groupBuyRepositoryProvider = Provider<GroupBuyRepository>((ref) {
  final client = Supabase.instance.client;
  return GroupBuyRepository(client);
});


