import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:niche_line_messaging/core/app_routes/app_routes.dart';
import 'package:niche_line_messaging/helper/shared_prefe/shared_prefe.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/utils/ToastMsg/toast_message.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_const/app_const.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/auth_screen/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// ===========================
/// AUTH CONTROLLER (Simplified)
/// Handles: Register, Login,
/// Sign in with Google / Apple
/// ===========================///

/// ---------- CONTROLLERS ---------- ///

class AuthController extends GetxController {
  /// ---------- CONTROLLERS ---------- ///
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final providerController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final otpController = TextEditingController();
  final locationController = TextEditingController();

  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmNewPassword = TextEditingController();

  /// ---------- STATES ---------- ///
  RxBool isSignupLoading = false.obs;
  RxBool isOtpVerifying = false.obs;
  RxBool isLoginLoading = false.obs;
  RxBool isSocialSAuthLoading = false.obs;
  RxBool isForgetPasswordSendingLoading = false.obs;
  RxBool isResetPasswordLoading = false.obs;
  RxBool isSocialLoading = false.obs;
  RxBool isChangePasswordLoading = false.obs;

  String tempEmail = ""; // for OTP verification

  /// =====================================================
  /// ✅ REGISTER NEW ACCOUNT
  /// =====================================================
  Future<void> createAccount() async {
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

    isSignupLoading.value = true;
    final body = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "location": locationController.text.trim(),
      "password": passwordController.text.trim(),
    };

