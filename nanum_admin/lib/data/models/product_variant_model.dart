// admin_web/lib/data/models/product_variant_model.dart (새 파일)

// 최종 조합 (SKU) 모델 ('레드 / S')
class ProductVariant {
  final int? id;
  final int? productId;
  final String name;
  int additionalPrice;
  int stockQuantity;

  ProductVariant({
    this.id,
    this.productId,
    required this.name,
    this.additionalPrice = 0,
    this.stockQuantity = 0,
  });

  // ✅ fromJson 메서드 추가
  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as int?,
      productId: json['product_id'] as int?,
      name: json['name'] as String,
      additionalPrice: json['additional_price'] as int? ?? 0,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
    );
  }

  // ✅ toJson 메서드도 추가 (필요한 경우)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'additional_price': additionalPrice,
      'stock_quantity': stockQuantity,
    };
  }

  ProductVariant copyWith({
    int? id,
    int? productId,
    String? name,
    int? additionalPrice,
    int? stockQuantity,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      additionalPrice: additionalPrice ?? this.additionalPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

}



// 옵션 값 모델 ('레드', 'S')
class OptionValue {
  final int? id;
  String value;

  OptionValue({this.id, required this.value});
}

// 옵션 그룹 모델 ('색상', '사이즈')
class OptionGroup {
  final int? id;
  String name;
  List<OptionValue> values;

  OptionGroup({
    this.id,
    required this.name,
    this.values = const [],
  });
}