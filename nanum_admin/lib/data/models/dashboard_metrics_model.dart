class DashboardMetrics {
  final int totalUsers;
  final int totalSales;
  final int activeDeals;
  final int successfulDeals;

  DashboardMetrics({
    required this.totalUsers,
    required this.totalSales,
    required this.activeDeals,
    required this.successfulDeals,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalUsers: json['total_users'] ?? 0,
      totalSales: json['total_sales'] ?? 0,
      activeDeals: json['active_deals'] ?? 0,
      successfulDeals: json['successful_deals'] ?? 0,
    );
  }
}