class UserProfile {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String bio;
  final String profilePicture;
  final String role; // 'user', 'admin', or 'guest'

  UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.bio,
    required this.profilePicture,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';
  bool get isGuest => role == 'guest';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'username': username,
        'email': email,
        'bio': bio,
        'profilePicture': profilePicture,
        'role': role,
      };
}