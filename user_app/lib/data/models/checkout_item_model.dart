// lib/data/models/checkout_item.dart (새 파일)

import 'product_model.dart';
import 'product_variant_model.dart';
// ⭐️ 위 import 경로는 실제 프로젝트 구조에 맞게 수정해주세요.

// 주문/결제 페이지로 전달하기 위한 임시 데이터 클래스
class CheckoutItemModel {
  final ProductModel product;
  final ProductVariant? selectedVariant;
  final int quantity;

  CheckoutItemModel({
    required this.product,
    this.selectedVariant,
    required this.quantity,
  });

  // 총 가격 계산 등 필요한 로직
  int get totalPrice {
      final basePrice = product.discountPrice ?? product.price;
      final variantPrice = selectedVariant?.additionalPrice ?? 0;
      return (basePrice + variantPrice) * quantity;
  }
}