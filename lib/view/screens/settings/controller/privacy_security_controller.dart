import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/view/screens/settings/controller/profile_controller.dart';
import 'package:niche_line_messaging/core/app_navigation.dart';

class PrivacySecurityController extends GetxController {
  final ProfileController profileController = Get.put(ProfileController());
  var isProcessing = false.obs;

  /// Entry point for the deletion flow
  void beginDeleteAllMessagesFlow() {
    _showRecoveryKeyInput();
  }

  /// Step 1: Input Recovery Key
  void _showRecoveryKeyInput() {
    final TextEditingController keyController = TextEditingController();
    Get.defaultDialog(
      title: "Security Check",
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      backgroundColor: const Color(0xFF1A1F3A),
      radius: 12,
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        children: [
          const Text(
            "Please enter your Recovery Key to verify your identity.",
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: keyController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter Recovery Key",
              hintStyle: TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Color(0xFF0E1527),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
      confirm: SizedBox(
        width: 100,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2DD4BF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (keyController.text.trim().isEmpty) {
              Get.snackbar(
                "Error",
                "Please enter recovery key",
                colorText: Colors.white,
                backgroundColor: Colors.red,
              );
              return;
            }
            AppNav.back(); // process logic
            _validateRecoveryKey(keyController.text.trim());
          },
          child: const Text("Verify", style: TextStyle(color: Colors.white)),
        ),
      ),
      cancel: SizedBox(
        width: 100,
        child: TextButton(
          onPressed: () => AppNav.back(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
        ),
      ),
    );
  }

  /// Step 2: Validate Recovery Key via API
  Future<void> _validateRecoveryKey(String key) async {
    isProcessing.value = true;
    _showLoadingDialog("Verifying...");

    try {
      // Ensure profile data is loaded to get email
      if (profileController.profileData.value == null) {
        await profileController.fetchProfile();
      }

      String? email = profileController.profileData.value?.email;
      if (email == null || email.isEmpty) {
        AppNav.back(); // close loading
        Get.snackbar(
          "Error",
          "Could not retrieve user email.",
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
        return;
      }

      Map<String, String> deviceInfo = await _getDeviceInfo();

      Map<String, dynamic> body = {
        "email": email,
        "recoveryKey": key,
        "model": deviceInfo['model'] ?? "Unknown",
        "manufacturer": deviceInfo['manufacturer'] ?? "Unknown",
        "uid": deviceInfo['uid'] ?? "Unknown",
      };

      var response = await ApiClient.postData(
        ApiUrl.submitRecoveryKeyAuth,
        body,
      );

      AppNav.back(); // close loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Validation Successful -> Proceed to Confirmation
        _showConfirmationStep1();
      } else {
        String msg = response.body['message'] ?? "Invalid Recovery Key";
        Get.snackbar(
          "Verification Failed",
          msg,
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      AppNav.back(); // close loading
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Step 3: First Confirmation Dialog
  void _showConfirmationStep1() {
    Get.defaultDialog(
      title: "Delete All Messages?",
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: const Color(0xFF1A1F3A),
      radius: 12,
      content: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Are you sure you want to delete all messages? This action cannot be undone.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      ),
      confirm: SizedBox(
        width: 100,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            AppNav.back();
            _showConfirmationStep2();
          },
          child: const Text(
            "Yes, Delete",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      cancel: SizedBox(
        width: 100,
        child: TextButton(
          onPressed: () => AppNav.back(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
        ),
      ),
    );
  }

  /// Step 4: Second Confirmation Dialog (Final)
  void _showConfirmationStep2() {
    Get.defaultDialog(
      title: "Final Confirmation",
      titleStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: const Color(0xFF1A1F3A),
      radius: 12,
      content: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "This is your last chance. All conversations will be permanently wiped.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      ),
      confirm: SizedBox(
        width: 100,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            AppNav.back();
            _executeDeleteAllMessages();
          },
          child: const Text("Confirm", style: TextStyle(color: Colors.white)),
        ),
      ),
      cancel: SizedBox(
        width: 100,
        child: TextButton(
          onPressed: () => AppNav.back(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
        ),
      ),
    );
  }

  /// Step 5: Execute Delete API
  Future<void> _executeDeleteAllMessages() async {
    isProcessing.value = true;
    _showLoadingDialog("Deleting messages...");

    try {
      var response = await ApiClient.deleteData(ApiUrl.deleteAllConversation);

      AppNav.back(); // close loading

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "All messages have been deleted.",
          colorText: Colors.white,
          backgroundColor: Colors.green,
        );
      } else {
        Get.snackbar(
          "Error",
          response.statusText ?? "Failed to delete messages",
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      AppNav.back(); // close loading
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  void _showLoadingDialog(String message) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF2DD4BF)),
              const SizedBox(width: 20),
              Text(message, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Helper: Get Device Info
  Future<Map<String, String>> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, String> deviceData = {
      'model': 'Unknown',
      'manufacturer': 'Unknown',
      'uid': 'Unknown',
    };

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData['model'] = androidInfo.model;
        deviceData['manufacturer'] = androidInfo.manufacturer;
        deviceData['uid'] = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData['model'] = iosInfo.model;
        deviceData['manufacturer'] = 'Apple';
        deviceData['uid'] = iosInfo.identifierForVendor ?? 'Unknown IOS ID';
      }
    } catch (e) {
      debugPrint("Failed to get device info: $e");
    }
    return deviceData;
  }
}
