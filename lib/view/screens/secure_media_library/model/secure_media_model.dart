class SecureMediaResponse {
  bool? success;
  String? message;
  SecureData? data;

  SecureMediaResponse({this.success, this.message, this.data});

  SecureMediaResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? SecureData.fromJson(json['data']) : null;
  }
}

class SecureData {
  Meta? meta;
  List<SecureMediaItem>? allmessage;

  SecureData({this.meta, this.allmessage});

  SecureData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['allmessage'] != null) {
      allmessage = <SecureMediaItem>[];
      json['allmessage'].forEach((v) {
        allmessage!.add(SecureMediaItem.fromJson(v));
      });
    }
  }
}

class Meta {
  int? page;
  int? limit;
  int? total;
  int? totalPage;

  Meta({this.page, this.limit, this.total, this.totalPage});

  Meta.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPage = json['totalPage'];
  }
}

class SecureMediaItem {
  String? sId;
  String? userId;
  String? createdAt;
  String? updatedAt;
  String? text;
  List<String>? imageUrl;
  String? audioUrl; // Can be null based on JSON

  SecureMediaItem({
    this.sId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.text,
    this.imageUrl,
    this.audioUrl,
  });

  SecureMediaItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    text = json['text'];
    if (json['imageUrl'] != null) {
      imageUrl = List<String>.from(json['imageUrl']);
    }
    audioUrl = json['audioUrl'];
  }
}
