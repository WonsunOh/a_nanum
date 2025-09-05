// core/utils/navigation_utils.dart (새 파일)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SafeNavigation {
  static void go(BuildContext context, String location) {
    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(location);
        }
      });
    }
  }
}