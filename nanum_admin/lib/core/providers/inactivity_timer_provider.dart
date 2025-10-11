// lib/core/providers/inactivity_timer_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inactivity_timer_provider.g.dart';

@riverpod
class InactivityTimer extends _$InactivityTimer {
  Timer? _timer;
  bool _disposed = false; // ⭐️ dispose 상태를 추적하는 플래그
  
  // ⭐️ 비활성 시간 설정 (30분)
  static const Duration inactivityDuration = Duration(minutes: 30);
  
  @override
  DateTime build() {
    // 초기 활동 시간 설정
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
      _timer = null;
    });
    
    _disposed = false;
    return DateTime.now();
  }

  // 사용자 활동 감지 시 호출
  void resetTimer() {
    if (_disposed) return; // ⭐️ disposed 체크
    
    try {
      state = DateTime.now();
      _timer?.cancel();
      
      _timer = Timer(inactivityDuration, () {
        if (!_disposed) {
          _onInactivityTimeout();
        }
      });
      
      if (kDebugMode) {
        debugPrint('🔄 Inactivity timer reset');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error resetting timer: $e');
      }
    }
  }

  // 비활성 타임아웃 처리
  void _onInactivityTimeout() {
    if (_disposed) return; // ⭐️ disposed 체크
    
    if (kDebugMode) {
      debugPrint('⏰ Inactivity timeout - logging out');
    }
    
    try {
      // 로그아웃 트리거 Provider 무효화
      ref.invalidate(inactivityLogoutTriggerProvider);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error triggering logout: $e');
      }
    }
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    
    if (kDebugMode) {
      debugPrint('🛑 Inactivity timer cancelled');
    }
  }
}

// 로그아웃 트리거 Provider
@riverpod
bool inactivityLogoutTrigger(InactivityLogoutTriggerRef ref) {
  return true;
}