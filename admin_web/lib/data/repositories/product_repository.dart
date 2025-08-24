// admin_web/lib/data/repositories/product_repository.dart (전체 교체)

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

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
    String? description,
    required int price,
    required int stockQuantity,
    required int categoryId,
    required bool isDisplayed,
    String? productCode,
    String? relatedProductCode,
    String? imageUrl,
  }) async {
    await _client.from('products').insert({
      'name': name,
      'description': description,
      'total_price': price,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'is_displayed': isDisplayed,
      'product_code': productCode,
      'related_product_code': relatedProductCode,
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
}