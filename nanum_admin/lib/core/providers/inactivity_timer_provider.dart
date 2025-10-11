// lib/core/providers/inactivity_timer_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inactivity_timer_provider.g.dart';

@riverpod
class InactivityTimer extends _$InactivityTimer {
  Timer? _timer;
  bool _disposed = false;
  
  // 비활성 시간 설정 (3분)
  static const Duration inactivityDuration = Duration(minutes: 1);
  
  @override
  DateTime build() {
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
    if (_disposed) return;
    
    try {
      state = DateTime.now();
      _timer?.cancel();
      
      _timer = Timer(inactivityDuration, () {
        if (!_disposed) {
          _onInactivityTimeout();
        }
      });
      
      if (kDebugMode) {
        debugPrint('🔄 Inactivity timer reset at ${DateTime.now()}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error resetting timer: $e');
      }
    }
  }

  // 비활성 타임아웃 처리
  void _onInactivityTimeout() {
    if (_disposed) return;
    
    if (kDebugMode) {
      debugPrint('⏰ Inactivity timeout - triggering logout at ${DateTime.now()}');
    }
    
    try {
      // ✅ 로그아웃 트리거 Provider 무효화
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

// ✅ 수정: 매번 새로운 DateTime 값을 반환하도록 변경
@riverpod
DateTime inactivityLogoutTrigger(Ref ref) {
  if (kDebugMode) {
    debugPrint('🚨 Logout trigger activated at ${DateTime.now()}');
  }
  return DateTime.now(); // ✅ 매번 다른 값 반환
}