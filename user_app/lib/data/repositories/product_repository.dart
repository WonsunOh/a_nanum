// user_app/lib/data/repositories/product_repository.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

// ⭐️ 이 부분이 shop_viewmodel.dart에서 찾고 있던 Provider의 정의입니다.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final client = Supabase.instance.client;
  return ProductRepository(client);
});

class ProductRepository {
  final SupabaseClient _client;

  ProductRepository(this._client);

  // 쇼핑몰에 진열된 모든 상품 목록을 가져오는 메서드
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('is_displayed', true) // '진열됨' 상태인 상품만 필터링
          .order('created_at', ascending: false);

      final List<ProductModel> products = [];
      for (final item in response) {
        try {
          // 정상적인 데이터만 리스트에 추가
          products.add(ProductModel.fromJson(item));
        } catch (e) {
          // 문제가 있는 데이터는 건너뛰고, 디버그 콘솔에 로그를 남김
          debugPrint('Skipping a product due to parsing error: $e. Data: $item');
        }
      }
      return products;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  // ⭐️ 특정 ID의 상품 하나만 가져오는 메서드
  Future<ProductModel> fetchProductById(int productId) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', productId)
          .single(); // ⭐️ 단일 결과를 가져옵니다.

      return ProductModel.fromJson(response);
    } catch (e) {
      print('--- 🚨 Error fetching product by id: $e ---');
      rethrow;
    }
  }
}