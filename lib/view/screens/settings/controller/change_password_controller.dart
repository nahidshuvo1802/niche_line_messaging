import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/core/app_navigation.dart';

class ChangePasswordController extends GetxController {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> changePassword() async {
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      Get.snackbar(
        "Error",
        "Password must be at least 6 characters",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // User request body: newpassword, oldpassword
    Map<String, String> body = {
      "newpassword": newPasswordController.text.trim(),
      "oldpassword": oldPasswordController.text.trim(),
    };

    isLoading.value = true;
    try {
      var response = await ApiClient.patchData(ApiUrl.changePassword, body);
      if (response.statusCode == 200) {
        AppNav.back(); // Close screen
        Get.snackbar(
          "Success",
          "Password changed successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          response.statusText ?? "Failed to change password",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error changing password: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
