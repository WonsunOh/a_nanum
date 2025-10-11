// nanum_admin/lib/data/repositories/inventory_repository.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bulk_upload_model.dart';
import '../models/inventory_model.dart';

class InventoryRepository {
  final SupabaseClient _client;

  InventoryRepository(this._client);

  // 📌 상품 검색 메서드 추가
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      debugPrint('🔍 Searching products with query: "$query"');
      
      // 검색 쿼리 실행
      final response = await _client
          .from('products')
          .select('id, name, stock_quantity, total_price')
          .ilike('name', '%$query%')
          // .eq('is_active', true) // 활성화된 상품만
          .order('name', ascending: true)
          .limit(20);
      
      final results = (response as List).map((data) => data as Map<String, dynamic>).toList();
      debugPrint('✅ Found ${results.length} products');
      
      return results;
    } catch (e) {
      debugPrint('❌ Error searching products: $e');
      rethrow; // 에러를 다시 던져서 UI에서 확인 가능하게
    }
  }

  // 재고 변경 로그 기록
  Future<void> recordInventoryChange({
    required int productId,
    required String type,
    required int quantity,
    required int previousStock,
    required int currentStock,
    String? reason,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      
      await _client.from('inventory_logs').insert({
        'product_id': productId,
        'type': type,
        'quantity': quantity,
        'previous_stock': previousStock,
        'current_stock': currentStock,
        'reason': reason,
        'admin_id': currentUser?.id,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      debugPrint('✅ Inventory log recorded for product $productId');
    } catch (e) {
      debugPrint('❌ Error recording inventory log: $e');
      rethrow;
    }
  }

  // 재고 조정 (입고/출고/조정)
  Future<void> adjustStock({
    required int productId,
    required String type,
    required int quantity,
    String? reason,
  }) async {
    try {
      // 현재 재고 조회
      final product = await _client
          .from('products')
          .select('stock_quantity')
          .eq('id', productId)
          .single();
      
      final previousStock = product['stock_quantity'] as int;
      int newStock;
      
      switch (type) {
        case 'in': // 입고
          newStock = previousStock + quantity;
          break;
        case 'out': // 출고
          newStock = previousStock - quantity;
          if (newStock < 0) newStock = 0;
          break;
        case 'adjust': // 조정 (절대값으로 설정)
          newStock = quantity;
          break;
        default:
          throw Exception('Invalid type: $type');
      }
      
      // 재고 업데이트
      await _client
          .from('products')
          .update({'stock_quantity': newStock})
          .eq('id', productId);
      
      // 로그 기록
      await recordInventoryChange(
        productId: productId,
        type: type,
        quantity: type == 'adjust' ? newStock - previousStock : quantity,
        previousStock: previousStock,
        currentStock: newStock,
        reason: reason,
      );
      
      debugPrint('✅ Stock adjusted: $previousStock → $newStock');
    } catch (e) {
      debugPrint('❌ Error adjusting stock: $e');
      rethrow;
    }
  }

  // 재고 변경 내역 조회
  Future<List<InventoryLog>> fetchInventoryLogs({
    int? productId,
    int limit = 100,
  }) async {
    try {
      final response = productId != null
          ? await _client
              .from('inventory_logs')
              .select('*, products(name)')
              .eq('product_id', productId)
              .order('created_at', ascending: false)
              .limit(limit)
          : await _client
              .from('inventory_logs')
              .select('*, products(name)')
              .order('created_at', ascending: false)
              .limit(limit);
      
      return (response as List).map((data) {
        final productName = data['products'] != null 
            ? data['products']['name'] as String
            : '알 수 없는 상품';
        
        return InventoryLog(
          id: data['id'],
          productId: data['product_id'],
          productName: productName,
          type: data['type'],
          quantity: data['quantity'],
          previousStock: data['previous_stock'],
          currentStock: data['current_stock'],
          reason: data['reason'],
          adminId: data['admin_id'],
          createdAt: DateTime.parse(data['created_at']),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching inventory logs: $e');
      return [];
    }
  }

  // 재고 부족 상품 조회
  Future<List<StockAlert>> fetchLowStockAlerts({int threshold = 10}) async {
    try {
      final response = await _client
          .from('products')
          .select('id, name, stock_quantity')
          .lte('stock_quantity', threshold)
          .eq('is_active', true) // 활성화된 상품만
          .order('stock_quantity', ascending: true);
      
      return (response as List).map((data) {
        return StockAlert(
          productId: data['id'],
          productName: data['name'],
          currentStock: data['stock_quantity'],
          threshold: threshold,
          isOutOfStock: data['stock_quantity'] == 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching low stock alerts: $e');
      return [];
    }
  }

  // 재고 일괄 조정 (엑셀 업로드 등)
  Future<void> bulkAdjustStock(List<Map<String, dynamic>> adjustments) async {
    try {
      for (final adj in adjustments) {
        await adjustStock(
          productId: adj['product_id'],
          type: 'adjust',
          quantity: adj['quantity'],
          reason: adj['reason'] ?? '일괄 조정',
        );
      }
      
      debugPrint('✅ Bulk stock adjustment completed: ${adjustments.length} items');
    } catch (e) {
      debugPrint('❌ Error in bulk adjustment: $e');
      rethrow;
    }
  }

  // InventoryRepository 클래스에 추가

// 📌 대시보드 통계 조회
Future<InventoryDashboardStats> fetchDashboardStats() async {
  try {
    // 1. 전체 상품 통계
    final productsResponse = await _client
        .from('products')
        .select('stock_quantity')
        .eq('is_active', true);
    
    final productsList = productsResponse as List;
    final totalProducts = productsList.length;
    final totalStock = productsList.fold<int>(
      0,
      (sum, item) => sum + (item['stock_quantity'] as int),
    );
    final lowStockCount = productsList.where((p) => p['stock_quantity'] <= 10).length;
    final outOfStockCount = productsList.where((p) => p['stock_quantity'] == 0).length;
    final averageStock = totalProducts > 0 ? totalStock / totalProducts : 0.0;

    // 2. 오늘의 재고 활동
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final todayLogsResponse = await _client
        .from('inventory_logs')
        .select('type, quantity')
        .gte('created_at', startOfDay.toIso8601String())
        .lte('created_at', endOfDay.toIso8601String());

    final todayLogs = todayLogsResponse as List;
    
    final todayInLogs = todayLogs.where((log) => log['type'] == 'in').toList();
    final todayOutLogs = todayLogs.where((log) => log['type'] == 'out').toList();
    final todayAdjustLogs = todayLogs.where((log) => log['type'] == 'adjust').toList();

    final todayInCount = todayInLogs.length;
    final todayOutCount = todayOutLogs.length;
    final todayAdjustCount = todayAdjustLogs.length;
    
    final todayInQuantity = todayInLogs.fold<int>(0, (sum, log) => sum + (log['quantity'] as int).abs());
    final todayOutQuantity = todayOutLogs.fold<int>(0, (sum, log) => sum + (log['quantity'] as int).abs());

    return InventoryDashboardStats(
      totalProducts: totalProducts,
      totalStock: totalStock,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      averageStock: averageStock,
      todayInCount: todayInCount,
      todayOutCount: todayOutCount,
      todayAdjustCount: todayAdjustCount,
      todayInQuantity: todayInQuantity,
      todayOutQuantity: todayOutQuantity,
    );
  } catch (e) {
    debugPrint('❌ Error fetching dashboard stats: $e');
    rethrow;
  }
}

// 📌 최근 7일 일별 통계
Future<List<DailyInventoryStats>> fetchDailyStats({int days = 7}) async {
  try {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));

    final response = await _client
        .from('inventory_logs')
        .select('created_at, type, quantity')
        .gte('created_at', startDate.toIso8601String())
        .order('created_at', ascending: true);

    final logs = response as List;

    // 날짜별로 그룹화
    final Map<String, DailyInventoryStats> dailyStatsMap = {};

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      dailyStatsMap[dateKey] = DailyInventoryStats(
        date: date,
        inCount: 0,
        outCount: 0,
        adjustCount: 0,
        inQuantity: 0,
        outQuantity: 0,
      );
    }

    // 로그 데이터를 날짜별로 집계
    for (final log in logs) {
      final createdAt = DateTime.parse(log['created_at']);
      final dateKey = DateFormat('yyyy-MM-dd').format(createdAt);
      final type = log['type'] as String;
      final quantity = (log['quantity'] as int).abs();

      if (dailyStatsMap.containsKey(dateKey)) {
        final existing = dailyStatsMap[dateKey]!;
        
        switch (type) {
          case 'in':
            dailyStatsMap[dateKey] = DailyInventoryStats(
              date: existing.date,
              inCount: existing.inCount + 1,
              outCount: existing.outCount,
              adjustCount: existing.adjustCount,
              inQuantity: existing.inQuantity + quantity,
              outQuantity: existing.outQuantity,
            );
            break;
          case 'out':
            dailyStatsMap[dateKey] = DailyInventoryStats(
              date: existing.date,
              inCount: existing.inCount,
              outCount: existing.outCount + 1,
              adjustCount: existing.adjustCount,
              inQuantity: existing.inQuantity,
              outQuantity: existing.outQuantity + quantity,
            );
            break;
          case 'adjust':
            dailyStatsMap[dateKey] = DailyInventoryStats(
              date: existing.date,
              inCount: existing.inCount,
              outCount: existing.outCount,
              adjustCount: existing.adjustCount + 1,
              inQuantity: existing.inQuantity,
              outQuantity: existing.outQuantity,
            );
            break;
        }
      }
    }

    return dailyStatsMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  } catch (e) {
    debugPrint('❌ Error fetching daily stats: $e');
    return [];
  }
}

// 📌 TOP 활동 상품 조회
Future<List<ProductActivityStats>> fetchTopActivityProducts({int limit = 5, int days = 7}) async {
  try {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final response = await _client
        .from('inventory_logs')
        .select('product_id, products(name), quantity')
        .gte('created_at', startDate.toIso8601String())
        .order('created_at', ascending: false);

    final logs = response as List;

    // 상품별로 그룹화
    final Map<int, ProductActivityStats> productStatsMap = {};

    for (final log in logs) {
      final productId = log['product_id'] as int;
      final productName = log['products'] != null 
          ? log['products']['name'] as String
          : '알 수 없는 상품';
      final quantity = (log['quantity'] as int).abs();

      if (productStatsMap.containsKey(productId)) {
        final existing = productStatsMap[productId]!;
        productStatsMap[productId] = ProductActivityStats(
          productId: productId,
          productName: productName,
          activityCount: existing.activityCount + 1,
          totalQuantity: existing.totalQuantity + quantity,
        );
      } else {
        productStatsMap[productId] = ProductActivityStats(
          productId: productId,
          productName: productName,
          activityCount: 1,
          totalQuantity: quantity,
        );
      }
    }

    final sortedStats = productStatsMap.values.toList()
      ..sort((a, b) => b.activityCount.compareTo(a.activityCount));

    return sortedStats.take(limit).toList();
  } catch (e) {
    debugPrint('❌ Error fetching top activity products: $e');
    return [];
  }
}

// 📌 상품 코드로 상품 조회
Future<Map<String, dynamic>?> findProductByCode(String productCode) async {
  try {
    final response = await _client
        .from('products')
        .select('id, name, stock_quantity, total_price')
        .eq('product_code', productCode)
        .maybeSingle();
    
    return response;
  } catch (e) {
    debugPrint('❌ Error finding product by code: $e');
    return null;
  }
}

// 📌 일괄 재고 조정 (트랜잭션 방식)
Future<BulkUploadResult> bulkAdjustStockFromRows(List<BulkUploadRow> rows) async {
  final startTime = DateTime.now();
  int successCount = 0;
  int failCount = 0;
  final List<String> errors = [];

  for (final row in rows) {
    if (!row.isValid || row.productId == null) {
      failCount++;
      errors.add('Row ${row.rowNumber}: ${row.errorMessage ?? "유효하지 않은 데이터"}');
      continue;
    }

    try {
      await adjustStock(
        productId: row.productId!,
        type: row.type!,
        quantity: row.quantity!,
        reason: row.reason ?? '일괄 업로드',
      );
      successCount++;
    } catch (e) {
      failCount++;
      errors.add('Row ${row.rowNumber}: ${row.productName ?? row.productCode} - $e');
      debugPrint('❌ Error processing row ${row.rowNumber}: $e');
    }
  }

  final processingTime = DateTime.now().difference(startTime);

  return BulkUploadResult(
    totalRows: rows.length,
    successCount: successCount,
    failCount: failCount,
    errors: errors,
    processingTime: processingTime,
  );
}
}

final inventoryRepositoryProvider = Provider((ref) {
  return InventoryRepository(Supabase.instance.client);
});