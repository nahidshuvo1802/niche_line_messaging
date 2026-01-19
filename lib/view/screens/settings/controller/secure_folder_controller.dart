import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';

class SecureFolderController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool hasCreatedAccount = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkSecureFolderStatus();
  }

  Future<void> checkSecureFolderStatus() async {
    try {
      isLoading.value = true;
      final response = await ApiClient.getData(
        ApiUrl.isCreateAccountSecureFolder,
      );

      if (response.statusCode == 200) {
        final body = response.body;
        if (body['success'] == true && body['data'] != null) {
          hasCreatedAccount.value = body['data']['status'] == true;
        }
      }
    } catch (e) {
      debugPrint("Error checking secure folder status: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOrCreatePin(String pin) async {
    try {
      final body = {"password": pin};
      final response = await ApiClient.postData(
        ApiUrl.createSecureFolder,
        body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = response.body;
        if (resBody['success'] == true) {
          Get.snackbar(
            'Success',
            resBody['message']?.toString() ?? 'Success',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF2DD4BF),
            colorText: Colors.white,
          );
          return true;
        } else {
          Get.snackbar(
            'Error',
            resBody['message']?.toString() ?? 'Operation failed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false;
        }
      } else {
        Get.snackbar(
          'Error',
          response.statusText ?? 'Operation failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint("Error verify/create PIN: $e");
      Get.snackbar(
        'Error',
        'An error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
