import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_model.dart';

class OrderRepository {
  final SupabaseClient _supabaseAdmin;

  OrderRepository()
      : _supabaseAdmin = SupabaseClient(
          dotenv.env['SUPABASE_URL']!,
          dotenv.env['SUPABASE_SERVICE_ROLE_KEY']!,
        );

  // '모집 성공' 상태의 모든 주문을 가져옵니다.
  Future<List<Order>> fetchSuccessfulOrders() async {
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
          .eq('group_buys.status', 'success'); // 모집 성공 상태 필터링

      return (response as List).map((data) => Order.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching successful orders: $e');
      rethrow;
    }
  }

  // 💡 송장 번호 일괄 업데이트 RPC를 호출하는 메소드
  Future<void> batchUpdateTrackingNumbers(List<Map<String, dynamic>> updates) async {
    try {
      await _supabaseAdmin.rpc('batch_update_tracking_numbers', params: {'updates': updates});
    } catch (e) {
      print('Error batch updating tracking numbers: $e');
      rethrow;
    }
  }
}

final orderRepositoryProvider = Provider((ref) => OrderRepository());