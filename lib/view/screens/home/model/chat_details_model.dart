// ==================== Message Model ====================
import 'package:niche_line_messaging/view/screens/home/views/chat_screen_one.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final String timestamp;
  final MessageType type;
  final bool isDelivered;
  final bool isRead;
  final bool showDateLabel;
  final String? dateLabel;
  final String? fileName;
  final String? fileSize;
  final String? voiceDuration;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
    this.isDelivered = false,
    this.isRead = false,
    this.showDateLabel = false,
    this.dateLabel,
    this.fileName,
    this.fileSize,
    this.voiceDuration,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? '',
      type: MessageType.values[json['type'] ?? 0],
      isDelivered: json['isDelivered'] ?? false,
      isRead: json['isRead'] ?? false,
      showDateLabel: json['showDateLabel'] ?? false,
      dateLabel: json['dateLabel'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      voiceDuration: json['voiceDuration'],
    );
  }
}
