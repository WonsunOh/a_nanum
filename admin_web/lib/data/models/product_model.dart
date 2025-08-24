// admin_web/lib/data/models/product_model.dart (전체 교체)

class ProductModel {
  final int id;
  final DateTime createdAt;
  final String name;
  final String description;
  final int price;
  final String? imageUrl;
  final int stockQuantity;
  final int categoryId;
  final bool isDisplayed;
  final String? productCode; // ⭐️ 상품 코드 (null 가능)
  final String? relatedProductCode; // ⭐️ 연관 상품 코드 (null 가능)
  final bool isSoldOut;

  ProductModel({
    required this.id,
    required this.createdAt,
    required this.name,
    String? description,
    required this.price,
    this.imageUrl,
    required this.stockQuantity,
    required this.categoryId,
    required this.isDisplayed,
    this.productCode,
    this.relatedProductCode,
    required this.isSoldOut,
  }) : description = description ?? ''; // ⭐️ 만약 null이면 빈 문자열로 초기화

  factory ProductModel.fromJson(Map<String, dynamic> json) {
        
    return ProductModel(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String? ?? '이름 없음',
      description: json['description'] as String? ?? '설명 없음',
      price: json['total_price'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 1, // 카테고리가 없으면 기본값 1
      isDisplayed: json['is_displayed'] as bool? ?? false,
      productCode: json['product_code'] as String?,
      relatedProductCode: json['related_product_code'] as String?,
      isSoldOut: json['is_sold_out'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'total_price': price,
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'is_displayed': isDisplayed,
      'product_code': productCode,
      'related_product_code': relatedProductCode,
      'is_sold_out': isSoldOut,
    };
  }

  ProductModel copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    String? description,
    int? price,
    String? imageUrl,
    int? stockQuantity,
    int? categoryId,
    bool? isDisplayed,
    String? productCode,
    String? relatedProductCode,
    bool? isSoldOut,
  }) {
    return ProductModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      categoryId: categoryId ?? this.categoryId,
      isDisplayed: isDisplayed ?? this.isDisplayed,
      productCode: productCode ?? this.productCode,
      relatedProductCode: relatedProductCode ?? this.relatedProductCode,
      isSoldOut: isSoldOut ?? this.isSoldOut,
    );
  }
}