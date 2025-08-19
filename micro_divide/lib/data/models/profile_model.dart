class Profile {
  final String id;
  final String username;
  final int level; 
  final int points; 

  Profile({
    required this.id,
    required this.username,
    required this.level,
    required this.points,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'],
      level: json['level'] ?? 1, 
      points: json['points'] ?? 0,
    );
  }
}