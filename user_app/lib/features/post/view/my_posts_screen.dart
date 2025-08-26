// user_app/lib/features/post/view/my_posts_screen.dart (새 파일)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPostsScreen extends ConsumerWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 쓴 글'),
      ),
      body: Center(
        child: Text('내가 쓴 글 목록이 여기에 표시됩니다.'),
      ),
    );
  }
}