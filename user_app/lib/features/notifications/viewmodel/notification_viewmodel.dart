// user_app/lib/features/notifications/viewmodel/notification_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

part 'notification_viewmodel.g.dart';

/// 모든 알림 목록을 관리하는 ViewModel
@riverpod
class NotificationViewModel extends _$NotificationViewModel {
  NotificationRepository get _repository => ref.read(notificationRepositoryProvider);

  @override
  Future<List<NotificationModel>> build() async {
    // 초기 데이터 로딩
    return _repository.fetchNotifications();
  }

  /// 알림 목록 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchNotifications());
  }

  /// 특정 알림을 읽음 처리
  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      
      // 상태 업데이트: 해당 알림의 isRead를 true로 변경
      final currentNotifications = state.value;
      if (currentNotifications != null) {
        final updatedNotifications = currentNotifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        
        state = AsyncValue.data(updatedNotifications);
      }
      
      // 읽지 않은 알림 개수도 업데이트
      ref.invalidate(unreadCountProvider);
    } catch (e) {
      // 에러 발생 시 전체 목록 새로고침
      await refresh();
    }
  }

  /// 모든 알림을 읽음 처리
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      
      // 상태 업데이트: 모든 알림의 isRead를 true로 변경
      final currentNotifications = state.value;
      if (currentNotifications != null) {
        final updatedNotifications = currentNotifications
            .map((notification) => notification.copyWith(isRead: true))
            .toList();
        
        state = AsyncValue.data(updatedNotifications);
      }
      
      // 읽지 않은 알림 개수도 업데이트
      ref.invalidate(unreadCountProvider);
    } catch (e) {
      // 에러 발생 시 전체 목록 새로고침
      await refresh();
    }
  }

  /// 특정 알림 삭제
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      
      // 상태 업데이트: 해당 알림을 목록에서 제거
      final currentNotifications = state.value;
      if (currentNotifications != null) {
        final updatedNotifications = currentNotifications
            .where((notification) => notification.id != notificationId)
            .toList();
        
        state = AsyncValue.data(updatedNotifications);
      }
      
      // 읽지 않은 알림 개수도 업데이트
      ref.invalidate(unreadCountProvider);
    } catch (e) {
      // 에러 발생 시 전체 목록 새로고침
      await refresh();
    }
  }
}

/// 읽지 않은 알림만 가져오는 Provider
@riverpod
Future<List<NotificationModel>> unreadNotifications(UnreadNotificationsRef ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.fetchUnreadNotifications();
}

/// 읽지 않은 알림 개수를 가져오는 Provider
@riverpod
Future<int> unreadCount(UnreadCountRef ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount();
}

/// 실시간 알림 구독 Provider
@riverpod
Stream<NotificationModel> notificationStream(NotificationStreamRef ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.subscribeToNotifications();
}

/// 취소 재요청을 처리하는 Provider
@riverpod
class CancellationResubmit extends _$CancellationResubmit {
  NotificationRepository get _repository => ref.read(notificationRepositoryProvider);

  @override
  Future<void> build() async {
    // 초기 상태는 아무것도 하지 않음
  }

  /// 주문 취소 재요청
  Future<bool> resubmitCancellation(int orderId, String reason) async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.resubmitCancellationRequest(orderId, reason);
      state = const AsyncValue.data(null);
      
      // 알림 목록 새로고침
      ref.invalidate(notificationViewModelProvider);
      
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}