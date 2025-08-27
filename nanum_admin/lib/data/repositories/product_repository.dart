// admin_web/lib/data/repositories/product_repository.dart (전체 교체)

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

import '../models/product_model.dart';
import '../models/product_option_model.dart';
import '../models/product_variant_model.dart';

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
    String? description,
    required int price,
    required int stockQuantity,
    required int categoryId,
    required bool isDisplayed,
    required bool isSoldOut,
    List<OptionGroup>? optionGroups, // ⭐️ required 제거, Nullable로 변경
    List<ProductVariant>? variants,
    String? productCode,
    String? relatedProductCode,
    String? imageUrl,
  }) async {
    final newProduct = await _client.from('products').insert({
      'name': name,
      'description': description,
      'total_price': price,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'is_displayed': isDisplayed,
      'is_sold_out': isSoldOut,
      'product_code': productCode,
      'related_product_code': relatedProductCode,
      'image_url': imageUrl,
    }).select().single();

    final newProductId = newProduct['id'];

  // ⭐️ 옵션 데이터가 있을 때만 저장 로직을 실행
  if (optionGroups != null && variants != null) {
    await _saveFullOptions(newProductId, optionGroups, variants);
  }
  }

  // ⭐️ 조합형 옵션을 저장하는 비공개 헬퍼 메서드
Future<void> _saveFullOptions(int productId, List<OptionGroup> optionGroups, List<ProductVariant> variants) async {
  // 옵션 그룹 및 값 저장
  for (final group in optionGroups) {
    if (group.name.isEmpty || group.values.isEmpty) continue;
    
    final newGroup = await _client.from('product_option_groups').insert({
      'product_id': productId,
      'name': group.name,
    }).select().single();
    final newGroupId = newGroup['id'];

    for (final value in group.values) {
      if (value.value.isEmpty) continue;
      await _client.from('product_option_values').insert({
        'option_group_id': newGroupId,
        'value': value.value,
      });
    }
  }

  // 최종 조합(Variant) 저장
  for (final variant in variants) {
    await _client.from('product_variants').insert({
      'product_id': productId,
      'name': variant.name,
      'additional_price': variant.additionalPrice,
      'stock_quantity': variant.stockQuantity,
    });
  }
}
// ⭐️ 1. 상품의 '기본 정보'만 업데이트하는 메서드 (스위치 토글용)
  Future<void> updateProductDetails(ProductModel product) async {
    await _client
        .from('products')
        .update(product.toJson())
        .eq('id', product.id);
  }

// ⭐️ 상품 수정 메서드 수정
Future<void> updateProductWithOptions(ProductModel product, {List<OptionGroup>? optionGroups, List<ProductVariant>? variants}) async {
  // 1. 상품 기본 정보 업데이트
  await _client.from('products').update(product.toJson()).eq('id', product.id);

  // 2. 기존 옵션 관련 정보 깨끗하게 삭제
  await _client.from('product_variants').delete().eq('product_id', product.id);
  await _client.from('product_option_groups').delete().eq('product_id', product.id);

  // 3. 새로운 옵션 데이터가 있을 때만 저장
  if (optionGroups != null && variants != null) {
    await _saveFullOptions(product.id, optionGroups, variants);
  }
}

  // ⭐️ 2. 상품의 '옵션'만 새로 저장하는 메서드
Future<void> saveOptions(int productId, List<ProductOption> options) async {
  // 기존 옵션을 모두 삭제
  await _client.from('product_options').delete().eq('product_id', productId);
  
  // 새로운 옵션을 다시 삽입
  await _saveOptions(productId, options); // 이전에 만든 _saveOptions 헬퍼 메서드 재사용
}

  // ⭐️ 옵션을 저장하는 비공개 헬퍼 메서드
Future<void> _saveOptions(int productId, List<ProductOption> options) async {
  for (final option in options) {
    if (option.name.isEmpty || option.items.isEmpty) continue;

    // 옵션 그룹(예: 색상) 저장
    final newOption = await _client.from('product_options').insert({
      'product_id': productId,
      'name': option.name,
    }).select().single();

    final newOptionId = newOption['id'];

    // 옵션 항목(예: 레드, 블루) 저장
    for (final item in option.items) {
      if (item.name.isEmpty) continue;
      await _client.from('product_option_items').insert({
        'option_id': newOptionId,
        'name': item.name,
        'additional_price': item.additionalPrice,
        'stock_quantity': item.stockQuantity,
      });
    }
  }
}

  // 상품을 삭제하는 기능
  Future<void> deleteProduct(int productId) async {
    await _client.from('products').delete().eq('id', productId);
    
  }

  // ⭐️ 이미지 파일을 Supabase Storage에 업로드하는 메서드
  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      final fileExtension = p.extension(fileName); // 파일 확장자 추출
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      const bucketName = 'products'; // Supabase Storage의 버킷 이름

      // 1. 파일을 스토리지에 업로드합니다.
      await _client.storage
          .from(bucketName)
          .uploadBinary(uniqueFileName, imageBytes);

      // 2. 업로드된 파일의 공개 URL을 가져옵니다.
      final url = _client.storage
          .from(bucketName)
          .getPublicUrl(uniqueFileName);
          
      return url;
    } catch (e) {
      debugPrint('--- 🚨 IMAGE UPLOAD ERROR 🚨 ---');
      debugPrint('$e');
      return null;
    }
  }
// ⭐️ 특정 상품의 옵션 그룹/값과 최종 조합(Variant)을 모두 불러오는 메서드
Future<(List<OptionGroup>, List<ProductVariant>)> fetchOptionsAndVariants(int productId) async {
    // 1. 옵션 그룹들 조회
    final groupsResponse = await _client.from('product_option_groups').select().eq('product_id', productId);
    final List<OptionGroup> optionGroups = [];

    // 2. 각 그룹에 속한 값들 조회
    for (final groupData in groupsResponse) {
        final groupId = groupData['id'];
        final valuesResponse = await _client.from('product_option_values').select().eq('option_group_id', groupId);
        final optionValues = valuesResponse.map((valueData) => OptionValue(id: valueData['id'], value: valueData['value'])).toList();
        optionGroups.add(OptionGroup(id: groupId, name: groupData['name'], values: optionValues));
    }

    // 3. 최종 조합(Variant)들 조회
    final variantsResponse = await _client.from('product_variants').select().eq('product_id', productId);
    final List<ProductVariant> variants = variantsResponse.map((variantData) => ProductVariant(
        id: variantData['id'],
        name: variantData['name'],
        additionalPrice: variantData['additional_price'],
        stockQuantity: variantData['stock_quantity'],
    )).toList();

    return (optionGroups, variants);
}
}