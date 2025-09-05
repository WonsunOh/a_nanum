// user_app/lib/data/repositories/product_repository.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/product_variant_model.dart';

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
          .eq('is_displayed', true)
          .order('created_at', ascending: false);

      final List<ProductModel> products = [];
      for (final item in response) {
        try {
          products.add(ProductModel.fromJson(item));
        } catch (e) {
          debugPrint('Skipping a product due to parsing error: $e. Data: $item');
        }
      }
      return products;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  // 상품 검색 메서드
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('is_displayed', true)
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);

      final List<ProductModel> products = [];
      for (final item in response) {
        try {
          products.add(ProductModel.fromJson(item));
        } catch (e) {
          debugPrint('Skipping a product due to parsing error: $e. Data: $item');
        }
      }
      return products;
    } catch (e) {
      debugPrint('Error searching products: $e');
      rethrow;
    }
  }

  // 카테고리별 상품 조회 메서드
  Future<List<ProductModel>> fetchProductsByCategory(int categoryId) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('is_displayed', true)
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);

      final List<ProductModel> products = [];
      for (final item in response) {
        try {
          products.add(ProductModel.fromJson(item));
        } catch (e) {
          debugPrint('Skipping a product due to parsing error: $e. Data: $item');
        }
      }
      return products;
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      rethrow;
    }
  }

  // ✅ 카테고리와 하위 카테고리의 상품들을 모두 조회하는 메서드 (수정)
  Future<List<ProductModel>> fetchProductsByCategoryHierarchy(List<int> categoryIds) async {
    try {
      if (categoryIds.isEmpty) {
        return fetchProducts(); // 빈 리스트인 경우 전체 상품 반환
      }

      // ✅ or 조건으로 여러 카테고리 ID를 처리
      String categoryFilter = categoryIds.map((id) => 'category_id.eq.$id').join(',');
      
      final response = await _client
          .from('products')
          .select()
          .eq('is_displayed', true)
          .or(categoryFilter) // 여러 카테고리 ID 중 하나라도 일치
          .order('created_at', ascending: false);

      final List<ProductModel> products = [];
      for (final item in response) {
        try {
          products.add(ProductModel.fromJson(item));
        } catch (e) {
          debugPrint('Skipping a product due to parsing error: $e. Data: $item');
        }
      }
      return products;
    } catch (e) {
      debugPrint('Error fetching products by category hierarchy: $e');
      
      // ✅ 에러 발생 시 첫 번째 카테고리로만 조회 시도
      if (categoryIds.isNotEmpty) {
        return fetchProductsByCategory(categoryIds.first);
      }
      rethrow;
    }
  }

  // 특정 ID의 상품 하나만 가져오는 메서드
  Future<ProductModel> fetchProductById(int productId) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', productId)
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching product by id: $e');
      rethrow;
    }
  }

  // ✅ 특정 상품의 모든 옵션과 조합을 계층 구조로 불러오는 메서드 (리턴 타입 수정)
  Future<(List<OptionGroup>, List<ProductVariant>)> fetchProductOptionsAndVariants(int productId) async {
    try {
      // 1. 옵션 그룹 조회
      final groupsResponse = await _client
          .from('product_option_groups')
          .select()
          .eq('product_id', productId);
      
      final List<OptionGroup> optionGroups = [];

      // 2. 각 그룹에 속한 값들 조회
      for (final groupData in groupsResponse) {
        final groupId = groupData['id'];
        final valuesResponse = await _client
            .from('product_option_values')
            .select()
            .eq('option_group_id', groupId);
        
        final optionValues = valuesResponse
            .map((valueData) => OptionValue.fromJson(valueData))
            .toList();
        
        optionGroups.add(OptionGroup(
          id: groupId,
          name: groupData['name'],
          values: optionValues,
        ));
      }

      // 3. 최종 조합(Variant)들 조회
      final variantsResponse = await _client
          .from('product_variants')
          .select()
          .eq('product_id', productId);
      
      final List<ProductVariant> variants = variantsResponse
          .map((variantData) => ProductVariant.fromJson(variantData))
          .toList();

      return (optionGroups, variants);
    } catch (e) {
      debugPrint('Error fetching product options and variants: $e');
      return (<OptionGroup>[], <ProductVariant>[]); // ✅ 정확한 타입으로 수정
    }
  }
}