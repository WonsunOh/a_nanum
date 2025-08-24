// user_app/lib/data/models/order_item_model.dart

class OrderItemModel {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final int pricePerItem;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.pricePerItem,
  });
}