    try {
      final response =
      await ApiClient.postData(ApiUrl.signUp, jsonEncode(body));
      isSignupLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        tempEmail = emailController.text.trim();
        showCustomSnackBar("OTP sent to your email!", isError: false);
        //Get.offAllNamed(AppRoutes.verifyPicCodeScreen);
      } else {
        final msg = response.body['message'] ?? 'Signup failed';
        showCustomSnackBar(msg, isError: true);
      }
    } catch (e) {
      isSignupLoading.value = false;
      showCustomSnackBar("Network error. Try again.", isError: true);
    }
  }

  /// =====================================================
  /// ✅ VERIFY OTP
  /// =====================================================
  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      showCustomSnackBar("Enter OTP code", isError: true);
      return;
    }

    isOtpVerifying.value = true;

    final body = {
      "verificationCode": int.tryParse(otpController.text.trim()) ?? 0000,
    };

    try {
      final response =
      await ApiClient.patchData(ApiUrl.verifyOtp, jsonEncode(body));
      isOtpVerifying.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar("Account verified successfully!", isError: false);
        clearSignUpFields();
        Get.offAllNamed(AppRoutes.loginScreen);
      } else {
        final msg = response.body['message'] ?? 'Invalid OTP';
        showCustomSnackBar(msg, isError: true);
      }
    } catch (e) {
      isOtpVerifying.value = false;
      showCustomSnackBar("Network error. Try again.", isError: true);
    }
  }

  ///====================================================
  /// ✅ SEND AGAIN OTP
  /// ==================================================
  void sendAgainOtp() async {
    var usingEmail = await SharePrefsHelper.getString("email");
    var response = await ApiClient.getData(ApiUrl.sendAgainOtp(email:usingEmail));
    if (response.statusCode == 200 || response.statusCode == 201) {
      showCustomSnackBar("OTP sent to your email!", isError: false);
    }
    else {
      final msg = "Something Went Wrong";
      showCustomSnackBar(msg, isError: true);
      Get.back();
    }
  }


    /// =====================================================
  /// ✅ VERIFY OTP FOR FORGET PASSWORD
  /// =====================================================
  Future<void> verifyOtpForget() async {
    if (otpController.text.isEmpty) {
      showCustomSnackBar("Enter OTP code", isError: true);
      return;
    }

    isOtpVerifying.value = true;

    final body = {
      "verificationCode": int.tryParse(otpController.text) ?? 0000,
    };

    try {
      final response =
          await ApiClient.postData(ApiUrl.verifyOtpForget, jsonEncode(body));

      isOtpVerifying.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.body;
        final accessToken = responseBody['data'];
        final message =
            responseBody['message'] ?? "Account verified successfully!";

        if (accessToken != null && accessToken.isNotEmpty) {
          // ✅ Decode JWT using jwt_decoder package
          final decodedToken = JwtDecoder.decode(accessToken);
          final userId = decodedToken['id'] ??
              decodedToken['_id'] ??
              decodedToken['userId'];

          if (userId != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('reset_user_id', userId.toString());
          }

          showCustomSnackBar(message, isError: false);
          clearSignUpFields();
          //Get.offAll(ResetPasswordScreen(userId: userId));
        } else {
          showCustomSnackBar("Access token not found", isError: true);
        }
      } else {
        final msg = response.body['message'] ?? 'Invalid OTP';
        showCustomSnackBar(msg, isError: true);
      }
    } catch (e) {
      isOtpVerifying.value = false;
      showCustomSnackBar("Network error. Try again.", isError: true);
      debugPrint("OTP Verify Error: $e");
    }
  }

  /// =====================================================
  /// ✅ FORGOT PASSWORD (Send Email)
  /// =====================================================
  Future<void> forgotPassword({required String email}) async {
    if (email.isEmpty) {
      showCustomSnackBar("Please enter your email", isError: true);
      return;
    }

    isForgetPasswordSendingLoading.value = true; // এটা loading দেখানোর জন্য
    final body = {
      "email": email.trim(),
    };

    try {
      final response =
          await ApiClient.postData(ApiUrl.forgetPassword, jsonEncode(body));
      isForgetPasswordSendingLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.toNamed(AppRoutes.verifypiccodescreenForget);
        showCustomSnackBar("Email sent successfully! Check your inbox.",
            isError: false);
      } else {
        final msg = response.body['message'] ?? 'Failed to send email';
        showCustomSnackBar(msg, isError: true);
      }
    } catch (e) {
      isForgetPasswordSendingLoading.value = false;
      showCustomSnackBar("Network error. Try again.", isError: true);
    }
  }

  /// =====================================================
  /// ✅ RESET PASSWORD (Send userId & new password)
  /// =====================================================
  /// এই মেথডটি ব্যবহারকারী যখন নতুন পাসওয়ার্ড সেট করতে চায়,
  /// তখন API তে userId এবং password পাঠায়।
  ///
  /// API Body Example:
  /// {
  ///   "userId": "68e40b16f2aede267a2c1d47",
  ///   "password": "215019"
  /// }
  ///
  /// সফল হলে ইউজারকে লগইন স্ক্রিনে রিডাইরেক্ট করা হবে।
  ///
  Future<void> resetPassword({
    required String userId,
    required String password,
  }) async {
    if (userId.isEmpty || password.isEmpty) {
      showCustomSnackBar("Something Went Wrong", isError: true);
      return;
    }

    // 🔄 লোডিং শুরু (বোতামে “Sending...” দেখানোর জন্য)
    isResetPasswordLoading.value = true;

    // 🧾 Request Body তৈরি করা
    final body = {
      "userId": userId.trim(),
      "password": password.trim(),
    };

    try {
      // 🌐 API কল করা (reset password endpoint)
      final response =
          await ApiClient.postData(ApiUrl.resetPassword, jsonEncode(body));

      // 🔄 লোডিং বন্ধ করা
      isResetPasswordLoading.value = false;

      // ✅ যদি সফল হয়
      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar("Password reset successfully!", isError: false);

        // 👉 সফল হলে Login Screen-এ পাঠানো
        Get.offAllNamed(AppRoutes.loginScreen);
      } else {
        // ❌ ব্যর্থ হলে backend এর message দেখানো
        final msg = response.body['message'] ?? 'Failed to reset password';
        showCustomSnackBar(msg, isError: true);
      }
    } catch (e) {
      // 🛑 Network বা অন্য কোনো এরর হলে
      isForgetPasswordSendingLoading.value = false;
      showCustomSnackBar("Network error. Try again.", isError: true);
    }
  }

  /// =====================================================
  /// ✅ CHANGE PASSWORD
  /// =====================================================
  /// এই মেথডটি ব্যবহারকারী তার পুরনো পাসওয়ার্ড ও নতুন পাসওয়ার্ড দিয়ে
  /// লগইন থাকা অবস্থায় পাসওয়ার্ড পরিবর্তন করতে পারবে।
  ///
  /// Required Body:
  /// {
  ///   "oldPassword": "123456",
  ///   "newPassword": "654321"
  /// }
  ///
  /// সফল হলে Success Snackbar দেখাবে ও user-কে আবার Login screen-এ পাঠাবে।
  ///
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      showCustomSnackBar("Please fill all fields", isError: true);
      return;
    }

    // Loading indicator toggle করতে চাইলে নতুন RxBool লাগাতে পারো

    isChangePasswordLoading.value = true;

    final body = {
      "newpassword": newPassword.trim().toString(),
      "oldpassword": oldPassword.trim().toString(),
    };

    try {
      final response = await ApiClient.patchData(
        ApiUrl.changePassword, // 🔹 এই endpoint টা তোমার ApiUrl এ যোগ করে নিও
        jsonEncode(body),
      );

      isChangePasswordLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar("Password changed successfully!", isError: false);
        // ✅ Password change successful হলে logout করিয়ে দেবে

        Get.offAllNamed(AppRoutes.settingScreen);
      } else {
        final msg = response.body['message'] ?? "Failed to change password";
        showCustomSnackBar(msg, isError: true);
      }
    } catch (e) {
      isChangePasswordLoading.value = false;
      showCustomSnackBar("Network error. Try again.", isError: true);
      debugPrint("Change Password Error: $e");
    }
  }

  /// =====================================================
  /// ✅ LOGIN USER (Email + Password)
  /// =====================================================

  //==================USE THIS=====================
  /// "email":"jawog85696@aiwanlab.com",
  ///"password": "215019"

  Future<void> loginUser() async {
    if (loginEmailController.text.isEmpty ||
        loginPasswordController.text.isEmpty) {
      showCustomSnackBar("Please enter email & password", isError: true);
      return;
    }

    isLoginLoading.value = true;

    final body = {
      "email": loginEmailController.text.trim(),
      "password": loginPasswordController.text.trim(),
    };

    try {
      final response =
          await ApiClient.postData(ApiUrl.signIn, jsonEncode(body));
      isLoginLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save token if available
        if (response.body != null &&
            response.body['data']['accessToken'] != null) {
          await SharePrefsHelper.setString(
              AppConstants.bearerToken, response.body['data']['accessToken']);
        }

        // showCustomSnackBar("Welcome back!", isError: false);
        Get.snackbar("Welcome", "Nice to see you",
            backgroundColor: const Color.fromARGB(96, 255, 255, 255),
            colorText: AppColors.red2,
            barBlur: 2.0);
        Get.offAllNamed(AppRoutes.homeScreen);
      } else {
        final msg = /*response.body['message'] ??*/ 'Invalid email or password';
        //showCustomSnackBar(msg, isError: true);
        Get.snackbar("Failed", "Invalid Email or Password",
            backgroundColor: Colors.white);
      }
    } catch (e) {
      isLoginLoading.value = false;
      showCustomSnackBar("Network error. Try again.", isError: true);
    }
  }

