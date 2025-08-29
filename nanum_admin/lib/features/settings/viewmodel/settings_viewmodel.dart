// nanum_admin/lib/features/settings/viewmodel/settings_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/settings_model.dart';
import '../../../data/repositories/settings_repository.dart';

// 뷰모델 프로바이더
final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, AsyncValue<Map<String, Setting>>>(
        (ref) {
  return SettingsViewModel(ref.watch(settingsRepositoryProvider));
});

class SettingsViewModel extends StateNotifier<AsyncValue<Map<String, Setting>>> {
  final SettingsRepository _repository;
  // UI에서 사용할 TextEditingController들을 관리
  final Map<String, TextEditingController> controllers = {};

  SettingsViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    state = const AsyncValue.loading();
    try {
      final settingsList = await _repository.fetchSettings();
      final settingsMap = {for (var s in settingsList) s.key: s};

      // 컨트롤러 초기화
      settingsMap.forEach((key, setting) {
        controllers[key] = TextEditingController(text: setting.value ?? '');
      });

      state = AsyncValue.data(settingsMap);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveSettings() async {
    if (state.value == null) return false;

    final updatedValues = <String, String>{};
    controllers.forEach((key, controller) {
      // 기존 값과 다를 경우에만 업데이트 목록에 추가
      if (controller.text != state.value![key]?.value) {
        updatedValues[key] = controller.text;
      }
    });

    if (updatedValues.isEmpty) return true; // 변경사항 없음

    try {
      await _repository.updateSettings(updatedValues);
      await fetchSettings(); // 저장 후 데이터 다시 불러오기
      return true;
    } catch (e) {
      debugPrint('설정 저장 실패: $e');
      return false;
    }
  }

  // 뷰모델이 소멸될 때 컨트롤러들도 정리
  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}