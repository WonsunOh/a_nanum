// File: nanum_admin/lib/data/repositories/cancellation_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cancellation_model.dart';

final cancellationRepositoryProvider = Provider((ref) {
  return CancellationRepository(Supabase.instance.client);
});

class CancellationRepository {
  final SupabaseClient _supabase;

  CancellationRepository(this._supabase);

  // 전체 취소 내역 조회
  Future<List<CancellationModel>> getFullCancellations({int page = 0, int pageSize = 20}) async {
    final response = await _supabase
        .from('order_cancellations')
        .select()
        .order('requested_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (response as List)
        .map((e) => CancellationModel.fromFullCancellation(e))
        .toList();
  }

  // 부분 취소 내역 조회
  Future<List<CancellationModel>> getPartialCancellations({int page = 0, int pageSize = 20}) async {
    final response = await _supabase
        .from('order_item_cancellations')
        .select('*, orders(order_number), order_items(products(name))')
        .order('requested_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);
        
    return (response as List)
        .map((e) => CancellationModel.fromPartialCancellation(e))
        .toList();
  }
}