// =====================================================
// 🎯Google Auth (Google)
// =====================================================
//=========================Google Sign IN================================//
  /// =====================================================
/// ✅ GOOGLE SIGN-IN WITH BACKEND INTEGRATION
/// =====================================================
/// =====================================================
/// ✅ GOOGLE SIGN-IN (STEP BY STEP)
/// =====================================================
Future<void> signInWithGoogle() async {
  try {
    isLoginLoading.value = true;

    // 1️⃣ STEP 1: Google Sign-In popup
    debugPrint('🔄 Step 1: Opening Google Sign-In...');
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      isLoginLoading.value = false;
      Get.snackbar(
        "Cancelled",
        "Google Sign-In was cancelled",
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // 2️⃣ STEP 2: Get Google authentication credentials
    debugPrint('🔄 Step 2: Getting Google credentials...');
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 3️⃣ STEP 3: Sign in to Firebase
    debugPrint('🔄 Step 3: Authenticating with Firebase...');
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user == null) {
      isLoginLoading.value = false;
      Get.snackbar(
        "Failed",
        "Google authentication failed",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    debugPrint('✅ Google Sign-In successful!');
    debugPrint('Name: ${user.displayName}');
    debugPrint('Email: ${user.email}');

    // ✅ Show success message
    Get.snackbar(
      "Success",
      "Google Sign-In successful! Logging you in...",
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );

    // Small delay to show the success message
    await Future.delayed(Duration(milliseconds: 500));

    // 4️⃣ STEP 4: Send to backend for authentication
    debugPrint('🔄 Step 4: Authenticating with backend...');
    
    final body = {
      "name": user.displayName ?? "Google User",
      "email": user.email ?? "",
      "photo": user.photoURL ?? "",
      "provider": "googleAuth",
    };

    debugPrint('🚀 Sending to backend: $body');

    final response = await ApiClient.postData(
      ApiUrl.socialAuth,
      jsonEncode(body),
    );

    debugPrint('📥 Backend Response: ${response.statusCode}');
    debugPrint('📥 Response Body: ${response.body}');

    // 5️⃣ STEP 5: Check backend response
    if (response.statusCode == 200 || response.statusCode == 201) {
      // ✅ Save access token
      if (response.body != null &&
          response.body['data'] != null &&
          response.body['data']['accessToken'] != null) {
        await SharePrefsHelper.setString(
          AppConstants.bearerToken,
          response.body['data']['accessToken'],
        );
        debugPrint('✅ Token saved successfully');
      }

      isLoginLoading.value = false;

      // ✅ Show login successful message
      Get.snackbar(
        "Login Successful",
        "Welcome",
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        barBlur: 2.0,
        duration: Duration(seconds: 2),
      );

      // Small delay before navigation
      await Future.delayed(Duration(milliseconds: 800));

      // 6️⃣ STEP 6: Navigate to home screen
      debugPrint('✅ Navigating to Home Screen...');
      Get.offAllNamed(AppRoutes.homeScreen);
      
    } else {
      // ❌ Backend authentication failed
      isLoginLoading.value = false;
      
      final msg = response.body['message'] ?? 'Authentication failed';
      Get.snackbar(
        "Login Failed",
        msg,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      
      // Sign out from Google if backend fails
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    }
  } catch (e) {
    isLoginLoading.value = false;
    debugPrint("❌ Google Sign-In error: $e");
    
    Get.snackbar(
      "Error",
      "Something went wrong. Please try again.",
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
    
    // Clean up on error
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }
}

  // ===================================================================
  // Apple Auth
  // ==================================================================

//=======================Apple Sign In=============================
/// =====================================================
/// ✅ APPLE SIGN-IN (STEP BY STEP)
/// =====================================================
Future<void> signInWithApple() async {
  try {
    isLoginLoading.value = true;

    // 1️⃣ STEP 1: Apple Sign-In popup
    debugPrint('🔄 Step 1: Opening Apple Sign-In...');
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // 2️⃣ STEP 2: Create Firebase credential
    debugPrint('🔄 Step 2: Getting Apple credentials...');
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );

    // 3️⃣ STEP 3: Sign in to Firebase
    debugPrint('🔄 Step 3: Authenticating with Firebase...');
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    final User? user = userCredential.user;

    if (user == null) {
      isLoginLoading.value = false;
      Get.snackbar(
        "Failed",
        "Apple authentication failed",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    debugPrint('✅ Apple Sign-In successful!');
    debugPrint('Name: ${user.displayName}');
    debugPrint('Email: ${user.email}');

    // Construct name from Apple credential
    String userName = user.displayName ??
        "${credential.givenName ?? ""} ${credential.familyName ?? ""}".trim();
    
    if (userName.isEmpty) {
      userName = "Apple User";
    }

    // ✅ Show success message
    Get.snackbar(
      "Success",
      "Apple Sign-In successful! Logging you in...",
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );

    // Small delay to show the success message
    await Future.delayed(Duration(milliseconds: 500));

    // 4️⃣ STEP 4: Send to backend for authentication
    debugPrint('🔄 Step 4: Authenticating with backend...');
    
    final body = {
      "name": userName,
      "email": user.email ?? credential.email ?? "",
      "photo": user.photoURL ?? "",
      "location": locationController.text.trim().isNotEmpty
          ? locationController.text.trim()
          : "Unknown Location",
      "provider": "appleAuth",
    };

    debugPrint('🚀 Sending to backend: $body');

    final response = await ApiClient.postData(
      ApiUrl.socialAuth,
      jsonEncode(body),
    );

    debugPrint('📥 Backend Response: ${response.statusCode}');
    debugPrint('📥 Response Body: ${response.body}');

    // 5️⃣ STEP 5: Check backend response
    if (response.statusCode == 200 || response.statusCode == 201) {
      // ✅ Save access token
      if (response.body != null &&
          response.body['data'] != null &&
          response.body['data']['accessToken'] != null) {
        await SharePrefsHelper.setString(
          AppConstants.bearerToken,
          response.body['data']['accessToken'],
        );
        debugPrint('✅ Token saved successfully');
      }

      isLoginLoading.value = false;

      // ✅ Show login successful message
      Get.snackbar(
        "Login Successful",
        "Welcome, $userName!",
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        barBlur: 2.0,
        duration: Duration(seconds: 2),
      );

      // Small delay before navigation
      await Future.delayed(Duration(milliseconds: 800));

      // 6️⃣ STEP 6: Navigate to home screen
      debugPrint('✅ Navigating to Home Screen...');
      Get.offAllNamed(AppRoutes.homeScreen);
      
    } else {
      // ❌ Backend authentication failed
      isLoginLoading.value = false;
      
      final msg = response.body['message'] ?? 'Authentication failed';
      Get.snackbar(
        "Login Failed",
        msg,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      
      // Sign out from Apple if backend fails
      await FirebaseAuth.instance.signOut();
    }
  } catch (e) {
    isLoginLoading.value = false;
    debugPrint('❌ Apple Sign-In failed: $e');
    
    Get.snackbar(
      "Error",
      "Something went wrong. Please try again.",
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
    
    // Clean up on error
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }
}


  /// =====================================================
  /// ✅ LOGOUT
  /// =====================================================
  Future<void> logout() async {
    await SharePrefsHelper.remove(AppConstants.bearerToken);
    await SharePrefsHelper.remove(AppConstants.userId);
    await SharePrefsHelper.remove("email");
    Get.offAll(()=> AuthScreen());
    showCustomSnackBar("Logged out successfully", isError: false);
    clearSignUpFields();
  }


  /// =====================================================
  /// ✅ CLEAR FIELDS
  /// =====================================================
  void clearSignUpFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    otpController.clear();
    providerController.clear();
  }
}
