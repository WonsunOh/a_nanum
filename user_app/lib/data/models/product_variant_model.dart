// user_app/lib/data/models/product_variant_model.dart (새 파일)

// 최종 조합 (SKU) 모델 ('레드 / S')
class ProductVariant {
  final int id;
  final String name;
  final int additionalPrice;
  final int stockQuantity;

  ProductVariant({
    required this.id,
    required this.name,
    this.additionalPrice = 0,
    this.stockQuantity = 0,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      name: json['name'],
      additionalPrice: json['additional_price'] ?? 0,
      stockQuantity: json['stock_quantity'] ?? 0,
    );
  }
}

// 옵션 값 모델 ('레드', 'S')
class OptionValue {
  final int id;
  final String value;

  OptionValue({required this.id, required this.value});

   factory OptionValue.fromJson(Map<String, dynamic> json) {
    return OptionValue(
      id: json['id'],
      value: json['value'],
    );
  }
}

// 옵션 그룹 모델 ('색상', '사이즈')
class OptionGroup {
  final int id;
  final String name;
  final List<OptionValue> values;

  OptionGroup({
    required this.id,
    required this.name,
    this.values = const [],
  });
}