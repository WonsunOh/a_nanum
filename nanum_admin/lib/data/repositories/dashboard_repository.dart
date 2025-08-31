// dashboard_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dashboard_metrics_model.dart';

class DashboardRepository {
  // 생성자에서 SupabaseClient를 직접 받도록 수정
  final SupabaseClient _client;
  DashboardRepository(this._client);

  Future<DashboardMetrics> fetchMetrics() async {
    // 이제 안전한 전역 클라이언트를 사용합니다.
    final response = await _client.rpc('get_dashboard_metrics').single();
    return DashboardMetrics.fromJson(response);
  }
}

final dashboardRepositoryProvider = Provider((ref) {
  // main.dart에서 초기화된 전역 클라이언트를 주입합니다.
  return DashboardRepository(Supabase.instance.client);
});