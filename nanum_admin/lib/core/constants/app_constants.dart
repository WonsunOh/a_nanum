// lib/core/constants/app_constants.dart
class AppConstants {
  // 앱 정보
  static const String appName = '나눔 스토어';
  static const String appVersion = '1.0.0';
  
  // API 관련
  static const int apiTimeoutSeconds = 30;
  static const int retryCount = 3;
  
  // 페이징
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // 가격 관련
  static const int defaultShippingFee = 3000;
  static const int freeShippingThreshold = 30000;
  static const int maxPrice = 10000000;
  
  // 이미지 관련
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
  
  // 공동구매 관련
  static const int minGroupBuyParticipants = 2;
  static const int maxGroupBuyParticipants = 100;
  static const int defaultGroupBuyDays = 7;
  
  // 카트 관련
  static const int maxCartItemQuantity = 999;
  static const int minCartItemQuantity = 1;
}