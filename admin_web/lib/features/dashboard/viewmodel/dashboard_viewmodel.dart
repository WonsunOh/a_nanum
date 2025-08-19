import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/dashboard_metrics_model.dart';
import '../../../data/repositories/dashboard_repository.dart';

final dashboardViewModelProvider = FutureProvider.autoDispose<DashboardMetrics>((ref) {
  return ref.watch(dashboardRepositoryProvider).fetchMetrics();
});