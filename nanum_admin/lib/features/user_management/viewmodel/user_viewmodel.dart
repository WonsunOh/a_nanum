import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/app_user_model.dart';
import '../../../data/models/user_detail_model.dart';
import '../../../data/repositories/user_repository.dart';

// 검색어를 관리하는 Provider (기존 코드 유지)
final userSearchQueryProvider = StateNotifierProvider<UserSearchQueryNotifier, String>((ref) {
  return UserSearchQueryNotifier();
});

class UserSearchQueryNotifier extends StateNotifier<String> {
  UserSearchQueryNotifier() : super('');
  void setSearchQuery(String query) {
    state = query;
  }
}


// 💡 FutureProvider를 StateNotifierProvider로 변경합니다.
//    데이터 조회와 상태 변경(레벨 수정)을 모두 처리합니다.
final userViewModelProvider = StateNotifierProvider.autoDispose<UserViewModel, AsyncValue<List<AppUser>>>((ref) {
  return UserViewModel(ref);
});

class UserViewModel extends StateNotifier<AsyncValue<List<AppUser>>> {
  final Ref _ref;
  late final UserRepository _repository;
  
  UserViewModel(this._ref) : super(const AsyncValue.loading()) {
    _repository = _ref.read(userRepositoryProvider);
    // 검색어가 변경될 때마다 데이터를 다시 불러옵니다.
    _ref.listen(userSearchQueryProvider, (_, __) => fetchAllUsers());
    fetchAllUsers(); // 초기 데이터 로드
  }

  Future<void> fetchAllUsers() async {
    state = const AsyncValue.loading();
    final searchQuery = _ref.read(userSearchQueryProvider);
    state = await AsyncValue.guard(() => _repository.fetchAllUsers(searchQuery: searchQuery));
  }

  // 레벨 수정 메소드
  Future<void> updateUserLevel(String userId, int newLevel) async {
    // UI에서 즉각적인 로딩 피드백을 원하면 아래 한 줄을 추가할 수 있습니다.
    // state = const AsyncValue.loading(); 
    await _repository.updateUserLevel(userId, newLevel);
    await fetchAllUsers(); // 성공 후 목록 새로고침
  }
}


// 특정 사용자의 상세 정보를 가져오는 Provider (기존 코드 유지)
final userDetailProvider = FutureProvider.autoDispose.family<UserDetail, String>((ref, userId) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.fetchUserDetails(userId);
});