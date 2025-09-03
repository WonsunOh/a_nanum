// lib/core/utils/cache_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'logger.dart';

class CacheManager {
  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 문자열 저장
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// 문자열 조회
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// 정수 저장
  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  /// 정수 조회
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// 불린 저장
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// 불린 조회
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  /// JSON 객체 저장
  static Future<void> setJson(String key, Map<String, dynamic> json) async {
    await _prefs?.setString(key, jsonEncode(json));
  }

  /// JSON 객체 조회
  static Map<String, dynamic>? getJson(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        Logger.error('JSON 파싱 오류', e, null, 'CacheManager');
        return null;
      }
    }
    return null;
  }

  /// 키 삭제
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  /// 모든 캐시 삭제
  static Future<void> clear() async {
    await _prefs?.clear();
  }

  /// 만료 시간과 함께 데이터 저장
  static Future<void> setWithExpiry(String key, String value, Duration expiry) async {
    final expiryTime = DateTime.now().add(expiry).millisecondsSinceEpoch;
    final dataWithExpiry = {
      'value': value,
      'expiry': expiryTime,
    };
    await setJson(key, dataWithExpiry);
  }

  /// 만료 시간을 확인하여 데이터 조회
  static String? getWithExpiry(String key) {
    final data = getJson(key);
    if (data == null) return null;

    final expiryTime = data['expiry'] as int?;
    if (expiryTime == null) return null;

    if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
      // 만료됨 - 삭제 후 null 반환
      remove(key);
      return null;
    }

    return data['value'] as String?;
  }
}

// 캐시 키 상수들
class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String cartItems = 'cart_items';
  static const String recentlyViewed = 'recently_viewed';
  static const String categories = 'categories';
  static const String appSettings = 'app_settings';
}