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
    return Inquiry(
      id: json['id'],
      title: json['title'] ?? '제목 없음', // ⭐️ 다른 필드들도 방어 코드 추가
      content: json['content'] ?? '내용 없음',
      status: json['status'] ?? 'pending',
      reply: json['reply'],
      authorName: profileData?['username'] as String? ?? '알 수 없음', 
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}