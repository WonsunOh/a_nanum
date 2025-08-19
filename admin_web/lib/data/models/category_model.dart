
import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final int? parentId; // 💡 이 필드를 추가

  const Category({
    required this.id,
    required this.name,
    this.parentId, // 💡 생성자에 추가
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      parentId: json['parent_id'], // 💡 fromJson 로직에 추가
    );
  }

  // 💡 Equatable을 사용하면 이 한 줄만 추가하면 됩니다.
  @override
  List<Object?> get props => [id];

}