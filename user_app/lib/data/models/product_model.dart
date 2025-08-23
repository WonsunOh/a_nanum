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

  ProductModel({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.stockQuantity,
    required this.categoryId,
    required this.isDisplayed,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int, // id는 항상 존재해야 함
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String? ?? '이름 없음',
      description: json['description'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      // ⭐️ category_id가 null일 경우, 기본값 1을 사용하도록 수정
      //    (또는 다른 유효한 기본 카테고리 ID로 설정)
      categoryId: json['category_id'] as int? ?? 1,
      isDisplayed: json['is_displayed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'is_displayed': isDisplayed,
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
    );
  }
}