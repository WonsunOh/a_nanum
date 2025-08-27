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
    return Inquiry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      status: json['status'],
      reply: json['reply'],
      authorName: json['profiles']?['username'] ?? '알 수 없음',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}