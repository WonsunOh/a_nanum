// admin_web/lib/data/models/product_option_model.dart (새 파일)

// '레드', 'S' 등 개별 옵션 항목
class ProductOptionItem {
  final int? id;
  final String name;
  final int additionalPrice;
  final int stockQuantity;

  ProductOptionItem({
    this.id,
    required this.name,
    required this.additionalPrice,
    required this.stockQuantity,
  });
}

// '색상', '사이즈' 등 옵션 그룹
class ProductOption {
  final int? id;
  final String name;
  final List<ProductOptionItem> items;

  ProductOption({
    this.id,
    required this.name,
    this.items = const [],
  });
}