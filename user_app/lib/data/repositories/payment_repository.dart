// user_app/lib/data/repositories/payment_repository.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/payment_model.dart';
import '../models/group_buy_model.dart';

class PaymentRepository {
  final SupabaseClient _client;
  PaymentRepository(this._client);

  // 결제 준비: merchant_uid 생성 및 참여 정보 업데이트
  Future<PaymentRequest> preparePayment({
    required int groupBuyId,
    required int quantity,
    required GroupBuy groupBuy,
  }) async {
    try {
      final user = _client.auth.currentUser!;
      final uuid = const Uuid();
      final merchantUid = 'GB_${groupBuyId}_${user.id.substring(0, 8)}_${uuid.v4().substring(0, 8)}';
      
      // ✅ Product 모델의 실제 필드 사용 + null 체크
      final product = groupBuy.product;
      if (product == null) {
        throw Exception('상품 정보가 없습니다.');
      }
      
      // ✅ totalPrice 사용하여 개당 가격 계산
      final singlePrice = (product.totalPrice / groupBuy.targetParticipants / 100).ceil() * 100;
      final shippingFee = 3000; // 기본 배송비 (Product 모델에 shippingFee 필드가 없으므로)
      final totalAmount = (singlePrice * quantity) + shippingFee;

      // 기존 참여 정보에 merchant_uid와 payment_amount 추가
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
      debugPrint('결제 준비 에러: $e');
      rethrow;
    }
  }

  // 결제 성공 처리
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
      debugPrint('결제 성공 처리 에러: $e');
      rethrow;
    }
  }

  // 결제 취소 처리
  Future<void> handlePaymentCancel(String merchantUid) async {
    try {
      await _client.rpc('handle_payment_cancel', params: {
        'p_merchant_uid': merchantUid,
      });
    } catch (e) {
      debugPrint('결제 취소 처리 에러: $e');
      rethrow;
    }
  }

  // 내 결제 내역 조회
  Future<List<PaymentModel>> fetchMyPayments() async {
    try {
      final userId = _client.auth.currentUser!.id;
      final response = await _client
          .from('participants')
          .select('*, group_buys(*, products(*))')
          .eq('user_id', userId)
          .not('merchant_uid', 'is', null) // merchant_uid가 있는 것만 (결제 진행한 것만)
          .order('joined_at', ascending: false);

      return (response as List)
          .map((json) => PaymentModel.fromParticipant(json))
          .toList();
    } catch (e) {
      debugPrint('결제 내역 조회 에러: $e');
      rethrow;
    }
  }

  // 특정 결제 정보 조회
  Future<PaymentModel?> getPaymentByMerchantUid(String merchantUid) async {
    try {
      final response = await _client
          .from('participants')
          .select('*, group_buys(*, products(*))')
          .eq('merchant_uid', merchantUid)
          .single();
      
      return PaymentModel.fromParticipant(response);
    } catch (e) {
      debugPrint('결제 정보 조회 에러: $e');
      return null;
    }
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(Supabase.instance.client);
});