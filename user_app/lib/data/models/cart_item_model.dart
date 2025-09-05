// user_app/lib/data/models/cart_item_model.dart (새 파일)

import 'product_model.dart'; // ⭐️ 상품 정보를 포함하기 위해 import

class CartItemModel {
  final int id;
  final String userId;
  final int productId;
  int quantity;
  final DateTime createdAt;
  final ProductModel? product;
  // ✅ variant 관련 필드들을 optional로 유지하되 사용 안함
  final int? variantId;
  final String? variantName;
  final int? variantAdditionalPrice;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    this.product,
    this.variantId,
    this.variantName,
    this.variantAdditionalPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
  return CartItemModel(
    id: json['id'] as int,
    userId: json['user_id'] as String,
    productId: json['product_id'] as int,
    quantity: json['quantity'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    product: json.containsKey('products') && json['products'] != null
        ? ProductModel.fromJson(json['products'])
        : null,
    // ✅ variant 정보 복원
    variantId: json['variant_id'],
    variantName: json['product_variants']?['name'],
    variantAdditionalPrice: json['product_variants']?['additional_price'],
  );
}
}