import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/main_layout.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../../shop_management/inventory/viewmodel/inventory_viewmodel.dart'; // ✅ 추가
import 'widgets/dashboard_chart_widget.dart';
import 'widgets/dashboard_metric_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardViewModelProvider);
    final inventoryStatsAsync = ref.watch(dashboardStatsProvider); // ✅ 추가
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return MainLayout(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardViewModelProvider);
          ref.invalidate(dashboardStatsProvider); // ✅ 추가
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: metricsAsync.when(
            loading: () => _buildSkeletonLoader(),
            error: (e, s) => _buildErrorState(e, () {
              ref.invalidate(dashboardViewModelProvider);
            }),
            data: (metrics) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '대시보드',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy년 MM월 dd일 (E)', 'ko')
                              .format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        ref.invalidate(dashboardViewModelProvider);
                        ref.invalidate(dashboardStatsProvider); // ✅ 추가
                      },
                      tooltip: '새로고침',
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 주요 지표 카드
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    DashboardMetricCard(
                      icon: Icons.people,
                      title: '총 회원 수',
                      value: '${metrics.totalUsers}명',
                      subtitle: '전월 대비',
                      growthRate: metrics.userGrowthRate,
                      color: Colors.blue,
                    ),
                    DashboardMetricCard(
                      icon: Icons.monetization_on,
                      title: '총 매출액',
                      value: '₩${currencyFormat.format(metrics.totalSales)}',
                      subtitle: '전월 대비',
                      growthRate: metrics.salesGrowthRate,
                      color: Colors.green,
                    ),
                    DashboardMetricCard(
                      icon: Icons.shopping_cart,
                      title: '오늘 주문',
                      value: '${metrics.todayOrders}건',
                      subtitle: '₩${currencyFormat.format(metrics.todaySales)}',
                      color: Colors.orange,
                    ),
                    DashboardMetricCard(
                      icon: Icons.pending_actions,
                      title: '대기중 주문',
                      value: '${metrics.pendingOrders}건',
                      subtitle: '처리 필요',
                      color: Colors.purple,
                    ),
                    DashboardMetricCard(
                      icon: Icons.local_fire_department,
                      title: '진행중인 공구',
                      value: '${metrics.activeDeals}건',
                      color: Colors.red,
                    ),
                    DashboardMetricCard(
                      icon: Icons.check_circle,
                      title: '성공한 공구',
                      value: '${metrics.successfulDeals}건',
                      color: Colors.teal,
                    ),
                    DashboardMetricCard(
                      icon: Icons.inventory,
                      title: '재고 부족 상품',
                      value: '${metrics.lowStockProducts}개',
                      subtitle: '확인 필요',
                      color: Colors.amber,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ✅ 재고 요약 섹션 추가
                _buildInventorySummarySection(context, inventoryStatsAsync),

                const SizedBox(height: 40),

                // 차트 섹션
                WeeklySalesChart(weeklyStats: metrics.weeklyStats),
                
                const SizedBox(height: 24),
                
                OrdersBarChart(weeklyStats: metrics.weeklyStats),

                const SizedBox(height: 40),

                // 빠른 액션
                _buildQuickActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ 재고 요약 섹션
  Widget _buildInventorySummarySection(
    BuildContext context,
    AsyncValue inventoryStatsAsync,
  ) {
    return inventoryStatsAsync.when(
      data: (stats) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.purple.shade700, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '재고 현황 요약',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    context.go('/shop/inventory');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('상세보기'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInventoryMiniCard(
                    '총 상품',
                    '${stats.totalProducts}개',
                    Icons.inventory_2,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInventoryMiniCard(
                    '총 재고',
                    '${NumberFormat('#,###').format(stats.totalStock)}개',
                    Icons.widgets,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInventoryMiniCard(
                    '재고 부족',
                    '${stats.lowStockCount}개',
                    Icons.warning_amber,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInventoryMiniCard(
                    '품절',
                    '${stats.outOfStockCount}개',
                    Icons.remove_circle_outline,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTodayActivity(
                    '오늘 입고',
                    stats.todayInCount,
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  _buildTodayActivity(
                    '오늘 출고',
                    stats.todayOutCount,
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  _buildTodayActivity(
                    '오늘 조정',
                    stats.todayAdjustCount,
                    Icons.tune,
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => _buildInventorySkeletonLoader(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildInventoryMiniCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayActivity(
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count건',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInventorySkeletonLoader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '빠른 실행',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickActionButton(
                icon: Icons.add_shopping_cart,
                label: '상품 추가',
                color: Colors.blue,
                onTap: () => context.go('/shop/products'),
              ),
              _buildQuickActionButton(
                icon: Icons.receipt_long,
                label: '주문 관리',
                color: Colors.green,
                onTap: () => context.go('/orders/shop'),
              ),
              _buildQuickActionButton(
                icon: Icons.inventory_2,
                label: '재고 관리',
                color: Colors.orange,
                onTap: () => context.go('/shop/inventory'),
              ),
              _buildQuickActionButton(
                icon: Icons.people,
                label: '회원 관리',
                color: Colors.purple,
                onTap: () => context.go('/users'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          const Text(
            '데이터를 불러오는데 실패했습니다',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(error.toString()),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}