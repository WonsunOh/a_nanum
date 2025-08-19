
import 'group_buy_model.dart';

class MyParticipation {
  final int quantity;
  final GroupBuy groupBuy;

  MyParticipation({
    required this.quantity,
    required this.groupBuy,
  });

  factory MyParticipation.fromJson(Map<String, dynamic> json) {
    return MyParticipation(
      quantity: json['quantity'],
      // participants 테이블에 join된 group_buys 데이터를 GroupBuy 모델로 변환
      groupBuy: GroupBuy.fromJson(json['group_buys']),
    );
  }
}