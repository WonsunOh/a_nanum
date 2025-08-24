// category_model.dart (admin_web, user_app 공통)

class CategoryModel {
  final int id;
  final String name;
  final DateTime createdAt;
  final int? parentId; 
  // ⭐️ 3단계 UI 구현을 위해 서브 카테고리 리스트를 임시로 담을 공간
  final List<CategoryModel> children;

  CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.parentId,
    List<CategoryModel>? children, // Nullable 파라미터로 받아서
  }) : children = children ?? []; // null이면 비어있는 '가변' 리스트로 초기화


  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      parentId: json['parent_id'] as int?, // ⭐️ fromJson에 추가
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parent_id': parentId, // ⭐️ toJson에 추가
    };
  }
}