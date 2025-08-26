// user_app/lib/data/models/wishlist_item_model.dart

import 'product_model.dart';

class WishlistItemModel {
  final int id;
  final String userId;
  final int productId;
  final DateTime createdAt;
  final ProductModel? product; // 찜 목록에서 상품 정보를 바로 보여주기 위함

  WishlistItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
    this.product,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      productId: json['product_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      product: json.containsKey('products') && json['products'] != null
          ? ProductModel.fromJson(json['products'])
          : null,
    );
  }
}