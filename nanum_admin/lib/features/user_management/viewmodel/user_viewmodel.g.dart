// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserViewModel)
const userViewModelProvider = UserViewModelProvider._();

final class UserViewModelProvider
    extends $AsyncNotifierProvider<UserViewModel, List<AppUser>> {
  const UserViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userViewModelHash();

  @$internal
  @override
  UserViewModel create() => UserViewModel();
}

String _$userViewModelHash() => r'a2696db7d659248832c1a44c524d36adb6bac161';

abstract class _$UserViewModel extends $AsyncNotifier<List<AppUser>> {
  FutureOr<List<AppUser>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<AppUser>>, List<AppUser>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AppUser>>, List<AppUser>>,
              AsyncValue<List<AppUser>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(UserSearchQuery)
const userSearchQueryProvider = UserSearchQueryProvider._();

final class UserSearchQueryProvider
    extends $NotifierProvider<UserSearchQuery, String> {
  const UserSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSearchQueryHash();

  @$internal
  @override
  UserSearchQuery create() => UserSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$userSearchQueryHash() => r'acf1af1759516cd639f4c469251a1e8a34c6d55e';

abstract class _$UserSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(UserDetail)
const userDetailProvider = UserDetailFamily._();

final class UserDetailProvider
    extends $AsyncNotifierProvider<UserDetail, UserDetailModel> {
  const UserDetailProvider._({
    required UserDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userDetailHash();

  @override
  String toString() {
    return r'userDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserDetail create() => UserDetail();

  @override
  bool operator ==(Object other) {
    return other is UserDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userDetailHash() => r'edaf666cd6e362d225a7b71acbf46dfac569738b';

final class UserDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          UserDetail,
          AsyncValue<UserDetailModel>,
          UserDetailModel,
          FutureOr<UserDetailModel>,
          String
        > {
  const UserDetailFamily._()
    : super(
        retry: null,
        name: r'userDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserDetailProvider call(String userId) =>
      UserDetailProvider._(argument: userId, from: this);

  @override
  String toString() => r'userDetailProvider';
}

abstract class _$UserDetail extends $AsyncNotifier<UserDetailModel> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<UserDetailModel> build(String userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<UserDetailModel>, UserDetailModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserDetailModel>, UserDetailModel>,
              AsyncValue<UserDetailModel>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
