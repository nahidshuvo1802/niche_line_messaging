// ==================== Chat Model ====================
class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final String timestamp;
  final String avatar;
  final int unreadCount;
  final bool isGroup;
  final bool isOnline;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.avatar,
    this.unreadCount = 0,
    this.isGroup = false,
    this.isOnline = false,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        lastMessage: json['lastMessage'] ?? '',
        timestamp: json['timestamp'] ?? '',
        avatar: json['avatar'] ?? '',
        unreadCount: json['unreadCount'] ?? 0,
        isGroup: json['isGroup'] ?? false,
        isOnline: json['isOnline'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lastMessage': lastMessage,
        'timestamp': timestamp,
        'avatar': avatar,
        'unreadCount': unreadCount,
        'isGroup': isGroup,
        'isOnline': isOnline,
      };
}