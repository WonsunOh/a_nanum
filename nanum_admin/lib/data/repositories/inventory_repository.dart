// nanum_admin/lib/data/repositories/inventory_repository.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_model.dart';

class InventoryRepository {
  final SupabaseClient _client;

  InventoryRepository(this._client);

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
      // ⭐️ 수정: 쿼리 체이닝 방식 변경
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
}

final inventoryRepositoryProvider = Provider((ref) {
  return InventoryRepository(Supabase.instance.client);
});