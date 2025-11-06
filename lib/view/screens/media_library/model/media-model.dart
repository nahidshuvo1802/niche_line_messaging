// ==================== MEDIA MODEL ====================
class MediaItem {
  final String id;
  final String url;
  final String type; // 'photo', 'video', 'doc'
  final String? thumbnail;
  final String? fileName;
  final String? fileSize;
  final DateTime uploadedAt;

  MediaItem({
    required this.id,
    required this.url,
    required this.type,
    this.thumbnail,
    this.fileName,
    this.fileSize,
    required this.uploadedAt,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'photo',
      thumbnail: json['thumbnail'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      uploadedAt: DateTime.parse(json['uploadedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}