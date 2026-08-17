class CommentItem {
  final String id;
  final String userId;
  final String username;
  final String profilePicture;
  final String imdbId;
  final String text;
  final bool hasSpoiler;
  final DateTime createdAt;

  CommentItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.profilePicture,
    required this.imdbId,
    required this.text,
    required this.hasSpoiler,
    required this.createdAt,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    // Backend populates 'userId' as an object holding the user's details
    final user = json['userId'] is Map ? json['userId'] : {};
    
    return CommentItem(
      // FIX: Ensure we map MongoDB's "_id" correctly so the delete route works!
      id: json['_id'] ?? json['id'] ?? '',
      userId: user['_id'] ?? json['userId'] ?? '',
      username: user['username'] ?? 'Unknown User',
      profilePicture: user['profilePicture'] ?? '',
      imdbId: json['imdbId'] ?? '',
      text: json['text'] ?? '',
      hasSpoiler: json['hasSpoiler'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}