// user_app/lib/features/user/mypage/viewmodel/profile_edit_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../providers/user_provider.dart';

// 프로필 편집 상태 클래스
class ProfileEditState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ProfileEditState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProfileEditState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ProfileEditState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// 프로필 편집 ViewModel
class ProfileEditViewModel extends StateNotifier<ProfileEditState> {
  final ProfileRepository _profileRepository;
  final Ref _ref;

  ProfileEditViewModel(this._profileRepository, this._ref) 
      : super(const ProfileEditState());

  // 프로필 업데이트
  Future<void> updateProfile({
    String? nickname,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? detailAddress,
    String? postcode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    try {
      
      await _profileRepository.updateProfile(
        nickname: nickname,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address:  address,
        postcode: postcode,
      );

      // 사용자 정보 새로고침
      _ref.invalidate(userProvider);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: '프로필 업데이트에 실패했습니다: $e'
      );
    }
  }

  // 레벨 업그레이드 (레벨 1 -> 2)
  Future<void> upgradeToLevel2({
    required String fullName,
    required String phoneNumber,
    required String address,
    required String detailAddress,
    required String postcode,
    String? nickname,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    try {
      // ✅ 우편번호와 주소를 별도로 저장하고 레벨도 업데이트
    await _profileRepository.updateProfileAndLevel(
      nickname: nickname,
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,      // ✅ 기본주소 + 상세주소
      postcode: postcode,    // ✅ 우편번호 별도 저장
      newLevel: 2,           // ✅ 레벨 2로 업데이트
    );

      // 레벨 업데이트는 서버에서 자동으로 처리되거나 별도 API 호출 필요
      // TODO: 레벨 업데이트 API 호출 추가

      // 사용자 정보 새로고침
      _ref.invalidate(userProvider);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: '레벨 업그레이드에 실패했습니다: $e'
      );
    }
  }

  // 상태 초기화
  void clearState() {
    state = const ProfileEditState();
  }
}

// Provider 정의
final profileEditViewModelProvider = 
    StateNotifierProvider<ProfileEditViewModel, ProfileEditState>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return ProfileEditViewModel(profileRepository, ref);
});