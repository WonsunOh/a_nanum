// admin_web/lib/core/admin_menu_item.dart (전체 교체)

import 'package:flutter/material.dart';

class AdminMenuItem {
  final String title;
  final IconData? icon;
  final String route;
  // ⭐️ 서브 메뉴들을 담을 리스트 추가
  final List<AdminMenuItem> children;

  AdminMenuItem({
    required this.title,
    this.icon,
    this.route = '',
    this.children = const [], // ⭐️ 기본값은 빈 리스트
  });
}