// admin_web/lib/data/models/product_model.dart (전체 교체)

import 'dart:convert';

import 'product_option_model.dart';

class ProductModel {
  final int id;
  final DateTime createdAt;
  final String name;
  final String description;
  final int price;
  final String? imageUrl;
  final int stockQuantity;
  final int categoryId;
  final String? categoryPath; 
  final bool isDisplayed;
  final String? productCode; // ⭐️ 상품 코드 (null 가능)
  final String? relatedProductCode; // ⭐️ 연관 상품 코드 (null 가능)
  final bool isSoldOut;
  final List<ProductOption> options;
  final int shippingFee; // ⭐️ 배송비 필드 추가
  final Map<String, bool> tags;

  final int? discountPrice;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;
   

  ProductModel({
    required this.id,
    required this.createdAt,
    required this.name,
    String? description,
    required this.price,
    this.imageUrl,
    required this.stockQuantity,
    required this.categoryId,
    this.categoryPath,
    required this.isDisplayed,
    this.productCode,
    this.relatedProductCode,
    required this.isSoldOut,
    this.options = const [],
    required this.shippingFee,
    required this.tags,

    this.discountPrice,
    this.discountStartDate,
    this.discountEndDate,

    
  }) : description = description ?? ''; // ⭐️ 만약 null이면 빈 문자열로 초기화

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    
    // ⭐️ description을 처리하는 로직을 추가합니다.
    String? description;
    if (json['description'] != null) {
      // 데이터가 문자열이 아니면 (List나 Map이면) JSON 문자열로 변환합니다.
      if (json['description'] is! String) {
        description = jsonEncode(json['description']);
      } else {
        description = json['description'];
      }
    }    
    return ProductModel(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String? ?? '이름 없음',
      description: description,
      price: json['total_price'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 1, // 카테고리가 없으면 기본값 1
      categoryPath:json['category_path'] as String?, 
      isDisplayed: json['is_displayed'] as bool? ?? false,
      productCode: json['product_code'] as String?,
      relatedProductCode: json['related_product_code'] as String?,
      isSoldOut: json['is_sold_out'] as bool? ?? false,
      shippingFee: json['shipping_fee'] as int? ?? 3000,
      tags: Map<String, bool>.from(json['tags'] ?? {}),

       discountPrice: json['discount_price'] as int?,
      discountStartDate: json['discount_start_date'] != null
          ? DateTime.parse(json['discount_start_date'])
          : null,
      discountEndDate: json['discount_end_date'] != null
          ? DateTime.parse(json['discount_end_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'total_price': price,
      'discount_price': discountPrice, 
      'discount_start_date': discountStartDate?.toIso8601String(),
      'discount_end_date': discountEndDate?.toIso8601String(),
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'is_displayed': isDisplayed,
      'product_code': productCode,
      'related_product_code': relatedProductCode,
      'is_sold_out': isSoldOut,
      'shipping_fee': shippingFee,
      'tags': tags,
      // ⭐️ toJson에 날짜 필드를 DB가 이해하는 문자열 형식으로 변환하여 추가합니다.
      
    };
  }

  ProductModel copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    String? description,
    int? price,
    int? discountPrice,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
    String? imageUrl,
    int? stockQuantity,
    int? categoryId,
    bool? isDisplayed,
    String? productCode,
    String? relatedProductCode,
    bool? isSoldOut,
    int? shippingFee,
    
    Map<String, bool>? tags,
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
      shippingFee: shippingFee ?? this.shippingFee,
      tags: tags ?? this.tags,
      discountPrice: discountPrice ?? this.discountPrice,
      discountStartDate: discountStartDate ?? this.discountStartDate,
      discountEndDate: discountEndDate ?? this.discountEndDate,
    );
  }
}