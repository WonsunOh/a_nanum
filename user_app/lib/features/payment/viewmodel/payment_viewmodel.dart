// user_app/lib/features/payment/viewmodel/payment_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/models/payment_model.dart' as local_models;
import '../../../data/models/group_buy_model.dart';

part 'payment_viewmodel.g.dart';

@riverpod
class PaymentViewModel extends _$PaymentViewModel {
  late PaymentRepository _paymentRepository;

  @override
  Future<void> build() async {
    _paymentRepository = ref.watch(paymentRepositoryProvider);
  }

  // 내 결제 내역 조회 (WebView 방식에서는 단순화)
  Future<List<local_models.PaymentModel>> getMyPayments() async {
    try {
      return await _paymentRepository.fetchMyPayments();
    } catch (e) {
      debugPrint('결제 내역 조회 에러: $e');
      rethrow;
    }
  }

  // 결제 준비 (WebView에서 사용할 데이터 준비)
  Future<local_models.PaymentRequest> preparePayment({
    required GroupBuy groupBuy,
    required int quantity,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final paymentRequestData = await _paymentRepository.preparePayment(
        groupBuyId: groupBuy.id,
        quantity: quantity,
        groupBuy: groupBuy,
      );
      
      state = const AsyncValue.data(null);
      return paymentRequestData;
    } catch (e) {
      debugPrint('결제 준비 에러: $e');
      state = AsyncValue.error(e, StackTrace.current);
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
      await _paymentRepository.handlePaymentSuccess(
        merchantUid: merchantUid,
        impUid: impUid,
        amount: amount,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      debugPrint('결제 성공 처리 에러: $e');
      rethrow;
    }
  }

  // 결제 취소 처리
  Future<void> handlePaymentCancel(String merchantUid) async {
    try {
      await _paymentRepository.handlePaymentCancel(merchantUid);
    } catch (e) {
      debugPrint('결제 취소 처리 에러: $e');
      rethrow;
    }
  }
}

// 결제 내역 Provider
@riverpod
Future<List<local_models.PaymentModel>> userPayments(UserPaymentsRef ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.fetchMyPayments();
}