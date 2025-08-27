import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/main_layout.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardViewModelProvider);
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardViewModelProvider.future),
          child: ListView( // 전체 화면을 스크롤 가능하게 만듭니다.
            children: [
              Text('요약', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              metricsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('데이터 로딩 실패: $e'),
                data: (metrics) {
                  return Wrap( // 화면 폭에 따라 자동으로 줄바꿈되는 Wrap 위젯
                    spacing: 24, // 가로 간격
                    runSpacing: 24, // 세로 간격
                    children: [
                      _MetricCard(
                        icon: Icons.people,
                        title: '총 회원 수',
                        value: '${metrics.totalUsers} 명',
                        color: Colors.blue,
                      ),
                      _MetricCard(
                        icon: Icons.monetization_on,
                        title: '총 매출액',
                        value: '${currencyFormat.format(metrics.totalSales)} 원',
                        color: Colors.green,
                      ),
                      _MetricCard(
                        icon: Icons.local_fire_department,
                        title: '진행중인 공구',
                        value: '${metrics.activeDeals} 건',
                        color: Colors.orange,
                      ),
                      _MetricCard(
                        icon: Icons.check_circle,
                        title: '성공한 공구',
                        value: '${metrics.successfulDeals} 건',
                        color: Colors.purple,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
              Text('주간 매출 현황', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              // TODO: 여기에 fl_chart 같은 패키지를 이용해 차트 위젯 추가
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('차트가 여기에 표시됩니다.')),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 통계 카드를 위한 재사용 가능한 위젯
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}