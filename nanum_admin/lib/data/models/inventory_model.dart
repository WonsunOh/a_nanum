// nanum_admin/lib/data/models/inventory_model.dart

class InventoryLog {
  final int id;
  final int productId;
  final String productName;
  final String type; // 'in' (입고), 'out' (출고), 'adjust' (조정)
  final int quantity; // 변경 수량
  final int previousStock; // 변경 전 재고
  final int currentStock; // 변경 후 재고
  final String? reason; // 변경 사유
  final String? adminId;
  final DateTime createdAt;

  InventoryLog({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.currentStock,
    this.reason,
    this.adminId,
    required this.createdAt,
  });

  factory InventoryLog.fromJson(Map<String, dynamic> json) {
    return InventoryLog(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'] ?? '알 수 없는 상품',
      type: json['type'],
      quantity: json['quantity'],
      previousStock: json['previous_stock'],
      currentStock: json['current_stock'],
      reason: json['reason'],
      adminId: json['admin_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class StockAlert {
  final int productId;
  final String productName;
  final int currentStock;
  final int threshold; // 알림 임계값
  final bool isOutOfStock;

  StockAlert({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.threshold,
    required this.isOutOfStock,
  });
}

// 📌 일별 재고 통계
class DailyInventoryStats {
  final DateTime date;
  final int inCount;
  final int outCount;
  final int adjustCount;
  final int inQuantity;
  final int outQuantity;

  DailyInventoryStats({
    required this.date,
    required this.inCount,
    required this.outCount,
    required this.adjustCount,
    required this.inQuantity,
    required this.outQuantity,
  });
}

// 📌 재고 대시보드 통계
class InventoryDashboardStats {
  final int totalProducts;
  final int totalStock;
  final int lowStockCount;
  final int outOfStockCount;
  final double averageStock;
  
  // 오늘의 활동
  final int todayInCount;
  final int todayOutCount;
  final int todayAdjustCount;
  final int todayInQuantity;
  final int todayOutQuantity;

  InventoryDashboardStats({
    required this.totalProducts,
    required this.totalStock,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.averageStock,
    required this.todayInCount,
    required this.todayOutCount,
    required this.todayAdjustCount,
    required this.todayInQuantity,
    required this.todayOutQuantity,
  });
}

// 📌 상품 활동 통계
class ProductActivityStats {
  final int productId;
  final String productName;
  final int activityCount;
  final int totalQuantity;

  ProductActivityStats({
    required this.productId,
    required this.productName,
    required this.activityCount,
    required this.totalQuantity,
  });
}