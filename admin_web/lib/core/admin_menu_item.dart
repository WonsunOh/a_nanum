import 'package:flutter/material.dart';

class AdminMenuItem {
  final String title;
  final IconData icon;
  final String route;
  final List<AdminMenuItem> subItems; // 하위 메뉴 리스트

  const AdminMenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.subItems = const [], // 기본값은 빈 리스트
  });
}