// nanum_admin/lib/data/models/order_item_cancellation_model.dart

import 'package:flutter/foundation.dart';

class OrderItemCancellation {
  final int id;
  final int orderItemId;
  final int orderId;
  final String userId;
  final String cancelReason;
  final String? cancelDetail;
  final int cancelQuantity;
  final int refundAmount;
  final String status; // 'pending', 'approved', 'rejected'
  final String? adminId;
  final String? adminNote;
  final DateTime? processedAt;
  final DateTime requestedAt;
  final DateTime createdAt;

  // 추가 정보 (조인으로 가져올 데이터)
  final String? productName;
  final String? userName;
  final String? userPhone;
  final int? pricePerItem;

  OrderItemCancellation({
    required this.id,
    required this.orderItemId,
    required this.orderId,
    required this.userId,
    required this.cancelReason,
    this.cancelDetail,
    required this.cancelQuantity,
    required this.refundAmount,
    required this.status,
    this.adminId,
    this.adminNote,
    this.processedAt,
    required this.requestedAt,
    required this.createdAt,
    this.productName,
    this.userName,
    this.userPhone,
    this.pricePerItem,
  });

  factory OrderItemCancellation.fromJson(Map<String, dynamic> json) {
  try {
    // 디버깅 로그 추가
    debugPrint('🔍 Parsing OrderItemCancellation: ${json['id']} for order ${json['order_id']}');
    
    return OrderItemCancellation(
      id: json['id'] as int? ?? 0,
      orderItemId: json['order_item_id'] as int? ?? 0,
      orderId: json['order_id'] as int? ?? 0,
      userId: json['user_id'] as String? ?? '',
      cancelReason: json['cancel_reason'] as String? ?? '',
      cancelDetail: json['cancel_detail'] as String?,
      cancelQuantity: json['cancel_quantity'] as int? ?? 1,
      refundAmount: json['refund_amount'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      adminId: json['admin_id'] as String?,
      adminNote: json['admin_note'] as String?,
      processedAt: json['processed_at'] != null 
          ? DateTime.tryParse(json['processed_at'].toString())
          : null,
      requestedAt: json['requested_at'] != null 
          ? DateTime.tryParse(json['requested_at'].toString()) ?? DateTime.now()
          : (json['created_at'] != null 
              ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      productName: _getNestedValue(json, ['order_items', 'products', 'name']) as String?,
      userName: _getNestedValue(json, ['orders', 'recipient_name']) as String?,
      userPhone: _getNestedValue(json, ['orders', 'recipient_phone']) as String?,
      pricePerItem: _getNestedValue(json, ['order_items', 'price_per_item']) as int?,
    );
  } catch (e) {
    debugPrint('❌ OrderItemCancellation.fromJson error: $e');
    debugPrint('❌ Json data: $json');
    rethrow;
  }
}

  // ✅ 중첩된 객체에서 안전하게 값을 가져오는 헬퍼 메서드
  static dynamic _getNestedValue(Map<String, dynamic> json, List<String> keys) {
    dynamic current = json;
    for (String key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }
}