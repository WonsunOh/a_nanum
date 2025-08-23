// admin_web/lib/data/repositories/product_repository.dart (전체 교체)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

// ⭐️ Repository 인스턴스를 앱 전체에 제공하는 Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(Supabase.instance.client);
});

class ProductRepository {
  final SupabaseClient _client;

  ProductRepository(this._client);

  // 모든 상품 목록을 가져오는 기능
  Future<List<ProductModel>> fetchProducts() async {
    final data = await _client.from('products').select().order('created_at');
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }

  // 상품을 추가하는 기능
  Future<void> addProduct({
    required String name,
    required String description,
    required int price,
    required int stockQuantity,
    required int categoryId,
    required bool isDisplayed,
    String? imageUrl,
  }) async {
    await _client.from('products').insert({
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'is_displayed': isDisplayed,
      'image_url': imageUrl,
    });
  }

  // 상품 정보를 업데이트하는 기능
  Future<void> updateProduct(ProductModel product) async {
    // ⭐️ ProductModel에 toJson() 메서드가 필요합니다!
    await _client.from('products').update(product.toJson()).eq('id', product.id);
  }

  // 상품을 삭제하는 기능
  Future<void> deleteProduct(int productId) async {
    await _client.from('products').delete().eq('id', productId);
  }
}