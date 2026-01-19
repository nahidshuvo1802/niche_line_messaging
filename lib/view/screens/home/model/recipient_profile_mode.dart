// ==================== MODEL ====================
// chat_info_model.dart
class RecipientProfileModel {
  final String userId;
  final String name;
  final String profileImage;
  final String bio;
  final bool isMuted;
  final bool isEncrypted;
  final List<Map<String, dynamic>>? members;

  RecipientProfileModel({
    required this.userId,
    required this.name,
    required this.profileImage,
    required this.bio,
    this.isMuted = false,
    this.isEncrypted = true,
    this.members,
  });

  // From JSON (Backend থেকে আসবে)
  factory RecipientProfileModel.fromJson(Map<String, dynamic> json) {
    return RecipientProfileModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'] ?? '',
      bio: json['bio'] ?? '',
      isMuted: json['isMuted'] ?? false,
      isEncrypted: json['isEncrypted'] ?? true,
      members: json['members'] != null
          ? List<Map<String, dynamic>>.from(json['members'])
          : null,
    );
  }

  // To JSON (Backend এ পাঠানোর জন্য)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'profileImage': profileImage,
      'bio': bio,
      'isMuted': isMuted,
      'isEncrypted': isEncrypted,
      'members': members,
    };
  }

  // Copy with method (state update এর জন্য)
  RecipientProfileModel copyWith({
    String? userId,
    String? name,
    String? profileImage,
    String? bio,
    bool? isMuted,
    bool? isEncrypted,
    List<Map<String, dynamic>>? members,
  }) {
    return RecipientProfileModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      isMuted: isMuted ?? this.isMuted,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      members: members ?? this.members,
    );
  }
}
