// admin_web/lib/data/models/product_variant_model.dart (새 파일)

// 최종 조합 (SKU) 모델 ('레드 / S')
class ProductVariant {
  final int? id;
  String name;
  int additionalPrice;
  int stockQuantity;

  ProductVariant({
    this.id,
    required this.name,
    this.additionalPrice = 0,
    this.stockQuantity = 0,
  });
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