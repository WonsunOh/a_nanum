import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
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
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(dailyStatsProvider);
          ref.invalidate(topActivityProductsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '재고 대시보드',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('yyyy년 MM월 dd일 (E)', 'ko').format(DateTime.now()),
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
                      ref.invalidate(dashboardStatsProvider);
                      ref.invalidate(dailyStatsProvider);
                      ref.invalidate(topActivityProductsProvider);
                    },
                    tooltip: '새로고침',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ✅ 재고 현황 카드
              dashboardStatsAsync.when(
                data: (stats) => _buildInventoryOverviewCards(context, stats),
                loading: () => _buildSkeletonCards(),
                error: (e, s) => _buildErrorCard(
                  '재고 통계를 불러오는데 실패했습니다',
                  e,
                  () => ref.invalidate(dashboardStatsProvider),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ 오늘의 활동
              dashboardStatsAsync.when(
                data: (stats) => _buildTodayActivityCard(context, stats),
                loading: () => _buildSkeletonCard(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // ✅ 최근 7일 추이
              dailyStatsAsync.when(
                data: (dailyStats) => _buildWeeklyTrendCard(context, dailyStats),
                loading: () => _buildSkeletonCard(height: 300),
                error: (e, s) => _buildErrorCard(
                  '주간 통계를 불러오는데 실패했습니다',
                  e,
                  () => ref.invalidate(dailyStatsProvider),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ TOP 활동 상품
              topProductsAsync.when(
                data: (products) => _buildTopProductsCard(context, products),
                loading: () => _buildSkeletonCard(),
                error: (e, s) => _buildErrorCard(
                  'TOP 상품을 불러오는데 실패했습니다',
                  e,
                  () => ref.invalidate(topActivityProductsProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ 재고 현황 카드 (개선)
  Widget _buildInventoryOverviewCards(BuildContext context, InventoryDashboardStats stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          context,
          title: '총 상품',
          value: stats.totalProducts.toString(),
          subtitle: '개',
          icon: Icons.inventory_2,
          color: Colors.blue,
          trend: null,
        ),
        _buildStatCard(
          context,
          title: '총 재고',
          value: NumberFormat('#,###').format(stats.totalStock),
          subtitle: '개',
          icon: Icons.widgets,
          color: Colors.green,
          trend: null,
        ),
        _buildStatCard(
          context,
          title: '평균 재고',
          value: stats.averageStock.toStringAsFixed(1),
          subtitle: '개/상품',
          icon: Icons.bar_chart,
          color: Colors.orange,
          trend: null,
        ),
        _buildStatCard(
          context,
          title: '재고 경고',
          value: stats.lowStockCount.toString(),
          subtitle: '품절: ${stats.outOfStockCount}개',
          icon: Icons.warning_amber,
          color: Colors.red,
          trend: stats.lowStockCount > 0 ? '확인 필요' : null,
        ),
      ],
    );
  }

  // ✅ 통계 카드 (그라데이션 & 애니메이션)
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trend,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
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
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 오늘의 활동 카드 (개선)
  Widget _buildTodayActivityCard(BuildContext context, InventoryDashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, color: Colors.blue.shade700, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 재고 활동',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy년 MM월 dd일').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
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
              Container(
                width: 1,
                height: 80,
                color: Colors.blue.shade200,
              ),
              Expanded(
                child: _buildActivityItem(
                  '출고',
                  stats.todayOutCount,
                  stats.todayOutQuantity,
                  Colors.red,
                  Icons.arrow_upward,
                ),
              ),
              Container(
                width: 1,
                height: 80,
                color: Colors.blue.shade200,
              ),
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
    );
  }

  Widget _buildActivityItem(
    String label,
    int count,
    int quantity,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count건',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (quantity > 0)
            Text(
              '${NumberFormat('#,###').format(quantity)}개',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }

  // ✅ 주간 추이 카드 (개선)
  Widget _buildWeeklyTrendCard(BuildContext context, List<DailyInventoryStats> dailyStats) {
    if (dailyStats.isEmpty) {
      return _buildEmptyCard(
        '최근 7일 입출고 추이',
        '재고 활동 내역이 없습니다',
        Icons.trending_up,
      );
    }

    final maxValue = dailyStats.fold<int>(
      0,
      (max, stat) => [max, stat.inQuantity, stat.outQuantity]
          .reduce((a, b) => a > b ? a : b),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.blue.shade700, size: 28),
              const SizedBox(width: 12),
              Text(
                '최근 7일 입출고 추이',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dailyStats.asMap().entries.map((entry) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (entry.key * 100)),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scaleY: value,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    );
                  },
                  child: _buildBarChart(
                    context,
                    date: entry.value.date,
                    inQuantity: entry.value.inQuantity,
                    outQuantity: entry.value.outQuantity,
                    maxValue: maxValue,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('입고', Colors.green),
              const SizedBox(width: 32),
              _buildLegendItem('출고', Colors.red),
            ],
          ),
        ],
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
    final inHeight = maxValue > 0
        ? (inQuantity / maxValue * 150).clamp(4.0, 150.0)
        : 4.0;
    final outHeight = maxValue > 0
        ? (outQuantity / maxValue * 150).clamp(4.0, 150.0)
        : 4.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 14,
              height: inHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 14,
              height: outHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          DateFormat('MM/dd').format(date),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
              _lightenColor(color, 0.2),  // 밝게
              _darkenColor(color, 0.2),   // 어둡게
            ],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 헬퍼 함수들
Color _lightenColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color _darkenColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

  // ✅ TOP 상품 카드 (개선)
  Widget _buildTopProductsCard(BuildContext context, List<ProductActivityStats> products) {
    if (products.isEmpty) {
      return _buildEmptyCard(
        'TOP 5 활동 상품 (최근 7일)',
        '최근 7일간 활동 내역이 없습니다',
        Icons.star,
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 12),
              Text(
                'TOP 5 활동 상품 (최근 7일)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (context, index) => Divider(
              height: 24,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 100)),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getRankColor(index),
                              _getRankColor(index).withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product.activityCount}건 활동',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${NumberFormat('#,###').format(product.totalQuantity)}개',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber.shade600;
      case 1:
        return Colors.grey.shade500;
      case 2:
        return Colors.brown.shade400;
      default:
        return Colors.blue.shade600;
    }
  }

  // ✅ 스켈레톤 로더
  Widget _buildSkeletonCards() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(
        4,
        (index) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 260,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard({double height = 200}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ✅ 에러 카드
  Widget _buildErrorCard(String title, Object error, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 빈 상태 카드
  Widget _buildEmptyCard(String title, String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}