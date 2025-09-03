class PaymentConfig {
  static const String storeId = 'iamport00m'; // 테스트용
  static const String channelKey = 'channel-key-6b4aa7b6-4107-4b0a-b9d0-c8c3c2feef9b'; // 테스트용
  
  // 실제 운영 시에는 .env 파일에서 로드
  // static const String storeId = String.fromEnvironment('PORTONE_STORE_ID');
  // static const String channelKey = String.fromEnvironment('PORTONE_CHANNEL_KEY');
}