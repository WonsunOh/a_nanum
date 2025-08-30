// user_app/lib/data/repositories/product_repository.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/product_variant_model.dart';

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
      // ⭐️ .from('products')를 .from('products_with_category_path')로 변경!
      final response = await _client
          .from('products_with_category_path')
          .select('*')
          .eq('is_displayed', true)
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

  // ⭐️ 특정 상품의 모든 옵션과 조합을 계층 구조로 불러오는 메서드
Future<(List<OptionGroup>, List<ProductVariant>)> fetchProductOptionsAndVariants(int productId) async {
  // 1. 옵션 그룹 조회
  final groupsResponse = await _client.from('product_option_groups').select().eq('product_id', productId);
  final List<OptionGroup> optionGroups = [];

  // 2. 각 그룹에 속한 값들 조회
  for (final groupData in groupsResponse) {
    final groupId = groupData['id'];
    final valuesResponse = await _client.from('product_option_values').select().eq('option_group_id', groupId);
    final optionValues = valuesResponse.map((valueData) => OptionValue.fromJson(valueData)).toList();
    optionGroups.add(OptionGroup(id: groupId, name: groupData['name'], values: optionValues));
  }

  // 3. 최종 조합(Variant)들 조회
  final variantsResponse = await _client.from('product_variants').select().eq('product_id', productId);
  final List<ProductVariant> variants = variantsResponse.map((variantData) => ProductVariant.fromJson(variantData)).toList();

  return (optionGroups, variants);
}
}