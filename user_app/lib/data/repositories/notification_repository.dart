// user_app/lib/data/repositories/notification_repository.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

part 'notification_repository.g.dart';

@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  return NotificationRepository();
}

class NotificationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// 사용자의 모든 알림을 최신 순으로 가져옵니다
  // user_app/lib/data/repositories/notification_repository.dart
Future<List<NotificationModel>> fetchNotifications() async {
  try {
    print('🔍 알림 조회 시작 - 사용자 ID: ${_client.auth.currentUser?.id}');
    
    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', _client.auth.currentUser!.id)
        .order('created_at', ascending: false);

    print('📦 알림 조회 결과: $response');
    print('📊 알림 개수: ${(response as List).length}');

    final notifications = (response as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
        
    print('✅ 알림 파싱 완료: ${notifications.length}개');
    return notifications;
  } catch (e) {
    print('❌ 알림 조회 에러: $e');
    throw Exception('알림 목록을 불러오는데 실패했습니다: $e');
  }
}

  /// 읽지 않은 알림만 가져옵니다
  Future<List<NotificationModel>> fetchUnreadNotifications() async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', _client.auth.currentUser!.id)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('읽지 않은 알림을 불러오는데 실패했습니다: $e');
    }
  }

  /// 특정 알림을 읽음 처리합니다
  Future<void> markAsRead(int notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (e) {
      throw Exception('알림 읽음 처리에 실패했습니다: $e');
    }
  }

  /// 모든 알림을 읽음 처리합니다
  Future<void> markAllAsRead() async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _client.auth.currentUser!.id)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('모든 알림 읽음 처리에 실패했습니다: $e');
    }
  }

  /// 특정 알림을 삭제합니다
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (e) {
      throw Exception('알림 삭제에 실패했습니다: $e');
    }
  }

  /// 읽지 않은 알림 개수를 가져옵니다
  Future<int> getUnreadCount() async {
    try {
      final response = await _client
    .from('notifications')
    .select('id')
    .eq('user_id', _client.auth.currentUser!.id)
    .eq('is_read', false);

return (response as List).length;
    } catch (e) {
      throw Exception('읽지 않은 알림 개수를 불러오는데 실패했습니다: $e');
    }
  }

  /// 실시간 알림 구독
  Stream<NotificationModel> subscribeToNotifications() {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _client.auth.currentUser!.id)
        .map((data) {
          if (data.isNotEmpty) {
            return NotificationModel.fromJson(data.first);
          }
          throw Exception('알림 데이터가 비어있습니다');
        });
  }

  /// 취소 거부 알림에서 주문 취소 재요청
  Future<void> resubmitCancellationRequest(int orderId, String reason) async {
    try {
      // order_cancellations 테이블에 새로운 취소 요청 삽입
      await _client.from('order_cancellations').insert({
        'order_id': orderId,
        'user_id': _client.auth.currentUser!.id,
        'reason': reason,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('취소 재요청에 실패했습니다: $e');
    }
  }
}