import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/main_layout.dart';
import '../viewmodel/reply_template_viewmodel.dart';

class ReplyTemplateScreen extends ConsumerWidget {
  const ReplyTemplateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(replyTemplateViewModelProvider);

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('답변 템플릿 관리', style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('새 템플릿 추가'),
                  onPressed: () { /* TODO: 템플릿 추가/수정 다이얼로그 띄우기 */ },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: templatesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
                data: (templates) => ListView.builder(
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return ListTile(
                      title: Text(template.title),
                      subtitle: Text(template.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () { /* 수정 */ }),
                          IconButton(icon: const Icon(Icons.delete), onPressed: () { /* 삭제 */ }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}