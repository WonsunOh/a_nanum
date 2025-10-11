// lib/features/shop_management/products/providers/product_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/product_variant_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';
import '../viewmodel/product_viewmodel.dart';

// 개별 상품의 variants를 관리하는 Family Provider
final productVariantsProvider = FutureProvider.family<List<ProductVariant>, int>((ref, productId) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.fetchVariantsByProductId(productId);
});

// 상품의 총 재고를 계산하는 Provider
final productTotalStockProvider = FutureProvider.family<int, int>((ref, productId) async {
  // 상품 정보와 variants 정보를 모두 가져와서 총 재고 계산
  final variantsAsync = await ref.watch(productVariantsProvider(productId).future);
  final productAsync = await ref.watch(productViewModelProvider.future);
  
  final product = productAsync.firstWhere((p) => p.id == productId);
  return product.calculateTotalStock(variantsAsync.isNotEmpty ? variantsAsync : null);
});

// 재고 상태를 반환하는 Provider
enum StockStatus { outOfStock, lowStock, sufficient }

final productStockStatusProvider = FutureProvider.family<StockStatus, int>((ref, productId) async {
  final totalStock = await ref.watch(productTotalStockProvider(productId).future);
  
  if (totalStock <= 0) return StockStatus.outOfStock;
  if (totalStock <= 10) return StockStatus.lowStock;
  return StockStatus.sufficient;
});