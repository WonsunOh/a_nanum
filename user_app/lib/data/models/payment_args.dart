// lib/data/models/payment_args.dart (새 파일)
class PaymentArgs {
  final int totalAmount;
  final String orderName;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String customerEmail;

  PaymentArgs({
    required this.totalAmount,
    required this.orderName,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerEmail,
  });
}