// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadNotificationsHash() =>
    r'4a2f031e3f1b82d8681fa9adff56364e941827d3';

/// 읽지 않은 알림만 가져오는 Provider
///
/// Copied from [unreadNotifications].
@ProviderFor(unreadNotifications)
final unreadNotificationsProvider =
    AutoDisposeFutureProvider<List<NotificationModel>>.internal(
      unreadNotifications,
      name: r'unreadNotificationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unreadNotificationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadNotificationsRef =
    AutoDisposeFutureProviderRef<List<NotificationModel>>;
String _$unreadCountHash() => r'b82a0fad18604d8541f622b5915c61e0b622aa52';

/// 읽지 않은 알림 개수를 가져오는 Provider
///
/// Copied from [unreadCount].
@ProviderFor(unreadCount)
final unreadCountProvider = AutoDisposeFutureProvider<int>.internal(
  unreadCount,
  name: r'unreadCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadCountRef = AutoDisposeFutureProviderRef<int>;
String _$notificationStreamHash() =>
    r'd9a6f6a8465a92b993d67641260a1e656ef6a38e';

/// 실시간 알림 구독 Provider
///
/// Copied from [notificationStream].
@ProviderFor(notificationStream)
final notificationStreamProvider =
    AutoDisposeStreamProvider<NotificationModel>.internal(
      notificationStream,
      name: r'notificationStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationStreamRef = AutoDisposeStreamProviderRef<NotificationModel>;
String _$notificationViewModelHash() =>
    r'2fff21a72239bfc1d1f77aa253466b57a94c1dc8';

/// 모든 알림 목록을 관리하는 ViewModel
///
/// Copied from [NotificationViewModel].
@ProviderFor(NotificationViewModel)
final notificationViewModelProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationViewModel,
      List<NotificationModel>
    >.internal(
      NotificationViewModel.new,
      name: r'notificationViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationViewModel =
    AutoDisposeAsyncNotifier<List<NotificationModel>>;
String _$cancellationResubmitHash() =>
    r'bb0b3887787ac9e73b2192964f89a89d0336e381';

/// 취소 재요청을 처리하는 Provider
///
/// Copied from [CancellationResubmit].
@ProviderFor(CancellationResubmit)
final cancellationResubmitProvider =
    AutoDisposeAsyncNotifierProvider<CancellationResubmit, void>.internal(
      CancellationResubmit.new,
      name: r'cancellationResubmitProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cancellationResubmitHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CancellationResubmit = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
