// File: nanum_admin/lib/data/models/order_model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ✅ OrderStatus Enum 재정의
enum OrderStatus {
  confirmed,        // 결제완료
  preparing,        // 상품준비중
  shipping,         // 배송중
  delivered,        // 배송완료
  purchaseConfirmed,// 구매확정
  exchangeReturn,   // 교환/반품
  cancellationRequested, // 취소요청
  cancelled;        // 주문취소

  String get displayName {
    switch (this) {
      case OrderStatus.confirmed: return '결제완료';
      case OrderStatus.preparing: return '상품준비중';
      case OrderStatus.shipping: return '배송중';
      case OrderStatus.delivered: return '배송완료';
      case OrderStatus.purchaseConfirmed: return '구매확정';
      case OrderStatus.exchangeReturn: return '교환/반품';
      case OrderStatus.cancellationRequested: return '취소요청';
      case OrderStatus.cancelled: return '주문취소';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.confirmed: return Colors.blue;
      case OrderStatus.preparing: return Colors.orange;
      case OrderStatus.shipping: return Colors.teal;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.purchaseConfirmed: return Colors.purple;
      case OrderStatus.exchangeReturn: return Colors.grey;
      case OrderStatus.cancellationRequested: return Colors.amber;
      case OrderStatus.cancelled: return Colors.red;
    }
  }
}

class OrderModel {
  final String orderId;
  final DateTime orderDate;
  final String userId;
  final String userName; // 주문자 정보 (필요 시 사용)
  final String recipientName; // 받는 사람 이름
  final String userEmail;
  final int totalAmount;
  final OrderStatus status;
  final String shippingAddress;
  final String recipientPhone;
  final List<OrderItem> items;
  final String orderType;
  final String? trackingNumber; // ✅ 추가
  final String? courierCompany; // ✅ 추가 (택배사)

  OrderModel({
    required this.orderId,
    required this.orderDate,
    required this.userId,
    required this.userName,
    required this.recipientName,
    required this.userEmail,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.recipientPhone,
    required this.items,
    required this.orderType,
    this.trackingNumber, // ✅ 추가
    this.courierCompany, // ✅ 추가
  });

  OrderModel copyWith({
    String? orderId,
    DateTime? orderDate,
    String? userId,
    String? userName,
    String? recipientName,
    String? userEmail,
    int? totalAmount,
    OrderStatus? status,
    String? shippingAddress,
    String? recipientPhone,
    List<OrderItem>? items,
    String? orderType,
    String? trackingNumber, // ✅ 추가
    String? courierCompany, // ✅ 추가
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      orderDate: orderDate ?? this.orderDate,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      recipientName: recipientName ?? this.recipientName,
      userEmail: userEmail ?? this.userEmail,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      items: items ?? this.items,
      orderType: orderType ?? this.orderType,
      trackingNumber: trackingNumber ?? this.trackingNumber, // ✅ 추가
      courierCompany: courierCompany ?? this.courierCompany, // ✅ 추가
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final statusString = json['status'] as String? ?? 'confirmed';
    final status = OrderStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => OrderStatus.confirmed,
    );
    
    final userData = json['users'];

    return OrderModel(
      orderId: json['order_number'] as String? ?? '', // 🔥🔥🔥 타입 캐스팅 추가
      orderDate: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(), // 🔥🔥🔥 tryParse로 변경
      userId: json['user_id'] as String? ?? '',
      userName: userData?['username'] as String? ?? '알 수 없음',
      recipientName: json['recipient_name'] as String? ?? '알 수 없음',
      userEmail: userData?['email'] as String? ?? '알 수 없음',
      totalAmount: json['total_amount'] ?? 0,
      status: status,
      shippingAddress: json['shipping_address'] as String? ?? '',
      recipientPhone: json['recipient_phone'] as String? ?? '',
      items: (json['order_items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ?? [],
      orderType: json['order_type'] as String? ?? 'shop',
      trackingNumber: json['tracking_number'] as String?, // ✅ 추가
      courierCompany: json['courier_company'] as String?, // ✅ 추가
    );
  }

  String get formattedOrderDate => DateFormat('yyyy-MM-dd HH:mm').format(orderDate);
  String get formattedTotalAmount => NumberFormat('#,###').format(totalAmount);
}

class OrderItem {
  final String productName;
  final int quantity;
  final int price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // 🔥🔥🔥 수정: productData가 null일 경우를 대비하여 안정성 강화
    final productData = json['products'] as Map<String, dynamic>?;
    return OrderItem(
      productName: productData?['name'] as String? ?? '상품 정보 없음', // String으로 캐스팅 및 null 처리
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
    );
  }
}

