import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/main_layout.dart';
import '../../../data/models/inquiry_model.dart';
import '../viewmodel/inquiry_viewmodel.dart';

class InquiryManagementScreen extends ConsumerWidget {
  const InquiryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiriesAsync = ref.watch(inquiryViewModelProvider);

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('고객 문의 관리', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Expanded(
              child: inquiriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('오류가 발생했습니다: $e')),
                data: (inquiries) {
                  if (inquiries.isEmpty) {
                    return const Center(child: Text('접수된 문의가 없습니다.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.read(inquiryViewModelProvider.notifier).fetchAllInquiries(),
                    child: ListView.separated(
                      itemCount: inquiries.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final inquiry = inquiries[index];
                        final isAnswered = inquiry.status == 'answered';
                        return ListTile(
                          leading: Icon(
                            isAnswered ? Icons.check_circle : Icons.hourglass_top,
                            color: isAnswered ? Colors.green : Colors.orange,
                          ),
                          title: Text(inquiry.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('문의자: ${inquiry.authorName} | 접수일: ${DateFormat('yyyy-MM-dd').format(inquiry.createdAt)}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _showInquiryDialog(context, ref, inquiry);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 문의 상세 및 답변 다이얼로그
  void _showInquiryDialog(BuildContext context, WidgetRef ref, Inquiry inquiry) {
    final replyController = TextEditingController(text: inquiry.reply ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('문의 내용 확인 및 답변'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('문의자: ${inquiry.authorName}'),
                    const SizedBox(height: 4),
                    Text('접수일: ${DateFormat('yyyy-MM-dd HH:mm').format(inquiry.createdAt)}'),
                    const Divider(height: 24),
                    Text('제목', style: Theme.of(context).textTheme.labelLarge),
                    Text(inquiry.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Text('내용', style: Theme.of(context).textTheme.labelLarge),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(inquiry.content),
                    ),
                    const Divider(height: 24),
                    TextFormField(
                      controller: replyController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: '답변 작성',
                        hintText: '여기에 답변을 입력하세요...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '답변을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final success = await ref.read(inquiryViewModelProvider.notifier)
                      .submitReply(inquiryId: inquiry.id, reply: replyController.text);
                  
                  if (success && context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('답변이 등록되었습니다.')),
                    );
                  }
                }
              },
              child: const Text('답변 등록'),
            ),
          ],
        );
      },
    );
  }
}