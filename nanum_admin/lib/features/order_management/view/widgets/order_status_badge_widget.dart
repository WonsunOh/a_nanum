import 'package:flutter/material.dart';
import '../../../../data/models/order_model.dart';

/// 주문 상태 배지 위젯
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final double? fontSize;
  final double? dotSize;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.dotSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize ?? 8,
            height: dotSize ?? 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              color: status.color,
              fontWeight: FontWeight.bold,
              fontSize: fontSize ?? 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 취소/반품 상태 배지 위젯
class CancellationStatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const CancellationStatusBadge({
    super.key,
    required this.status,
    this.fontSize,
  });

  ({Color color, String label}) get _statusConfig {
    return switch (status) {
      'pending' => (color: Colors.orange, label: '대기중'),
      'approved' => (color: Colors.green, label: '승인됨'),
      'rejected' => (color: Colors.red, label: '거절됨'),
      _ => (color: Colors.grey, label: status),
    };
  }

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color, width: 1.5),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? 12,
        ),
      ),
    );
  }
}

/// 취소 유형 배지 위젯
class CancellationTypeBadge extends StatelessWidget {
  final bool isFullCancellation;
  final double? fontSize;

  const CancellationTypeBadge({
    super.key,
    required this.isFullCancellation,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final color = isFullCancellation ? Colors.red : Colors.deepOrange;
    final label = isFullCancellation ? '전체취소' : '부분취소';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? 12,
        ),
      ),
    );
  }
}