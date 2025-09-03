// admin_web/lib/data/repositories/product_repository.dart (전체 교체)

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

import '../../core/errors/error_handler.dart';
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

  // 관리자 페이지의 모든 상품 목록을 가져오는 기능
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final data = await _client
          .from('products_with_category_path')
          .select('*')
          .order('created_at', ascending: false);
      
      return data.map((item) => ProductModel.fromJson(item)).toList();
    } catch (error, stackTrace) {
      ErrorHandler.logError(error, stackTrace, 'fetchProducts');
      throw ErrorHandler.handleSupabaseError(error);
    }
  }

  
  // 상품을 추가하는 기능
  Future<void> addProduct({
    required String name,
    String? description,
    required int price,
    int? discountPrice,
    DateTime? discountStartDate,
    DateTime? discountEndDate,

    required int stockQuantity,
    required int categoryId,
    required bool isDisplayed,
    required bool isSoldOut,
    List<OptionGroup>? optionGroups, // ⭐️ required 제거, Nullable로 변경
    List<ProductVariant>? variants,
    String? productCode,
    String? relatedProductCode,
    String? imageUrl,
    required int shippingFee, 
    Map<String, bool>? tags, 
    
  }) async {
    final Map<String, dynamic> productData =({
      'name': name,
      'description': description,
      'total_price': price,
      'discount_price': discountPrice,
      'discount_start_date': discountStartDate?.toIso8601String(), // ⭐️ 4. insert 구문에 추가
     'discount_end_date': discountEndDate?.toIso8601String(),
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'is_displayed': isDisplayed,
      'is_sold_out': isSoldOut,
      'product_code': productCode,
      'related_product_code': relatedProductCode,
      'image_url': imageUrl,
      'shipping_fee': shippingFee, // ⭐️ 3. insert 구문에 추가
    'tags': tags,
    
    
    });

    

  final newProduct = await _client.from('products').insert(productData).select().single();
    final newProductId = newProduct['id'];

  // ⭐️ 옵션 데이터가 있을 때만 저장 로직을 실행
  if (optionGroups != null && variants != null) {
    await _saveFullOptions(newProductId, optionGroups, variants);
  }
  }

  // ⭐️ 가격 정보만 업데이트하는 효율적인 메서드 추가
  Future<void> updateProductPrice({
    required int productId,
    required int price,
    int? discountPrice,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
  }) async {
    await _client.from('products').update({
      'total_price': price,
      'discount_price': discountPrice,
      'discount_start_date': discountStartDate?.toIso8601String(),
      'discount_end_date': discountEndDate?.toIso8601String(),
    }).eq('id', productId);
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
  final Map<String, dynamic> productData =({
      'name': product.name,
      'description': product.description,
      'total_price': product.price,
      'stock_quantity': product.stockQuantity,
      'category_id': product.categoryId,
      'is_displayed': product.isDisplayed,
      'is_sold_out': product.isSoldOut,
      'product_code': product.productCode,
      'related_product_code': product.relatedProductCode,
      'shipping_fee': product.shippingFee,
      'tags': product.tags,
      'image_url': product.imageUrl,
      'discount_price': product.discountPrice,
      // ⭐️ 6. 누락되었던 날짜 필드를 여기에 추가합니다.
      'discount_start_date': product.discountStartDate?.toIso8601String(),
      'discount_end_date': product.discountEndDate?.toIso8601String(),
    });

  // ⭐️ [데이터 추적 3단계] Repository에서 DB로 데이터를 보내기 직전 최종 값 확인
    debugPrint('--- [REPOSITORY] Updating Data to Supabase ---');
    debugPrint(productData.toString());
    debugPrint('-----------------------------------------------');

  await _client.from('products').update(productData).eq('id', product.id);

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
      final uniqueFileName = 'public/${DateTime.now().millisecondsSinceEpoch}$fileExtension';
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

// 할인 중인 상품 목록만 가져오는 기능
  Future<List<ProductModel>> fetchDiscountedProducts() async {
    final data = await _client
        .from('products_with_category_path') // 기존 VIEW 재사용
        .select('*')
        .not('discount_price', 'is', null) // discount_price가 null이 아니고
        .gt('discount_price', 0) // 0보다 큰 상품만
        .order('created_at', ascending: false);
        
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }
Future<List<ProductModel>> searchProducts(String query) async {
    final data = await _client
        .from('products_with_category_path')
        .select('*')
        // 'name' 컬럼에서 query를 포함하는 모든 데이터를 대소문자 구분 없이 검색
        .ilike('name', '%$query%')
        .order('created_at', ascending: false);
        
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }
/// 'products' 버킷의 'public' 폴더에 있는 모든 파일을 삭제하는 함수
  Future<void> emptyPublicFolderInProducts() async {
    const bucketName = 'products';
    const folderName = 'public';

    debugPrint('"$bucketName" 버킷의 "$folderName" 폴더 삭제를 시작합니다...');

    try {
      final fileList = await _client.storage
          .from(bucketName)
          .list(path: folderName);

      if (fileList.isEmpty) {
        debugPrint('✅ 폴더에 삭제할 파일이 없습니다.');
        return;
      }

      final filePathsToRemove = fileList
          .map((file) => '$folderName/${file.name}')
          .toList();

      await _client.storage
          .from(bucketName)
          .remove(filePathsToRemove);
      
      debugPrint('✅ ${filePathsToRemove.length}개의 파일이 성공적으로 삭제되었습니다.');

    } on StorageException catch (e) {
      debugPrint('🚨 스토리지 에러 발생: ${e.message}');
    } catch (e) {
      debugPrint('🚨 알 수 없는 에러 발생: $e');
    }
  }
}