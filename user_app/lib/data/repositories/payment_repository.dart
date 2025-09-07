// user_app/lib/data/repositories/payment_repository.dart에 추가

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/group_buy_model.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final SupabaseClient _client;
  PaymentRepository(this._client);

  /// 기존 구조에 맞춘 결제 생성
  Future<int> createPayment({
    required int orderId,
    required int amount,
    required String paymentKey, // merchant_uid 역할
    String method = 'card',
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      
      final response = await _client.from('payments').insert({
        'payment_key': paymentKey,
        'order_id': orderId,
        'user_id': userId,
        'amount': amount,
        'status': 'pending',
        'method': method,
        'payment_type': 'payment',
      }).select().single();

      return response['id'];
    } catch (e) {
      print('❌ 결제 생성 에러: $e');
      rethrow;
    }
  }

   /// 결제 완료 처리
  Future<void> completePayment({
    required String paymentKey,
    Map<String, dynamic>? rawData,
  }) async {
    try {
      await _client.from('payments').update({
        'status': 'completed',
        'approved_at': DateTime.now().toIso8601String(),
        'raw_data': rawData,
      }).eq('payment_key', paymentKey);

      print('✅ 결제 완료 처리: $paymentKey');
    } catch (e) {
      print('❌ 결제 완료 처리 에러: $e');
      rethrow;
    }
  }


  /// 전체 환불 처리
  Future<int> createFullRefund({
    required int orderId,
    required int originalPaymentId,
    required int refundAmount,
    String? reason,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final refundKey = 'refund_${DateTime.now().millisecondsSinceEpoch}';
      
      final response = await _client.from('payments').insert({
        'payment_key': refundKey,
        'order_id': orderId,
        'user_id': userId,
        'parent_payment_id': originalPaymentId,
        'amount': -refundAmount, // 음수로 저장
        'status': 'completed',
        'method': 'refund',
        'payment_type': 'refund',
        'approved_at': DateTime.now().toIso8601String(),
        'memo': reason,
      }).select().single();

      // 주문 상태를 환불로 변경
      await _client.from('orders').update({
        'status': 'refunded'
      }).eq('id', orderId);

      return response['id'];
    } catch (e) {
      print('❌ 환불 처리 에러: $e');
      rethrow;
    }
  }

  /// 부분 환불 처리
  Future<int> createPartialRefund({
  required int orderId,
  required int originalPaymentId,
  required int refundAmount,
  required List<int> refundItemIds,
  String? reason,
}) async {
  try {
    final userId = _client.auth.currentUser?.id;
    final refundKey = 'partial_refund_${DateTime.now().millisecondsSinceEpoch}';
    
    final response = await _client.from('payments').insert({
      'payment_key': refundKey,
      'order_id': orderId,
      'user_id': userId,
      'parent_payment_id': originalPaymentId,
      'amount': -refundAmount,
      'status': 'completed',
      'method': 'partial_refund',
      'payment_type': 'partial_refund',
      'approved_at': DateTime.now().toIso8601String(),
      'memo': reason,
    }).select().single();

    // ✅ inFilter() 사용 또는 filter() 사용
    if (refundItemIds.isNotEmpty) {
      await _client.from('order_items').update({
        'status': 'refunded'
      }).inFilter('id', refundItemIds);
    }

    return response['id'];
  } catch (e) {
    print('❌ 부분환불 처리 에러: $e');
    rethrow;
  }
}

  /// 주문의 결제 내역 조회
  Future<List<Map<String, dynamic>>> getOrderPaymentHistory(int orderId) async {
    try {
      final response = await _client
          .from('payments')
          .select('*')
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ 결제내역 조회 에러: $e');
      rethrow;
    }
  }

  /// 환불 가능 금액 계산
  Future<int> getRefundableAmount(int orderId) async {
    try {
      final payments = await getOrderPaymentHistory(orderId);
      
      int totalPaid = 0;
      int totalRefunded = 0;

      for (final payment in payments) {
        if (payment['status'] == 'completed') {
          final amount = payment['amount'] as int;
          final paymentType = payment['payment_type'] as String?;
          
          if (paymentType == 'payment' || paymentType == null) {
            totalPaid += amount;
          } else if (paymentType == 'refund' || paymentType == 'partial_refund') {
            totalRefunded += amount.abs();
          }
        }
      }

      return totalPaid - totalRefunded;
    } catch (e) {
      print('❌ 환불가능금액 계산 에러: $e');
      return 0;
    }
  }
  /// 내 결제 내역 조회 (공동구매용)
  Future<List<PaymentModel>> fetchMyPayments() async {
    try {
      final userId = _client.auth.currentUser!.id;
      final response = await _client
          .from('participants')
          .select('*, group_buys(*, products(*))')
          .eq('user_id', userId)
          .not('merchant_uid', 'is', null)
          .order('joined_at', ascending: false);

      return (response as List)
          .map((json) => PaymentModel.fromParticipant(json))
          .toList();
    } catch (e) {
      print('결제 내역 조회 에러: $e');
      rethrow;
    }
  }

  /// 결제 준비 (공동구매용)
  Future<PaymentRequest> preparePayment({
    required int groupBuyId,
    required int quantity,
    required GroupBuy groupBuy,
  }) async {
    try {
      final user = _client.auth.currentUser!;
      final uuid = const Uuid();
      final merchantUid = 'GB_${groupBuyId}_${user.id.substring(0, 8)}_${uuid.v4().substring(0, 8)}';
      
      final product = groupBuy.product;
      if (product == null) {
        throw Exception('상품 정보가 없습니다.');
      }
      
      final singlePrice = (product.totalPrice / groupBuy.targetParticipants / 100).ceil() * 100;
      final shippingFee = 3000;
      final totalAmount = (singlePrice * quantity) + shippingFee;

      await _client
          .from('participants')
          .update({
            'merchant_uid': merchantUid,
            'payment_amount': totalAmount,
          })
          .eq('group_buy_id', groupBuyId)
          .eq('user_id', user.id);

      return PaymentRequest(
        merchantUid: merchantUid,
        name: '${product.name} (${quantity}개)',
        amount: totalAmount,
        buyerEmail: user.email!,
        buyerName: user.userMetadata?['full_name'] ?? '구매자',
        buyerTel: user.userMetadata?['phone'] ?? '',
        customData: {
          'group_buy_id': groupBuyId,
          'quantity': quantity,
        },
      );
    } catch (e) {
      print('결제 준비 에러: $e');
      rethrow;
    }
  }

  /// 결제 성공 처리 (공동구매용)
  Future<void> handlePaymentSuccess({
    required String merchantUid,
    required String impUid,
    required int amount,
    required String paymentMethod,
  }) async {
    try {
      await _client.rpc('handle_payment_success', params: {
        'p_merchant_uid': merchantUid,
        'p_imp_uid': impUid,
        'p_amount': amount,
        'p_payment_method': paymentMethod,
      });
    } catch (e) {
      print('결제 성공 처리 에러: $e');
      rethrow;
    }
  }

  /// 결제 취소 처리 (공동구매용)
  Future<void> handlePaymentCancel(String merchantUid) async {
    try {
      await _client.rpc('handle_payment_cancel', params: {
        'p_merchant_uid': merchantUid,
      });
    } catch (e) {
      print('결제 취소 처리 에러: $e');
      rethrow;
    }
  }

  /// 특정 결제 정보 조회
  Future<PaymentModel?> getPaymentByMerchantUid(String merchantUid) async {
    try {
      final response = await _client
          .from('participants')
          .select('*, group_buys(*, products(*))')
          .eq('merchant_uid', merchantUid)
          .single();
      
      return PaymentModel.fromParticipant(response);
    } catch (e) {
      print('결제 정보 조회 에러: $e');
      return null;
    }
  }

  // ... 앞서 작성한 환불 관련 메서드들 ...
}

// PaymentRepository Provider 추가
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(Supabase.instance.client);
});
