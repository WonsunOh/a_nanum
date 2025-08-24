// user_app/lib/data/models/product_model.dart (전체 교체)

class ProductModel {
  final int id;
  final DateTime createdAt;
  final String name;
  final String? description;
  final int price;
  final int? discountPrice; // 할인가
  final int shippingFee;   // 배송비
  final String? imageUrl;
  final int stockQuantity;
  final int categoryId;
  final bool isDisplayed;
  final bool isSoldOut;
  final String? productCode;
  final String? relatedProductCode;
  final bool isUserCreatable; // 사용자가 공구 생성 가능한지 여부

  ProductModel({
    required this.id,
    required this.createdAt,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    required this.shippingFee,
    this.imageUrl,
    required this.stockQuantity,
    required this.categoryId,
    required this.isDisplayed,
    required this.isSoldOut,
    this.productCode,
    this.relatedProductCode,
    required this.isUserCreatable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String? ?? '이름 없음',
      description: json['description'] as String?,
      price: json['total_price'] as int? ?? 0, // DB 컬럼명은 total_price
      discountPrice: json['discount_price'] as int?,
      shippingFee: json['shipping_fee'] as int? ?? 3000, // 기본 배송비 3000원
      imageUrl: json['image_url'] as String?,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 1, // 기본 카테고리 1
      isDisplayed: json['is_displayed'] as bool? ?? false,
      isSoldOut: json['is_sold_out'] as bool? ?? false,
      productCode: json['product_code'] as String?,
      relatedProductCode: json['related_product_code'] as String?,
      isUserCreatable: json['is_user_creatable'] as bool? ?? false,
    );
  }

  // copyWith는 객체의 일부 값만 변경하여 새로운 객체를 만들 때 유용합니다.
  ProductModel copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    String? description,
    int? price,
    int? discountPrice,
    int? shippingFee,
    String? imageUrl,
    int? stockQuantity,
    int? categoryId,
    bool? isDisplayed,
    bool? isSoldOut,
    String? productCode,
    String? relatedProductCode,
    bool? isUserCreatable,
  }) {
    return ProductModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      shippingFee: shippingFee ?? this.shippingFee,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      categoryId: categoryId ?? this.categoryId,
      isDisplayed: isDisplayed ?? this.isDisplayed,
      isSoldOut: isSoldOut ?? this.isSoldOut,
      productCode: productCode ?? this.productCode,
      relatedProductCode: relatedProductCode ?? this.relatedProductCode,
      isUserCreatable: isUserCreatable ?? this.isUserCreatable,
    );
  }
}