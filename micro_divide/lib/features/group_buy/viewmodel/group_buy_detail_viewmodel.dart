import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/group_buy_repository.dart';

final quantityProvider = StateProvider.autoDispose<int>((ref) => 1);

final groupBuyDetailViewModelProvider = StateNotifierProvider.autoDispose<GroupBuyDetailViewModel, AsyncValue<void>>((ref) {
  return GroupBuyDetailViewModel(ref.read(groupBuyRepositoryProvider));
});

class GroupBuyDetailViewModel extends StateNotifier<AsyncValue<void>> {
  final GroupBuyRepository _repository;
  
  GroupBuyDetailViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<void> createGroupBuy({
    required String name,
    required int totalPrice,
    required int targetParticipants,
    required XFile image,
    String? description,
    int? categoryId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final imageBytes = await image.readAsBytes();
      final imageUrl = await _repository.uploadProductImage(imageBytes: imageBytes, imageName: image.name);
      
      await _repository.createNewGroupBuy(
        name: name,
        totalPrice: totalPrice,
        targetParticipants: targetParticipants,
        imageUrl: imageUrl,
        description: description,
        categoryId: categoryId,
      );
    });
  }

  Future<void> joinGroupBuy({
    required int groupBuyId, 
    required int quantity
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.joinGroupBuy(
      groupBuyId: groupBuyId,
      quantity: quantity,
    ));
  }

  // 💡 공구 취소 메소드 추가
  Future<void> cancelGroupBuy(int groupBuyId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.cancelGroupBuy(groupBuyId));
  }

  // 💡 목표 수량 수정 메소드
  Future<void> updateTargetQuantity({required int groupBuyId, required int newQuantity}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateTargetQuantity(
      groupBuyId: groupBuyId,
      newQuantity: newQuantity,
    ));
  }
}

// 💡 현재 사용자가 특정 공구에 참여했는지 여부를 확인하는 Provider
// .family를 사용하면 Provider에 파라미터(groupBuyId)를 전달할 수 있습니다.
final hasJoinedProvider = FutureProvider.autoDispose.family<bool, int>((ref, groupBuyId) async {
  final repository = ref.watch(groupBuyRepositoryProvider);
  final currentUser = Supabase.instance.client.auth.currentUser;

  if (currentUser == null) {
    return false; // 로그인 안 했으면 참여 안 한 것
  }

  // 1. 해당 공구의 전체 참여자 uid 목록을 가져옵니다.
  final participantUids = await repository.getParticipantUids(groupBuyId);
  
  // 2. 그 목록에 현재 내 uid가 포함되어 있는지 확인합니다.
  return participantUids.contains(currentUser.id);
});