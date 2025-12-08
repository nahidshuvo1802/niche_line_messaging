import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/core/app_routes/app_routes.dart';
import 'package:niche_line_messaging/utils/ToastMsg/toast_message.dart';

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

  /// =====================================================
  /// ✅ CREATE ACCOUNT (Frontend Simulation)
  /// =====================================================
  Future<void> createAccount() async {
    // Basic Validation
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showCustomSnackBar("Please fill all fields", isError: true);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showCustomSnackBar("Passwords do not match", isError: true);
      return;
    }

    isSignupLoading.value = true;

    // Simulate API Delay
    await Future.delayed(const Duration(seconds: 2));

    isSignupLoading.value = false;

    // Success Simulation
    showCustomSnackBar("OTP sent to your email (Demo)!", isError: false);

    // Navigate to OTP Screen
    Get.toNamed(AppRoutes.verifyPicCodeScreen);
  }

  /// =====================================================
  /// ✅ VERIFY OTP (Frontend Simulation)
  /// =====================================================
  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty || otpController.text.length < 4) {
      showCustomSnackBar("Enter valid OTP code", isError: true);
      return;
    }

    isOtpVerifying.value = true;

    // Simulate API Delay
    await Future.delayed(const Duration(seconds: 2));

    isOtpVerifying.value = false;

    // Success Simulation
    showCustomSnackBar("Account verified successfully (Demo)!", isError: false);

    // Clear fields
    otpController.clear();

    // Navigate to Recovery Setup Screen
    Get.offAllNamed(AppRoutes.recoverySetupScreen);
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
    if (loginEmailController.text.isEmpty || loginPasswordController.text.isEmpty) {
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