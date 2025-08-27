import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/dashboard_metrics_model.dart';

class DashboardRepository {
  final SupabaseClient _supabaseAdmin;

  DashboardRepository()
      : _supabaseAdmin = SupabaseClient(
          dotenv.env['SUPABASE_URL']!,
          dotenv.env['SUPABASE_SERVICE_ROLE_KEY']!,
        );
  
  Future<DashboardMetrics> fetchMetrics() async {
    // .rpc() 호출 시 .single()을 붙여주면 단일 JSON 객체를 반환받습니다.
    final response = await _supabaseAdmin.rpc('get_dashboard_metrics').single();
    return DashboardMetrics.fromJson(response);
  }
}

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());