import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/core/app_routes/app_routes.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/utils/ToastMsg/toast_message.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/final_recovery_screen.dart';

class AuthController extends GetxController {
  /// ---------- CONTROLLERS ---------- ///
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final otpController = TextEditingController();
  final locationController = TextEditingController();

  /// ---------- STATES ---------- ///
  RxBool isSignupLoading = false.obs;
  RxBool isOtpVerifying = false.obs;
  RxBool isLoginLoading = false.obs;
  RxBool isRegistering = false.obs;

  /// =====================================================
  /// ✅ CREATE ACCOUNT (Step 1)
  /// =====================================================
  /// =====================================================
  /// ✅ INITIALIZE REGISTRATION (Step 1)
  /// =====================================================
  void initializeRegistration() {
    // Basic Validation
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        locationController.text.isEmpty) {
      showCustomSnackBar("Please fill all fields", isError: true);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showCustomSnackBar("Passwords do not match", isError: true);
      return;
    }

    // Navigate to Recovery Setup Screen directly (No API call yet)
    Get.toNamed(AppRoutes.recoverySetupScreen);
  }

  /// =====================================================
  /// ✅ VERIFY OTP (Step 2)
  /// =====================================================
  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty || otpController.text.length < 4) {
      showCustomSnackBar("Enter valid OTP code", isError: true);
      return;
    }

    isOtpVerifying.value = true;

    try {
      Map<String, dynamic> body = {
        "email": emailController.text.trim(),
        "otp": otpController.text.trim(),
      };

      debugPrint("Verifying OTP for: ${body['email']}");

      // Real API Call
      Response response = await ApiClient.postData(ApiUrl.otpVerify, body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar("Account verified successfully!", isError: false);
        otpController.clear();
        // Navigate to Final Success Screen
        Get.offAll(() => const FinalRecoveryScreen());
      } else {
        String errorMessage = response.statusText ?? "Verification failed";
        if (response.body != null && response.body['message'] != null) {
          errorMessage = response.body['message'];
        }
        showCustomSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      debugPrint("OTP Verification Error: $e");
      showCustomSnackBar("Something went wrong: $e", isError: true);
    } finally {
      isOtpVerifying.value = false;
    }
  }

  /// =====================================================
  /// ✅ RECOVERY KEY LOGIC (Step 3)
  /// =====================================================
  RxString recoveryKey = ''.obs;

  void generateRecoveryKey() {
    recoveryKey.value = _generateRandomString(8);
  }

  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// =====================================================
  /// ✅ REGISTER USER (Final Step)
  /// =====================================================
  Future<void> registerUser() async {
    isRegistering.value = true;

    try {
      // 1. Get Device Info
      Map<String, String> deviceInfo = await _getDeviceInfo();

      // 2. Prepare Payload
      // Note: FCM token is hardcoded for now or should be fetched from FirebaseMessaging
      String fcmToken =
          "cEghrSHmaHFH141KtB85C9:APA91bHK32qcrfw0LbPXUsuWV98AJdw2dpZ2u7lUiXvqglcNI41qC6eYzlw1p62RNCSgs2xD_9X2GWAvO23HtGQQTVIjrPNM8VfeqQGfid2D_aLQ9g6dApg";

      Map<String, dynamic> body = {
        "name": nameController.text.trim(),
        "password": passwordController.text.trim(),
        "email": emailController.text.trim(),
        "location": locationController.text.trim(),
        "model": deviceInfo['model'],
        "manufacturer": deviceInfo['manufacturer'],
        "recoveryKey": recoveryKey.value,
        "uid": deviceInfo['uid'],
        "fcm": fcmToken,
      };

      debugPrint("Registering User with body: $body");

      // 3. Call API
      Response response = await ApiClient.postData(ApiUrl.signUp, body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar("Account created successfully!", isError: false);
        // Navigate to OTP Screen
        Get.toNamed(AppRoutes.verifyPicCodeScreen);
      } else {
        // Handle Error
        String errorMessage = response.statusText ?? "Registration failed";
        if (response.body != null && response.body['message'] != null) {
          errorMessage = response.body['message'];
        }
        showCustomSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      debugPrint("Registration Error: $e");
      showCustomSnackBar("Something went wrong: $e", isError: true);
    } finally {
      isRegistering.value = false;
    }
  }

  /// =====================================================
  /// 📱 GET DEVICE INFO
  /// =====================================================
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

  /// =====================================================
  /// ✅ SEND AGAIN OTP (Frontend Simulation)
  /// =====================================================
  void sendAgainOtp() async {
    showCustomSnackBar("Sending OTP...", isError: false);
    await Future.delayed(const Duration(seconds: 2));
    showCustomSnackBar("OTP sent again (Demo)!", isError: false);
  }

  /// =====================================================
  /// ✅ LOGIN USER (Frontend Simulation)
  /// =====================================================
  Future<void> loginUser() async {
    if (loginEmailController.text.isEmpty ||
        loginPasswordController.text.isEmpty) {
      showCustomSnackBar("Please enter email & password", isError: true);
      return;
    }

    isLoginLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoginLoading.value = false;

    // Direct Home for demo
    Get.offAllNamed(AppRoutes.homeScreen);
    showCustomSnackBar("Welcome back (Demo)!", isError: false);
  }
}
