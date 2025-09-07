import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/group_buy_model.dart';

class MypageRepository {
  final SupabaseClient _client;
  MypageRepository(this._client);
  
  // 내가 참여한 공구 목록을 가져오는 메소드
Future<List<GroupBuy>> fetchMyGroupBuys() async {
  try {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('participants')
        .select('*, group_buys(*, products(*))') // participants에 join된 group_buys와 그 안의 products를 가져옴
        .eq('user_id', userId);
    
    final List<dynamic> data = response as List;

    // 💡 .map() 안에서 GroupBuy.fromJson 결과를 return하도록 수정
    return data.map((participantData) {
      // participantData 안에 중첩된 'group_buys' 데이터를 추출합니다.
      final groupBuyData = participantData['group_buys'];
      
      // 데이터가 정상적으로 존재할 경우 GroupBuy 모델로 변환하여 반환합니다.
      if (groupBuyData != null) {
        return GroupBuy.fromJson(groupBuyData);
      }
      
      // 만약 데이터가 비어있다면 null을 반환합니다.
      return null;
    })
    // 💡 whereType을 사용해 리스트에서 null을 모두 제거하고, 타입을 List<GroupBuy>로 확정합니다.
    .whereType<GroupBuy>()
    .toList();

  } catch (e) {
    rethrow;
  }
}

  // 참여 취소 RPC 호출
  Future<void> cancelParticipation(int groupBuyId) async {
    await _client.rpc(
      'handle_cancel_participation',
      params: {
        'p_group_buy_id': groupBuyId,
        'p_user_id': _client.auth.currentUser!.id,
      },
    );
  }

  // 수량 변경 RPC 호출
  Future<void> editQuantity(int groupBuyId, int newQuantity) async {
    await _client.rpc(
      'handle_edit_quantity',
      params: {
        'p_group_buy_id': groupBuyId,
        'p_user_id': _client.auth.currentUser!.id,
        'p_new_quantity': newQuantity,
      },
    );
  }
}
