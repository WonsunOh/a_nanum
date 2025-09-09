// user_app/lib/data/models/notification_model.dart

class NotificationModel {
  final int id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // 읽음 상태로 변경된 새로운 인스턴스 반환
  NotificationModel copyWith({
    int? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 알림 타입별 아이콘 반환
  String get iconName {
    switch (type) {
      case 'order_cancellation':
        return 'cancel';
      case 'order_status':
        return 'shopping_bag';
      case 'group_buy':
        return 'group';
      case 'promotion':
        return 'local_offer';
      default:
        return 'notifications';
    }
  }

  // 알림 타입별 색상 반환
  String get colorType {
    switch (type) {
      case 'order_cancellation':
        return 'error';
      case 'order_status':
        return 'success';
      case 'group_buy':
        return 'info';
      case 'promotion':
        return 'warning';
      default:
        return 'default';
    }
  }
}