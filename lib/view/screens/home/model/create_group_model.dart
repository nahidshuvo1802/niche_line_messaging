// ==================== Recipient Model ====================
class RecipientModel {
  final String id;
  final String name;
  final String status;
  final String avatar;
  final bool isOnline;

  RecipientModel({
    required this.id,
    required this.name,
    required this.status,
    required this.avatar,
    this.isOnline = false,
  });

  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      avatar: json['avatar'] ?? '',
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'avatar': avatar,
      'isOnline': isOnline,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipientModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}