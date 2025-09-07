// user_app/lib/data/models/direct_purchase_item_model.dart (새 파일 생성)

import 'product_model.dart';
import 'product_variant_model.dart';

/// 바로구매 시 사용할 상품 정보 모델
class DirectPurchaseItem {
  final ProductModel product;
  final ProductVariant? selectedVariant;
  final int quantity;
  final String? variantName;
  final int? variantAdditionalPrice;

  DirectPurchaseItem({
    required this.product,
    this.selectedVariant,
    required this.quantity,
    this.variantName,
    this.variantAdditionalPrice,
  });

  /// 단일 상품의 총 가격 계산
  int get totalPrice {
    final basePrice = product.discountPrice ?? product.price;
    final variantPrice = variantAdditionalPrice ?? selectedVariant?.additionalPrice ?? 0;
    return (basePrice + variantPrice) * quantity;
  }

  /// 기본 가격 (옵션 제외)
  int get basePrice {
    return product.discountPrice ?? product.price;
  }

  /// 옵션 추가 가격
  int get additionalPrice {
    return variantAdditionalPrice ?? selectedVariant?.additionalPrice ?? 0;
  }

  /// 단위 가격 (기본가격 + 옵션가격)
  int get unitPrice {
    return basePrice + additionalPrice;
  }

  @override
  String toString() {
    return 'DirectPurchaseItem(product: ${product.name}, variant: $variantName, quantity: $quantity, totalPrice: $totalPrice)';
  }
}