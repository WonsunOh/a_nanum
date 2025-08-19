class Product {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int totalPrice;
  final int? categoryId; // 💡 categoryId도 추가해주는 것이 좋습니다.
  final String? externalProductId; // 💡 이 필드를 추가합니다.
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.totalPrice,
    this.categoryId, // 💡 생성자에 추가
    this.externalProductId, // 💡 생성자에 추가
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      totalPrice: json['total_price'],
      categoryId: json['category_id'], // 💡 fromJson에 추가
      externalProductId: json['external_product_id'], // 💡 fromJson에 추가
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}