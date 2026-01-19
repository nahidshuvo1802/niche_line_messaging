class SettingsContentModel {
  bool? success;
  String? message;
  SettingsData? data;

  SettingsContentModel({this.success, this.message, this.data});

  SettingsContentModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? SettingsData.fromJson(json['data']) : null;
  }
}

class SettingsData {
  String? id;
  String? content;

  SettingsData({this.id, this.content});

  SettingsData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    if (json.containsKey('aboutUs')) {
      content = json['aboutUs'];
    } else if (json.containsKey('PrivacyPolicy')) {
      content = json['PrivacyPolicy'];
    } else if (json.containsKey('TermsConditions')) {
      content = json['TermsConditions'];
    }
  }
}
