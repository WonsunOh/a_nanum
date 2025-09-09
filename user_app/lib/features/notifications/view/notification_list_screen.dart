// user_app/lib/features/notifications/view/notification_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/notification_model.dart';
import '../viewmodel/notification_viewmodel.dart';

class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({super.key});

  @override
  ConsumerState<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends ConsumerState<NotificationListScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationViewModelProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          // 읽지 않은 알림 개수 표시
          unreadCountAsync.when(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // 모두 읽음 처리 버튼
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => _markAllAsRead(),
            tooltip: '모두 읽음',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: notificationsAsync.when(
          data: (notifications) => _buildNotificationList(notifications),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorWidget(error),
        ),
      ),
    );
  }

  /// 알림 목록 위젯 구성
  Widget _buildNotificationList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('알림이 없습니다', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  /// 개별 알림 아이템 위젯
  Widget _buildNotificationItem(NotificationModel notification) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _confirmDelete(notification),
      onDismissed: (direction) => _deleteNotification(notification.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification),
          child: Icon(
            _getNotificationIcon(notification),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () => _onNotificationTap(notification),
      ),
    );
  }

  /// 에러 위젯
  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('알림을 불러오는데 실패했습니다\n$error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refresh(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 알림 타입별 아이콘 반환
  IconData _getNotificationIcon(NotificationModel notification) {
    switch (notification.type) {
      case 'order_cancellation':
        return Icons.cancel;
      case 'order_status':
        return Icons.shopping_bag;
      case 'group_buy':
        return Icons.group;
      case 'promotion':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  /// 알림 타입별 색상 반환
  Color _getNotificationColor(NotificationModel notification) {
    switch (notification.type) {
      case 'order_cancellation':
        return Colors.red;
      case 'order_status':
        return Colors.green;
      case 'group_buy':
        return Colors.blue;
      case 'promotion':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// 날짜 시간 포맷팅
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  /// 알림 탭 이벤트
  void _onNotificationTap(NotificationModel notification) {
    // 읽지 않은 알림이면 읽음 처리
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // 알림 타입에 따른 화면 이동
    switch (notification.type) {
      case 'order_cancellation':
        _handleOrderCancellationTap(notification);
        break;
      case 'order_status':
        _navigateToOrderDetail(notification);
        break;
      case 'group_buy':
        _navigateToGroupBuyDetail(notification);
        break;
      default:
        // 기본적으로는 알림 상세나 관련 화면으로 이동
        break;
    }
  }

  /// 주문 취소 알림 처리
  void _handleOrderCancellationTap(NotificationModel notification) {
    final data = notification.data;
    if (data != null) {
      final status = data['status'] as String?;
      final orderId = data['order_id'] as int?;

      if (status == 'rejected' && orderId != null) {
        // 취소 거부 상세 화면으로 이동
        context.push('/notifications/cancellation-rejected/$orderId');
      } else {
        // 일반 주문 상세 화면으로 이동
        _navigateToOrderDetail(notification);
      }
    }
  }

  /// 주문 상세 화면으로 이동
  void _navigateToOrderDetail(NotificationModel notification) {
    final orderId = notification.data?['order_id'];
    if (orderId != null) {
      context.push('/orders/$orderId');
    }
  }

  /// 공구 상세 화면으로 이동
  void _navigateToGroupBuyDetail(NotificationModel notification) {
    final groupBuyId = notification.data?['group_buy_id'];
    if (groupBuyId != null) {
      context.push('/group-buys/$groupBuyId');
    }
  }

  /// 새로고침
  Future<void> _refresh() async {
    await ref.read(notificationViewModelProvider.notifier).refresh();
    ref.invalidate(unreadCountProvider);
  }

  /// 특정 알림 읽음 처리
  Future<void> _markAsRead(int notificationId) async {
    await ref.read(notificationViewModelProvider.notifier).markAsRead(notificationId);
  }

  /// 모든 알림 읽음 처리
  Future<void> _markAllAsRead() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 알림 읽음 처리'),
        content: const Text('모든 알림을 읽음 처리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(notificationViewModelProvider.notifier).markAllAsRead();
    }
  }

  /// 알림 삭제 확인
  Future<bool?> _confirmDelete(NotificationModel notification) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 삭제'),
        content: Text('\'${notification.title}\' 알림을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// 알림 삭제
  Future<void> _deleteNotification(int notificationId) async {
    await ref.read(notificationViewModelProvider.notifier).deleteNotification(notificationId);
  }
}