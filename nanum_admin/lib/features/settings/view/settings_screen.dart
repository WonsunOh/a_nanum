// nanum_admin/lib/features/settings/view/settings_screen.dart (전체 수정)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/main_layout.dart';
import '../viewmodel/settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsViewModelProvider);
    final settingsViewModel = ref.read(settingsViewModelProvider.notifier);

    // 각 섹션에 표시할 설정 키 목록
    const Map<String, List<String>> sections = {
      '기본 정책': ['shipping_fee'],
      '회사 정보': [
        'company_name',
        'business_number',
        'ceo_name',
        'address',
        'telecommunication_sales_number',
        'customer_service_phone',
        'customer_service_email'
      ],
      '디자인 설정': ['logo_image_url'],
    };

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('쇼핑몰 전체 설정',
                    style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('변경사항 저장'),
                  onPressed: () async {
                    final success = await settingsViewModel.saveSettings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            success ? '성공적으로 저장되었습니다.' : '저장에 실패했습니다.'),
                        backgroundColor:
                            success ? Colors.green : Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: settingsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('에러 발생: $err')),
                data: (settings) {
                  return ListView(
                    // sections 맵을 기반으로 동적으로 UI를 생성
                    children: sections.entries.map((sectionEntry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(sectionEntry.key),
                          ...sectionEntry.value.map((settingKey) {
                            // ⭐️ 핵심: settings 맵에 해당 키가 있을 때만 위젯을 생성
                            if (settings.containsKey(settingKey) &&
                                settingsViewModel.controllers.containsKey(settingKey)) {
                              final setting = settings[settingKey]!;
                              return _buildTextField(
                                label: setting.comment ?? settingKey, // DB의 comment를 label로 사용
                                controller: settingsViewModel.controllers[settingKey]!,
                              );
                            }
                            // 해당 키가 없으면 아무것도 그리지 않음
                            return const SizedBox.shrink();
                          }),
                          const SizedBox(height: 32),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
          ),
        ],
      ),
    );
  }
}