// user_app/lib/data/models/level_upgrade_request_model.dart
class LevelUpgradeRequest {
  final int id;
  final String userId;
  final int currentLevel;
  final int requestedLevel;
  final String reason;
  final String? additionalInfo;
  final String status; // pending, approved, rejected
  final String? adminComment;
  final DateTime createdAt;
  final DateTime? processedAt;

  LevelUpgradeRequest({
    required this.id,
    required this.userId,
    required this.currentLevel,
    required this.requestedLevel,
    required this.reason,
    this.additionalInfo,
    required this.status,
    this.adminComment,
    required this.createdAt,
    this.processedAt,
  });

  factory LevelUpgradeRequest.fromJson(Map<String, dynamic> json) {
    return LevelUpgradeRequest(
      id: json['id'],
      userId: json['user_id'],
      currentLevel: json['current_level'],
      requestedLevel: json['requested_level'],
      reason: json['reason'],
      additionalInfo: json['additional_info'],
      status: json['status'],
      adminComment: json['admin_comment'],
      createdAt: DateTime.parse(json['created_at']),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'current_level': currentLevel,
      'requested_level': requestedLevel,
      'reason': reason,
      'additional_info': additionalInfo,
    };
  }
}