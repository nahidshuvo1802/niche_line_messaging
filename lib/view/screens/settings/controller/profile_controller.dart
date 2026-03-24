import 'dart:convert';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/core/app_routes/app_routes.dart';
import 'package:niche_line_messaging/view/screens/home/controller/chatlist_controller.dart';
import 'package:niche_line_messaging/view/screens/settings/model/profile_model.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var profileData = Rxn<Data>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      var response = await ApiClient.getData(ApiUrl.getMyProfile);
      if (response.statusCode == 200) {
        var model = ProfileModel.fromJson(response.body);
        if (model.success == true) {
          profileData.value = model.data;
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? location,
    dynamic imageFile,
  }) async {
    isLoading.value = true;
    try {
      // Construct the 'data' object
      Map<String, dynamic> dataMap = {};
      if (name != null) dataMap['name'] = name;
      if (location != null) dataMap['location'] = location;

      // The body fields: 'data' containing the JSON string
      Map<String, String> body = {'data': jsonEncode(dataMap)};

      List<MultipartBody> multipartBody = [];
      if (imageFile != null && imageFile is File) {
        multipartBody.add(MultipartBody('file', imageFile));
      }

      var response = await ApiClient.patchMultipartData(
        ApiUrl.updateMyProfile,
        body,
        multipartBody: multipartBody,
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Profile updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchProfile(); // Refresh ProfileController data

        // Delete old ChatListController before navigation to prevent disposed controller error
        if (Get.isRegistered<ChatListController>()) {
          Get.delete<ChatListController>(force: true);
        }

        Get.offAllNamed(AppRoutes.homeScreen);
      } else {
        Get.snackbar(
          "Error",
          response.statusText ?? "Failed to update",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
