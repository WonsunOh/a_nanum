class DashboardMetrics {
  final int totalUsers;
  final int totalSales;
  final int activeDeals;
  final int successfulDeals;
  
  // ✅ 추가: 상세 통계
  final int todayOrders;
  final int todaySales;
  final int pendingOrders;
  final int lowStockProducts;
  
  // ✅ 추가: 증감률
  final double userGrowthRate;
  final double salesGrowthRate;
  
  // ✅ 추가: 주간 데이터
  final List<DailyStats> weeklyStats;

  DashboardMetrics({
    required this.totalUsers,
    required this.totalSales,
    required this.activeDeals,
    required this.successfulDeals,
    this.todayOrders = 0, // ✅ 기본값 설정 (선택)
    this.todaySales = 0,
    this.pendingOrders = 0,
    this.lowStockProducts = 0,
    this.userGrowthRate = 0.0,
    this.salesGrowthRate = 0.0,
    this.weeklyStats = const [],
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalUsers: json['total_users'] ?? 0,
      totalSales: json['total_sales'] ?? 0,
      activeDeals: json['active_deals'] ?? 0,
      successfulDeals: json['successful_deals'] ?? 0,
      
      // ✅ 새 필드 추가
      todayOrders: json['today_orders'] ?? 0,
      todaySales: json['today_sales'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
      lowStockProducts: json['low_stock_products'] ?? 0,
      userGrowthRate: (json['user_growth_rate'] ?? 0.0).toDouble(),
      salesGrowthRate: (json['sales_growth_rate'] ?? 0.0).toDouble(),
      
      // ✅ 주간 통계 파싱
      weeklyStats: (json['weekly_stats'] as List?)
          ?.map((e) => DailyStats.fromJson(e))
          .toList() ?? [],
    );
  }
}

// ✅ DailyStats 클래스 추가
class DailyStats {
  final DateTime date;
  final int orders;
  final int sales;
  final int users;

  DailyStats({
    required this.date,
    required this.orders,
    required this.sales,
    required this.users,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date']),
      orders: json['orders'] ?? 0,
      sales: json['sales'] ?? 0,
      users: json['users'] ?? 0,
    );
  }
}