import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/main_layout.dart';
import '../../../../data/models/inventory_model.dart';
import '../viewmodel/inventory_viewmodel.dart';

class InventoryDashboardScreen extends ConsumerWidget {
  const InventoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);
    final dailyStatsAsync = ref.watch(dailyStatsProvider);
    final topProductsAsync = ref.watch(topActivityProductsProvider);

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('재고 대시보드', style: Theme.of(context).textTheme.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.invalidate(dashboardStatsProvider);
                    ref.invalidate(dailyStatsProvider);
                    ref.invalidate(topActivityProductsProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 재고 현황 카드
                    dashboardStatsAsync.when(
                      data: (stats) => _buildInventoryOverviewCards(context, stats),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('오류: $e')),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 오늘의 활동
                    dashboardStatsAsync.when(
                      data: (stats) => _buildTodayActivityCard(context, stats),
                      loading: () => const SizedBox.shrink(),
                      error: (e, s) => const SizedBox.shrink(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 최근 7일 추이
                    dailyStatsAsync.when(
                      data: (dailyStats) => _buildWeeklyTrendCard(context, dailyStats),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('오류: $e')),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // TOP 활동 상품
                    topProductsAsync.when(
                      data: (products) => _buildTopProductsCard(context, products),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('오류: $e')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryOverviewCards(BuildContext context, InventoryDashboardStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: '총 상품',
            value: stats.totalProducts.toString(),
            subtitle: '개',
            icon: Icons.inventory_2,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: '총 재고',
            value: NumberFormat('#,###').format(stats.totalStock),
            subtitle: '개',
            icon: Icons.widgets,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: '평균 재고',
            value: stats.averageStock.toStringAsFixed(1),
            subtitle: '개/상품',
            icon: Icons.bar_chart,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: '재고 경고',
            value: stats.lowStockCount.toString(),
            subtitle: '품절: ${stats.outOfStockCount}',
            icon: Icons.warning_amber,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayActivityCard(BuildContext context, InventoryDashboardStats stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '오늘의 재고 활동',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(DateTime.now()),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildActivityItem(
                    '입고',
                    stats.todayInCount,
                    stats.todayInQuantity,
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                ),
                Container(width: 1, height: 60, color: Colors.grey[300]),
                Expanded(
                  child: _buildActivityItem(
                    '출고',
                    stats.todayOutCount,
                    stats.todayOutQuantity,
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                ),
                Container(width: 1, height: 60, color: Colors.grey[300]),
                Expanded(
                  child: _buildActivityItem(
                    '조정',
                    stats.todayAdjustCount,
                    0,
                    Colors.blue,
                    Icons.tune,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String label,
    int count,
    int quantity,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          '$count건',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (quantity > 0)
          Text(
            '${NumberFormat('#,###').format(quantity)}개',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildWeeklyTrendCard(BuildContext context, List<DailyInventoryStats> dailyStats) {
    if (dailyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = dailyStats.fold<int>(
      0,
      (max, stat) => [max, stat.inQuantity, stat.outQuantity].reduce((a, b) => a > b ? a : b),
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  '최근 7일 입출고 추이',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: dailyStats.map((stat) {
                  return _buildBarChart(
                    context,
                    date: stat.date,
                    inQuantity: stat.inQuantity,
                    outQuantity: stat.outQuantity,
                    maxValue: maxValue,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('입고', Colors.green),
                const SizedBox(width: 24),
                _buildLegendItem('출고', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(
    BuildContext context, {
    required DateTime date,
    required int inQuantity,
    required int outQuantity,
    required int maxValue,
  }) {
    final inHeight = maxValue > 0 ? (inQuantity / maxValue * 150).clamp(2.0, 150.0) : 2.0;
    final outHeight = maxValue > 0 ? (outQuantity / maxValue * 150).clamp(2.0, 150.0) : 2.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 12,
              height: inHeight,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 12,
              height: outHeight,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('MM/dd').format(date),
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTopProductsCard(BuildContext context, List<ProductActivityStats> products) {
    if (products.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.inbox, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '최근 7일간 활동 내역이 없습니다.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text(
                  'TOP 5 활동 상품 (최근 7일)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(index),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    product.productName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text('${product.activityCount}건 활동'),
                  trailing: Text(
                    '${NumberFormat('#,###').format(product.totalQuantity)}개',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey[400]!;
      case 2:
        return Colors.brown[300]!;
      default:
        return Colors.blue;
    }
  }
}