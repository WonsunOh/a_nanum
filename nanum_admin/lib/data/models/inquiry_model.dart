class Inquiry {
  final int id;
  final String title;
  final String content;
  final String status;
  final String? reply;
  final String authorName;
  final DateTime createdAt;

  Inquiry({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    this.reply,
    required this.authorName,
    required this.createdAt,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    final profileData = json['profiles'] as Map<String, dynamic>?;

    DateTime parsedDate;
    try {
      // json['created_at']이 null이 아니고, 유효한 문자열일 때만 파싱
      if (json['created_at'] != null && json['created_at'] is String) {
        parsedDate = DateTime.parse(json['created_at']);
      } else {
        // 그 외의 모든 경우 (null, 다른 타입 등)에는 현재 시간을 기본값으로 사용
        parsedDate = DateTime.now();
      }
    } catch (e) {
      // 파싱 중 에러가 발생해도 현재 시간을 기본값으로 사용하여 앱이 멈추는 것을 방지
      parsedDate = DateTime.now();
    }
    return Inquiry(
      id: json['id'],
      title: json['title'] ?? '제목 없음', // ⭐️ 다른 필드들도 방어 코드 추가
      content: json['content'] ?? '내용 없음',
      status: json['status'] ?? 'pending',
      reply: json['reply'],
      authorName: profileData?['username'] as String? ?? '알 수 없음', 
      createdAt: parsedDate,
    );
  }
}