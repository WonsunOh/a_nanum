import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/app_user_model.dart';
import '../../../data/models/user_detail_model.dart';
import '../../../data/repositories/user_repository.dart';

part 'user_viewmodel.g.dart';

// ⭐️ 1. StateNotifierProvider 대신 AsyncNotifierProvider를 사용하도록 변경합니다.
@riverpod
class UserViewModel extends _$UserViewModel {
  late final UserRepository _repository;

  // ⭐️ 2. build 메서드는 Provider가 처음 호출될 때 한 번만 실행됩니다.
  // 여기서 비동기 데이터 로딩을 하고 그 결과를 반환하면 됩니다.
  // 더 이상 생성자에서 데이터를 불러올 필요가 없습니다.
  @override
  Future<List<AppUser>> build() async {
    _repository = ref.read(userRepositoryProvider);
    
    // ⭐️ 3. 검색어 Provider를 감시(watch)합니다.
    // 검색어가 변경되면 이 build 메서드가 자동으로 다시 실행되어 데이터를 새로고침합니다.
    final searchQuery = ref.watch(userSearchQueryProvider);
    
    // 초기 데이터 로딩
    return _repository.fetchAllUsers(searchQuery: searchQuery);
  }

  // ⭐️ 4. 데이터 갱신이 필요한 다른 함수들은 그대로 유지합니다.
  // 상태를 직접 관리하는 대신, ref.invalidateSelf()를 호출하여
  // build 메서드를 다시 실행하게 만드는 것이 핵심입니다.
  Future<void> updateUserLevel(String userId, int newLevel) async {
    state = const AsyncValue.loading(); // 로딩 상태로 변경
    state = await AsyncValue.guard(() async {
      await _repository.updateUserLevel(userId, newLevel);
      // 데이터 갱신 후, Provider를 무효화시켜서 build를 다시 실행하게 합니다.
      ref.invalidateSelf(); 
      return future; // 이전 상태의 데이터를 잠시 유지
    });
  }
}

// ⭐️ 검색어를 위한 간단한 StateProvider는 그대로 사용합니다.
@riverpod
class UserSearchQuery extends _$UserSearchQuery {
  @override
  String build() => '';

  void setSearchQuery(String query) {
    state = query;
  }
}
@riverpod
class UserDetail extends _$UserDetail {
  late final UserRepository _repository;

  // build 메서드에 userId를 인자로 받습니다.
 @override
  Future<UserDetailModel> build(String userId) async {
    _repository = ref.read(userRepositoryProvider);
    return _repository.fetchUserDetails(userId);
  }
}