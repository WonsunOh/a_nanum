// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userViewModelHash() => r'79f73a8a2b1254c46bc95e7528dcfee47c856672';

/// See also [UserViewModel].
@ProviderFor(UserViewModel)
final userViewModelProvider =
    AutoDisposeAsyncNotifierProvider<UserViewModel, List<AppUser>>.internal(
      UserViewModel.new,
      name: r'userViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserViewModel = AutoDisposeAsyncNotifier<List<AppUser>>;
String _$userSearchQueryHash() => r'acf1af1759516cd639f4c469251a1e8a34c6d55e';

/// See also [UserSearchQuery].
@ProviderFor(UserSearchQuery)
final userSearchQueryProvider =
    AutoDisposeNotifierProvider<UserSearchQuery, String>.internal(
      UserSearchQuery.new,
      name: r'userSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserSearchQuery = AutoDisposeNotifier<String>;
String _$userDetailHash() => r'6acd32946c4539e7dfe54904684670da17224ada';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$UserDetail
    extends BuildlessAutoDisposeAsyncNotifier<UserDetailModel> {
  late final String userId;

  FutureOr<UserDetailModel> build(String userId);
}

/// See also [UserDetail].
@ProviderFor(UserDetail)
const userDetailProvider = UserDetailFamily();

/// See also [UserDetail].
class UserDetailFamily extends Family<AsyncValue<UserDetailModel>> {
  /// See also [UserDetail].
  const UserDetailFamily();

  /// See also [UserDetail].
  UserDetailProvider call(String userId) {
    return UserDetailProvider(userId);
  }

  @override
  UserDetailProvider getProviderOverride(
    covariant UserDetailProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userDetailProvider';
}

/// See also [UserDetail].
class UserDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<UserDetail, UserDetailModel> {
  /// See also [UserDetail].
  UserDetailProvider(String userId)
    : this._internal(
        () => UserDetail()..userId = userId,
        from: userDetailProvider,
        name: r'userDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userDetailHash,
        dependencies: UserDetailFamily._dependencies,
        allTransitiveDependencies: UserDetailFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  FutureOr<UserDetailModel> runNotifierBuild(covariant UserDetail notifier) {
    return notifier.build(userId);
  }

  @override
  Override overrideWith(UserDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserDetailProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<UserDetail, UserDetailModel>
  createElement() {
    return _UserDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserDetailProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserDetailRef on AutoDisposeAsyncNotifierProviderRef<UserDetailModel> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<UserDetail, UserDetailModel>
    with UserDetailRef {
  _UserDetailProviderElement(super.provider);

  @override
  String get userId => (origin as UserDetailProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
