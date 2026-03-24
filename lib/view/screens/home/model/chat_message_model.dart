class MessageResponse {
  bool? success;
  String? message;
  MessageData? data;

  MessageResponse({this.success, this.message, this.data});

  MessageResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? MessageData.fromJson(json['data']) : null;
  }
}

class MessageData {
  Meta? meta;
  List<ChatMessage>? allmessage;

  MessageData({this.meta, this.allmessage});

  MessageData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['allmessage'] != null) {
      allmessage = <ChatMessage>[];
      json['allmessage'].forEach((v) {
        allmessage!.add(ChatMessage.fromJson(v));
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

class ChatMessage {
  String? sId;
  String? text;
  List<dynamic>? imageUrl;
  dynamic audioUrl;
  bool? seen;
  MsgByUserId? msgByUserId;
  String? conversationId;
  String? createdAt;
  String? updatedAt;

  ChatMessage({
    this.sId,
    this.text,
    this.imageUrl,
    this.audioUrl,
    this.seen,
    this.msgByUserId,
    this.conversationId,
    this.createdAt,
    this.updatedAt,
  });

  ChatMessage.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    text = json['text'];
    if (json['imageUrl'] != null) {
      imageUrl = json['imageUrl']; // Can be refined to List<String> if needed
    }
    audioUrl = json['audioUrl'];
    seen = json['seen'];
    msgByUserId = json['msgByUserId'] != null
        ? MsgByUserId.fromJson(json['msgByUserId'])
        : null;
    conversationId = json['conversationId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class MsgByUserId {
  String? sId;
  String? name;
  String? photo;
  bool? online;

  MsgByUserId({this.sId, this.name, this.photo, this.online});

  MsgByUserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    photo = json['photo'];
    online = json['online'];
  }
}
