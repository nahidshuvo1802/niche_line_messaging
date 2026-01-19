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
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/final_recovery_screen.dart';
import 'package:niche_line_messaging/view/screens/subscription/controller/subscription_controller.dart';
import 'package:niche_line_messaging/view/screens/subscription/view/subscription_screen_trial.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_input_screen.dart';
import 'package:niche_line_messaging/service/socket_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:niche_line_messaging/helper/shared_prefe/shared_prefe.dart';
import 'package:flutter/foundation.dart';
import 'package:niche_line_messaging/utils/app_const/app_const.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      loginEmailController.text = "info.sohelranaa@gmail.com";
      loginPasswordController.text = "MyStrongPass@2026";
    }
  }

  RxBool isRecoveryLoading = false.obs;

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
      // Body for new API: {"verificationCode": 1234} (Integer)
      Map<String, dynamic> body = {
        "verificationCode": int.tryParse(otpController.text.trim()) ?? 0,
      };

      debugPrint("🚀 Verifying OTP with body: $body");

      // Real API Call
      Response response = await ApiClient.patchData(ApiUrl.otpVerify, body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle Success
        // Save Access Token if available
        if (response.body['data'] != null &&
            response.body['data']['accessToken'] != null) {
          String token = response.body['data']['accessToken'];
          await SharePrefsHelper.setString(AppConstants.bearerToken, token);
          debugPrint("✅ Access Token Saved: $token");
        }

        showCustomSnackBar("Account verified successfully!", isError: false);
        otpController.clear();

        // Clear temp email
        await SharePrefsHelper.remove("temp_register_email");

        // Navigate to Final Success Screen (or Home)
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

    // Ensure at least one letter and one number
    String result = '';
    bool hasLetter = false;
    bool hasNumber = false;

    // Keep generating until we satisfy conditions
    while (!hasLetter || !hasNumber) {
      result = String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
        ),
      );

      hasLetter = result.contains(RegExp(r'[A-Z]'));
      hasNumber = result.contains(RegExp(r'[0-9]'));
    }

    return result;
  }

  /// =====================================================
  /// ✅ REGISTER USER (Final Step)
  /// =====================================================
  Future<void> registerUser() async {
    isRegistering.value = true;

    try {
      // 1. Get Device Info
      Map<String, String> deviceInfo = await _getDeviceInfo();

      // 2. Get Package Info
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String packageName = packageInfo.packageName;

      // 3. Prepare Payload (FCM is not needed for now as per requirement)
      Map<String, dynamic> body = {
        "name": nameController.text.trim(),
        "password": passwordController.text.trim(),
        "email": emailController.text.trim(),
        "location": locationController.text.trim(),
        "model": deviceInfo['model'],
        "manufacturer": deviceInfo['manufacturer'],
        "recoveryKey": recoveryKey.value,
        "uid": deviceInfo['uid'],
        "package": packageName, // Added package name from device
      };

      debugPrint("📱 Device Info: $deviceInfo");
      debugPrint("📦 Package Name: $packageName");
      debugPrint("🚀 Registering User with body: $body");

      // 4. Call API
      Response response = await ApiClient.postData(ApiUrl.signUp, body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save email locally for OTP resend
        await SharePrefsHelper.setString(
          "temp_register_email",
          emailController.text.trim(),
        );

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
  /// ✅ SEND AGAIN OTP (Real API - GET)
  /// =====================================================
  Future<void> sendAgainOtp() async {
    String email = "";

    // 1. Try getting from controller
    if (emailController.text.isNotEmpty) {
      email = emailController.text.trim();
    }
    // 2. Try getting from Login controller
    else if (loginEmailController.text.isNotEmpty) {
      email = loginEmailController.text.trim();
    }
    // 3. Try getting from SharedPreferences (Best for OTP screen reload)
    else {
      email = await SharePrefsHelper.getString("temp_register_email");
    }

    if (email.isEmpty) {
      showCustomSnackBar("Email not found to resend OTP", isError: true);
      return;
    }

    try {
      showCustomSnackBar("Resending OTP...", isError: false);
      debugPrint("🔄 Resending OTP to: $email");

      // API Call (GET Request)
      String url = ApiUrl.sendAgainOtp(email: email);
      Response response = await ApiClient.getData(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar("OTP sent successfully!", isError: false);
      } else {
        String errorMessage = response.statusText ?? "Failed to resend OTP";
        if (response.body != null && response.body['message'] != null) {
          errorMessage = response.body['message'];
        }
        showCustomSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      debugPrint("❌ Resend OTP Error: $e");
      showCustomSnackBar("Something went wrong: $e", isError: true);
    }
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

    try {
      // 1. Get Device Info
      Map<String, String> deviceInfo = await _getDeviceInfo();

      // 2. Prepare Body
      Map<String, dynamic> body = {
        "email": loginEmailController.text.trim(),
        "password": loginPasswordController.text.trim(),
        "uid": deviceInfo['uid'] ?? "Unknown",
        // "fcm": "..." // Not needed for now
      };

      debugPrint("🚀 Logging in with body: $body");

      // 3. Call API
      Response response = await ApiClient.postData(ApiUrl.signIn, body);

      // Check for Recovery Key Requirement
      if (response.body != null && response.body['recoveryKey'] == true) {
        Get.to(() => RecoveryKeyInputScreen());
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.body['data'];

        // Strict Check: Access Token MUST be present
        if (data != null && data['accessToken'] != null) {
          String token = data['accessToken'];
          await SharePrefsHelper.setString(AppConstants.bearerToken, token);
          debugPrint("✅ Access Token Saved: $token");

          // Decode JWT to get User ID for socket connection
          try {
            Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
            debugPrint("📝 Decoded JWT: $decodedToken");

            String? usrId =
                decodedToken['_id'] ??
                decodedToken['id'] ??
                decodedToken['userId'] ??
                decodedToken['sub'];
            if (usrId != null && usrId.isNotEmpty) {
              await SharePrefsHelper.setString(AppConstants.userId, usrId);
              debugPrint("✅ User ID from JWT Saved: $usrId");
            }
          } catch (e) {
            debugPrint("⚠️ Error decoding JWT: $e");
          }

          if (data['refreshToken'] != null) {
            String refreshToken = data['refreshToken'];
            await SharePrefsHelper.setString(
              AppConstants.refreshToken,
              refreshToken,
            );
            debugPrint("✅ Refresh Token Saved: $refreshToken");
          }

          showCustomSnackBar(
            response.body['message'] ?? "Login successful!",
            isError: false,
          );

          // Check Active Subscription and Navigate
          final subController = Get.put(SubscriptionController());
          await subController.getActiveSubscription();

          // Initialize socket connection after successful login
          debugPrint('🔌 Initializing socket after login...');
          await SocketApi.init();

          if (subController.hasActiveSubscription.value &&
              subController.activePlanType.value == 'free') {
            Get.offAll(() => const SubscriptionScreenTrial());
          } else {
            Get.offAllNamed(AppRoutes.homeScreen);
          }
        } else {
          // Success status but NO Access Token -> Redirect to Recovery
          debugPrint(
            "⚠️ Missing Access Token. Redirecting to Recovery Key Input.",
          );
          Get.to(() => RecoveryKeyInputScreen());
        }
      } else {
        // Handle Error
        String errorMessage = response.statusText ?? "Login failed";
        if (response.body != null && response.body['message'] != null) {
          errorMessage = response.body['message'];
        }

        // Create new session via Recovery Key if Unauthorized
        if (errorMessage.contains("You are not Authorized")) {
          Get.to(() => RecoveryKeyInputScreen());
          // showCustomSnackBar("Security Check Required", isError: true);
          return;
        }

        showCustomSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      debugPrint("Login Error: $e");
      showCustomSnackBar("Something went wrong: $e", isError: true);
    } finally {
      isLoginLoading.value = false;
    }
  }

  /// =====================================================
  /// ❌ CANCEL REGISTRATION (Anytime)
  /// =====================================================
  void cancelRegistration() {
    // Clear all form fields safely
    try {
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      locationController.clear();
    } catch (e) {
      debugPrint("Controllers might be disposed: $e");
    }
    recoveryKey.value = '';

    // Clear temp email
    SharePrefsHelper.remove("temp_register_email");

    // Reset loading states
    isSignupLoading.value = false;
    isOtpVerifying.value = false;
    isRegistering.value = false;

    // Navigate back to Auth Screen
    Get.offAllNamed(AppRoutes.authScreen);

    showCustomSnackBar("Registration cancelled", isError: false);
  }

  /// =====================================================
  /// 🚪 LOGOUT USER
  /// =====================================================
  Future<void> logoutUser() async {
    try {
      // Disconnect socket before logout
      debugPrint('🔌 Disconnecting socket on logout...');
      SocketApi.dispose();

      await SharePrefsHelper.remove(AppConstants.bearerToken);
      await SharePrefsHelper.remove(AppConstants.refreshToken);
      await SharePrefsHelper.remove(AppConstants.userId);
      await SharePrefsHelper.remove("temp_register_email");
      await SharePrefsHelper.remove("current_subscription_id");

      // Clear Controllers safely
      try {
        loginEmailController.clear();
        loginPasswordController.clear();
        emailController.clear();
      } catch (e) {
        debugPrint("Controllers might be disposed: $e");
      }

      // Navigate to Auth Screen
      Get.offAllNamed(AppRoutes.authScreen);
      showCustomSnackBar("Logged out successfully", isError: false);
    } catch (e) {
      debugPrint("Logout Error: $e");
      showCustomSnackBar("Failed to logout: $e", isError: true);
    }
  }

  /// =====================================================
  /// 🔑 SUBMIT RECOVERY KEY
  /// =====================================================
  Future<void> submitRecoveryKey(String key) async {
    isRecoveryLoading.value = true;
    try {
      // 1. Get Device Info
      Map<String, String> deviceInfo = await _getDeviceInfo();

      // 2. Prepare Body
      Map<String, dynamic> body = {
        "email": loginEmailController.text.trim(),
        "recoveryKey": key,
        "model": deviceInfo['model'] ?? "Unknown",
        "manufacturer": deviceInfo['manufacturer'] ?? "Unknown",
        "uid": deviceInfo['uid'] ?? "Unknown",
      };

      debugPrint("🚀 Submitting Recovery Key Auth: $body");

      Response response = await ApiClient.postData(
        ApiUrl.submitRecoveryKeyAuth,
        body,
      );

      debugPrint(
        "Recovery Response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success Logic
        Get.offAllNamed(AppRoutes.authScreen);

        Get.snackbar(
          "Success",
          "Recovery key is correct, now please login again",
          backgroundColor: const Color(0xFF2DD4BF),
          colorText: AppColors.primary,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(10),
        );
      } else {
        String msg = "Verification failed";
        if (response.body != null && response.body['message'] != null) {
          msg = response.body['message'];
        }
        showCustomSnackBar(msg, isError: true);
      }
    } catch (e) {
      debugPrint("Recovery Key Error: $e");
      showCustomSnackBar("Error: $e", isError: true);
    } finally {
      isRecoveryLoading.value = false;
    }
  }
}
