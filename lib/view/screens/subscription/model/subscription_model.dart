class SubscriptionModel {
  bool? success;
  String? message;
  Data? data;

  SubscriptionModel({this.success, this.message, this.data});

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  List<SubscriptionItem>? allSubscriptionList;

  Data({this.allSubscriptionList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['all_subscription_list'] != null) {
      allSubscriptionList = <SubscriptionItem>[];
      json['all_subscription_list'].forEach((v) {
        allSubscriptionList!.add(SubscriptionItem.fromJson(v));
      });
    }
  }
}

class SubscriptionItem {
  PlanDetails? subscriptionType30;
  PlanDetails? subscriptionType15;
  String? sId;
  String? title;
  String? description;
  List<SubscriptionPrice>? subscriptionPrice;

  SubscriptionItem({
    this.subscriptionType30,
    this.subscriptionType15,
    this.sId,
    this.title,
    this.description,
    this.subscriptionPrice,
  });

  SubscriptionItem.fromJson(Map<String, dynamic> json) {
    subscriptionType30 = json['subscriptionType30'] != null
        ? PlanDetails.fromJson(json['subscriptionType30'])
        : null;
    subscriptionType15 = json['subscriptionType15'] != null
        ? PlanDetails.fromJson(json['subscriptionType15'])
        : null;
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    if (json['subscriptionPrice'] != null) {
      subscriptionPrice = <SubscriptionPrice>[];
      json['subscriptionPrice'].forEach((v) {
        subscriptionPrice!.add(SubscriptionPrice.fromJson(v));
      });
    }
  }
}

class PlanDetails {
  String? title;
  List<String>? features;

  PlanDetails({this.title, this.features});

  PlanDetails.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    features = json['features'].cast<String>();
  }
}

class SubscriptionPrice {
  String? pricetype;
  String? sId;

  SubscriptionPrice({this.pricetype, this.sId});

  SubscriptionPrice.fromJson(Map<String, dynamic> json) {
    pricetype = json['pricetype'];
    sId = json['_id'];
  }
}
