// nanum_admin/lib/features/settings/viewmodel/settings_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/utils/logger.dart';
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

  // ✅ 1단계: 기존 기능 + 에러 처리 + 로깅
  Future<void> fetchSettings() async {
    try {
      Logger.debug('설정 목록 로드 시작', 'SettingsViewModel');
      
      state = const AsyncValue.loading();
      final settingsList = await _repository.fetchSettings();
      final settingsMap = {for (var s in settingsList) s.key: s};

      // 컨트롤러 초기화
      settingsMap.forEach((key, setting) {
        controllers[key] = TextEditingController(text: setting.value ?? '');
      });

      state = AsyncValue.data(settingsMap);
      Logger.info('설정 로드 완료: ${settingsMap.length}개', 'SettingsViewModel');
    } catch (error, stackTrace) {
      Logger.error('설정 로드 실패', error, stackTrace, 'SettingsViewModel');
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(error), stackTrace);
    }
  }

  Future<bool> saveSettings() async {
    if (state.value == null) return false;

    try {
      Logger.debug('설정 저장 시작', 'SettingsViewModel');
      
      final updatedValues = <String, String>{};
      controllers.forEach((key, controller) {
        if (controller.text != state.value![key]?.value) {
          updatedValues[key] = controller.text;
        }
      });

      if (updatedValues.isEmpty) {
        Logger.info('변경된 설정이 없습니다', 'SettingsViewModel');
        return true;
      }

      await _repository.updateSettings(updatedValues);
      await fetchSettings(); // 저장 후 데이터 다시 불러오기
      
      Logger.info('설정 저장 완료: ${updatedValues.length}개 항목', 'SettingsViewModel');
      return true;
    } catch (error, stackTrace) {
      Logger.error('설정 저장 실패', error, stackTrace, 'SettingsViewModel');
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