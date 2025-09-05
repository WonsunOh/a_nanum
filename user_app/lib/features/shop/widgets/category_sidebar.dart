// user_app/lib/features/shop/widgets/category_sidebar.dart (새 파일)

import 'package:flutter/material.dart';
import '../../../data/models/category_model.dart';

class CategorySidebar extends StatefulWidget {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  State<CategorySidebar> createState() => _CategorySidebarState();
}

class _CategorySidebarState extends State<CategorySidebar> {
  final Set<int> _expandedCategories = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Icon(Icons.category, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Text(
                '카테고리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
        
        // 전체 상품 버튼
        ListTile(
          leading: const Icon(Icons.apps, color: Colors.grey),
          title: const Text(
            '전체 상품',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          selected: widget.selectedCategoryId == null,
          selectedTileColor: Colors.blue.shade50,
          onTap: () => widget.onCategorySelected(null),
        ),
        
        const Divider(height: 1),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: widget.categories.map((category) {
              return _buildCategoryItem(category, 0);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(CategoryModel category, int depth) {
    final isSelected = widget.selectedCategoryId == category.id;
    final hasChildren = category.children.isNotEmpty;
    final isExpanded = _expandedCategories.contains(category.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: depth * 16.0),
          child: ListTile(
            dense: depth > 0,
            contentPadding: EdgeInsets.only(
              left: 16 + (depth * 8.0),
              right: 16,
            ),
            leading: hasChildren
                ? Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: Colors.grey.shade600,
                  )
                : Icon(
                    Icons.fiber_manual_record,
                    size: 8,
                    color: isSelected ? Colors.blue : Colors.grey.shade400,
                  ),
            title: Text(
              category.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue.shade700 : Colors.black87,
                fontSize: depth > 0 ? 14 : 15,
              ),
            ),
            selected: isSelected,
            selectedTileColor: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onTap: () {
              if (hasChildren) {
                setState(() {
                  if (isExpanded) {
                    _expandedCategories.remove(category.id);
                  } else {
                    _expandedCategories.add(category.id);
                  }
                });
              }
              widget.onCategorySelected(category.id);
            },
          ),
        ),
        
        if (hasChildren && isExpanded)
          ...category.children.map((child) {
            return _buildCategoryItem(child, depth + 1);
          }),
      ],
    );
  }
}