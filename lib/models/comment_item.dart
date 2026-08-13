class CommentItem {
  final String id;
  final String username;
  final String profilePicture;
  final String text;
  final bool hasSpoiler;
  final DateTime createdAt;

  CommentItem({
    required this.id,
    required this.username,
    required this.profilePicture,
    required this.text,
    required this.hasSpoiler,
    required this.createdAt,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    final userMap = json['userId'] is Map ? json['userId'] : {};
    return CommentItem(
      id: json['_id'] ?? '',
      username: userMap['username'] ?? json['username'] ?? 'Anonymous',
      profilePicture: userMap['profilePicture'] ?? json['profilePicture'] ?? '',
      text: json['text'] ?? '',
      hasSpoiler: json['hasSpoiler'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'profilePicture': profilePicture,
        'text': text,
        'hasSpoiler': hasSpoiler,
        'createdAt': createdAt.toIso8601String(),
      };
}