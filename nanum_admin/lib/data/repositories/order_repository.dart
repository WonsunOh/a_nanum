// nanum_admin/lib/data/repositories/order_repository.dart (전체 수정)

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_model.dart';

// ⭐️ 1. 주문 타입을 구분하기 위한 Enum을 만듭니다.
enum OrderType { shop, groupBuy }

class OrderRepository {
  final SupabaseClient _supabaseAdmin;

  OrderRepository()
      : _supabaseAdmin = SupabaseClient(
          dotenv.env['SUPABASE_URL']!,
          dotenv.env['SUPABASE_SERVICE_ROLE_KEY']!,
        );

  // ⭐️ 2. 기존 함수를 '공동구매' 주문 전용으로 변경합니다.
  Future<List<Order>> fetchGroupBuyOrders() async {
    try {
      final response = await _supabaseAdmin
          .from('participants')
          .select('''
            id,
            quantity,
            delivery_address,
            profiles (username, phone),
            group_buys!inner (
              status,
              products (name)
            )
          ''')
          // 공동구매 주문 중 '성공' 이후 단계의 주문들만 가져옵니다.
          .inFilter('group_buys.status', ['success', 'preparing', 'shipped', 'completed']);

      return (response as List).map((data) => Order.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching successful group buy orders: $e');
      rethrow;
    }
  }

  // ⭐️ 3. '쇼핑몰' 주문을 가져오는 새로운 함수를 만듭니다.
  //    기존 Order 모델과 형식을 맞추기 위해 SQL 쿼리를 조정합니다.
  Future<List<Order>> fetchShopOrders() async {
    try {
      final response = await _supabaseAdmin
          .from('order_items')
          .select('''
            id,
            quantity,
            orders!inner (
              recipient_name,
              recipient_phone,
              shipping_address
            ),
            products (name)
          ''');

      // 가져온 데이터를 기존 Order 모델에 맞게 가공합니다.
      return (response as List).map((data) {
        return Order(
          participantId: data['id'], // order_items.id를 participantId처럼 사용
          quantity: data['quantity'],
          productName: data['products']?['name'] ?? 'N/A',
          userName: data['orders']?['recipient_name'],
          deliveryAddress: data['orders']?['shipping_address'],
          userPhone: data['orders']?['recipient_phone'],
        );
      }).toList();

    } catch (e) {
      debugPrint('Error fetching shop orders: $e');
      rethrow;
    }
  }


  // 송장 번호 일괄 업데이트 RPC를 호출하는 메소드 (기존 코드 유지)
  Future<void> batchUpdateTrackingNumbers(List<Map<String, dynamic>> updates) async {
    try {
      await _supabaseAdmin.rpc('batch_update_tracking_numbers', params: {'updates': updates});
    } catch (e) {
      debugPrint('Error batch updating tracking numbers: $e');
      rethrow;
    }
  }
}

final orderRepositoryProvider = Provider((ref) => OrderRepository());