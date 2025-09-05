// user_app/lib/data/models/category_model.dart (새 파일)

class CategoryModel {
  final int id;
  final String name;
  final DateTime createdAt;
  final int? parentId;
  final List<CategoryModel> children;

  CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.parentId,
    List<CategoryModel>? children,
  }) : children = children ?? [];

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      parentId: json['parent_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parent_id': parentId,
    };
  }
}