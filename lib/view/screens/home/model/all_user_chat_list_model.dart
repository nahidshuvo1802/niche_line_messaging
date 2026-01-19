class AllUserChatListModel {
  bool? success;
  String? message;
  Data? data;

  AllUserChatListModel({this.success, this.message, this.data});

  AllUserChatListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  Meta? meta;
  List<AllUser>? allUsers;

  Data({this.meta, this.allUsers});

  Data.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['all_users'] != null) {
      allUsers = <AllUser>[];
      json['all_users'].forEach((v) {
        allUsers!.add(AllUser.fromJson(v));
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

class AllUser {
  String? sId;
  String? name;
  String? photo;
  String? id;

  AllUser({this.sId, this.name, this.photo, this.id});

  AllUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    photo = json['photo'];
    id = json['id'];
  }
}
