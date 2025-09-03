// user_app/lib/data/models/payment_model.dart

import 'package:flutter/material.dart';

class PaymentModel {
  final int id;                    // participants.id
  final int groupBuyId;           // participants.group_buy_id 
  final String userId;            // participants.user_id
  final String merchantUid;       // participants.merchant_uid
  final String? impUid;           // participants.imp_uid
  final int amount;               // participants.payment_amount
  final String? paymentMethod;    // participants.payment_method
  final String status;            // participants.payment_status
  final DateTime? paidAt;         // participants.paid_at
  final DateTime createdAt;       // participants.joined_at
  final String? productName;      // 조인된 상품명
  final String? productImageUrl;  // 조인된 상품 이미지

  PaymentModel({
    required this.id,
    required this.groupBuyId,
    required this.userId,
    required this.merchantUid,
    this.impUid,
    required this.amount,
    this.paymentMethod,
    required this.status,
    this.paidAt,
    required this.createdAt,
    this.productName,
    this.productImageUrl,
  });

  // ✅ participants 테이블과 조인된 데이터에서 생성
  factory PaymentModel.fromParticipant(Map<String, dynamic> json) {
    final groupBuy = json['group_buys'] as Map<String, dynamic>?;
    final product = groupBuy?['products'] as Map<String, dynamic>?;
    
    return PaymentModel(
      id: json['id'] as int,                                    // participants.id
      groupBuyId: json['group_buy_id'] as int,                 // participants.group_buy_id
      userId: json['user_id'] as String,                       // participants.user_id
      merchantUid: json['merchant_uid'] as String? ?? '',      // participants.merchant_uid
      impUid: json['imp_uid'] as String?,                      // participants.imp_uid
      amount: json['payment_amount'] as int? ?? 0,             // participants.payment_amount
      paymentMethod: json['payment_method'] as String?,        // participants.payment_method
      status: json['payment_status'] as String? ?? 'pending',  // participants.payment_status
      paidAt: json['paid_at'] != null 
        ? DateTime.parse(json['paid_at'] as String) 
        : null,                                                // participants.paid_at
      createdAt: DateTime.parse(json['joined_at'] as String),  // participants.joined_at
      productName: product?['name'] as String?,                // products.name (조인)
      productImageUrl: product?['image_url'] as String?,       // products.image_url (조인)
    );
  }

  // 결제 상태별 표시용 텍스트
  String get statusText {
    switch (status) {
      case 'pending':
        return '결제 대기';
      case 'paid':
        return '결제 완료';
      case 'cancelled':
        return '결제 취소';
      case 'failed':
        return '결제 실패';
      default:
        return '알 수 없음';
    }
  }

  // 결제 상태별 색상
  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// 결제 요청 데이터 모델 (participant_id 제거)
class PaymentRequest {
  final String merchantUid;
  final String name;           
  final int amount;           
  final String buyerEmail;    
  final String buyerName;     
  final String? buyerTel;     
  final Map<String, dynamic>? customData;

  PaymentRequest({
    required this.merchantUid,
    required this.name,
    required this.amount,
    required this.buyerEmail,
    required this.buyerName,
    this.buyerTel,
    this.customData,
  });

  Map<String, dynamic> toJson() {
    return {
      'merchant_uid': merchantUid,
      'name': name,
      'amount': amount,
      'buyer_email': buyerEmail,
      'buyer_name': buyerName,
      'buyer_tel': buyerTel,
      'custom_data': customData,
    };
  }
}