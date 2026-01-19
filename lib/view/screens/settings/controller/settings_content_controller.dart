import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/view/screens/settings/model/settings_content_model.dart';

enum ContentType { aboutUs, privacyPolicy, terms }

class SettingsContentController extends GetxController {
  var isLoading = true.obs;
  var content = "".obs;

  Future<void> fetchContent(ContentType type) async {
    isLoading.value = true;
    String url = "";
    switch (type) {
      case ContentType.aboutUs:
        url = ApiUrl.aboutUs;
        break;
      case ContentType.privacyPolicy:
        url = ApiUrl.privacyPolicy;
        break;
      case ContentType.terms:
        url = ApiUrl.termsAndConditions;
        break;
    }

    try {
      var response = await ApiClient.getData(url);
      if (response.statusCode == 200) {
        var model = SettingsContentModel.fromJson(response.body);
        if (model.success == true) {
          content.value = model.data?.content ?? "No content available.";
        }
      }
    } catch (e) {
      debugPrint("Error fetching content: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
