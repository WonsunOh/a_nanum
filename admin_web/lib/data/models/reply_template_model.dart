class ReplyTemplate {
  final int id;
  final String title;
  final String content;

  ReplyTemplate({required this.id, required this.title, required this.content});

  factory ReplyTemplate.fromJson(Map<String, dynamic> json) {
    return ReplyTemplate(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }
}