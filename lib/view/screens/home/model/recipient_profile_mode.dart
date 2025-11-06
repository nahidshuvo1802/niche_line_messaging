// ==================== MODEL ====================
// chat_info_model.dart
class RecipientProfileModel {
  final String userId;
  final String name;
  final String profileImage;
  final String bio;
  final bool isMuted;
  final bool isEncrypted;

  RecipientProfileModel({
    required this.userId,
    required this.name,
    required this.profileImage,
    required this.bio,
    this.isMuted = false,
    this.isEncrypted = true,
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
  }) {
    return RecipientProfileModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      isMuted: isMuted ?? this.isMuted,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }
}
