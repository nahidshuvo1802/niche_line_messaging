class ProfileModel {
  bool? success;
  String? message;
  Data? data;

  ProfileModel({this.success, this.message, this.data});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  String? sId;
  String? name;
  String? email;
  String? photo;
  String? location;
  String? model;
  String? manufacturer;

  Data({
    this.sId,
    this.name,
    this.email,
    this.photo,
    this.location,
    this.model,
    this.manufacturer,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    photo = json['photo'];
    location = json['location'];
    model = json['model'];
    manufacturer = json['manufacturer'];
  }
}
