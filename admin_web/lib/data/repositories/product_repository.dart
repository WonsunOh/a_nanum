import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product_model.dart';

class ProductRepository {
  final SupabaseClient _supabaseAdmin;

  ProductRepository()
      : _supabaseAdmin = SupabaseClient(
          dotenv.env['SUPABASE_URL']!,
          dotenv.env['SUPABASE_SERVICE_ROLE_KEY']!,
        );

  Future<List<Product>> fetchAllProducts() async {
    final response = await _supabaseAdmin.from('products').select().order('created_at', ascending: false);
    return (response as List).map((data) => Product.fromJson(data)).toList();
  }

  Future<String> uploadProductImage(Uint8List imageBytes, String imageName) async {
    final fileExt = imageName.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    await _supabaseAdmin.storage.from('products').uploadBinary(
          fileName,
          imageBytes,
          fileOptions: FileOptions(contentType: 'image/$fileExt'),
        );
    return _supabaseAdmin.storage.from('products').getPublicUrl(fileName);
  }

  Future<void> createProduct({
    required String name,
    required int totalPrice,
    String? description,
    String? imageUrl,
    int? categoryId,
    String? externalProductId,
  }) async {
    await _supabaseAdmin.from('products').insert({
      'name': name,
      'total_price': totalPrice,
      'description': description,
      'image_url': imageUrl,
      'category_id': categoryId,
      'external_product_id': externalProductId,
    });
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required int totalPrice,
    String? description,
    String? imageUrl,
    int? categoryId,
    String? externalProductId,
  }) async {
    final updates = {
      'name': name,
      'total_price': totalPrice,
      'description': description,
      'category_id': categoryId,
      'external_product_id': externalProductId,
    };
    if (imageUrl != null) {
      updates['image_url'] = imageUrl;
    }
    await _supabaseAdmin.from('products').update(updates).eq('id', id);
  }

  Future<void> deleteProduct(int productId) async {
    await _supabaseAdmin.from('products').delete().eq('id', productId);
  }
}

final productRepositoryProvider = Provider((ref) => ProductRepository());