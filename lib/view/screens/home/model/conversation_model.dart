class ConversationModel {
  bool? success;
  String? message;
  Data? data;

  ConversationModel({this.success, this.message, this.data});

  ConversationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  Meta? meta;
  List<AllConversations>? allConversations;

  Data({this.meta, this.allConversations});

  Data.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['allConversations'] != null) {
      allConversations = <AllConversations>[];
      json['allConversations'].forEach((v) {
        allConversations!.add(AllConversations.fromJson(v));
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

class AllConversations {
  String? sId;
  List<Participants>? participants;
  String? groupname;
  String? lastMessage;
  String? chat;
  bool? isDelete;
  String? createdAt;
  String? updatedAt;

  AllConversations({
    this.sId,
    this.participants,
    this.groupname,
    this.lastMessage,
    this.chat,
    this.isDelete,
    this.createdAt,
    this.updatedAt,
  });

  AllConversations.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['participants'] != null) {
      participants = <Participants>[];
      json['participants'].forEach((v) {
        participants!.add(Participants.fromJson(v));
      });
    }
    groupname = json['groupname'];
    lastMessage = json['lastMessage'];
    chat = json['chat'];
    isDelete = json['isDelete'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class Participants {
  String? sId;
  String? name;
  String? photo;
  bool? online;

  Participants({this.sId, this.name, this.photo, this.online});

  Participants.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    photo = json['photo'];
    online = json['online'];
  }
}
