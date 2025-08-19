import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/group_buy_repository.dart';

// 💡 폼 컨트롤러들을 위한 Provider들 정의
final nameControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final priceControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final participantsControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final descriptionControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final categoryIdProvider = StateProvider.autoDispose<int?>((ref) => null);
final selectedImageProvider = StateProvider.autoDispose<XFile?>((ref) => null);

final createGroupBuyViewModelProvider = StateNotifierProvider.autoDispose<CreateGroupBuyViewModel, AsyncValue<void>>((ref) {
  return CreateGroupBuyViewModel(ref.read(groupBuyRepositoryProvider));
});

class CreateGroupBuyViewModel extends StateNotifier<AsyncValue<void>> {
  final GroupBuyRepository _repository;
  CreateGroupBuyViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<void> createGroupBuy({
    required String name,
    required int totalPrice,
    required int targetParticipants,
    required XFile image, // View에서는 XFile을 받음
    String? description,
    int? categoryId,
    String? externalProductId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. 이미지 파일을 바이트로 변환
      final imageBytes = await image.readAsBytes();
      // 2. Repository를 통해 이미지를 업로드하고 최종 URL을 받음
      final imageUrl = await _repository.uploadProductImage(
        imageBytes: imageBytes,
        imageName: image.name,
      );
      // 3. 업로드된 최종 URL을 사용하여 DB에 공구 정보 생성 요청
      await _repository.createNewGroupBuy(
        name: name,
        totalPrice: totalPrice,
        targetParticipants: targetParticipants,
        imageUrl: imageUrl, // 💡 최종 URL 전달
        description: description,
        categoryId: categoryId,
        externalProductId: externalProductId,
      );
    });
  }
}