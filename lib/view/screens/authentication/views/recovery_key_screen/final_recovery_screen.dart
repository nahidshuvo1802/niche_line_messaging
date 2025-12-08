import 'dart:io'; // Platform চেক করার জন্য
import 'package:device_info_plus/device_info_plus.dart'; // Device Info প্যাকেজ
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:niche_line_messaging/helper/shared_prefe/shared_prefe.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_const/app_const.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/subscription/view/subscription_screen_one.dart';

// ==================== Final Recovery Screen ====================
class FinalRecoveryScreen extends StatelessWidget {
  const FinalRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Center(
                child: CustomImage(
                  imageSrc: AppImages.finalrecovery,
                  height: 200.h,
                  width: 200.w,
                  boxFit: BoxFit.fitHeight,
                  fit: BoxFit.cover,
                  scale: 2,
                ),
              ),
              SizedBox(height: 30.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  children: [
                    CustomText(
                      text: 'Recovery Key Setup\nComplete',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      bottom: 12.h,
                    ),
                    CustomText(
                      text: 'Your messages and encryption keys are\nnow securely backed up.',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () => _showBiometricSetupDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Go to Chats',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: _handleViewBackupSettings,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2DD4BF),
                    side: BorderSide(
                      color: const Color(0xFF2DD4BF).withOpacity(0.5),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'View Backup Settings',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  void _handleViewBackupSettings() {
    Get.snackbar(
      'Info',
      'Opening backup settings...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2DD4BF),
      colorText: AppColors.primary,
    );
  }

  void _showBiometricSetupDialog(BuildContext context) {
    Get.dialog(const BiometricSetupDialog(), barrierDismissible: false);
  }
}

// ==================== Biometric Setup Dialog ====================
class BiometricSetupDialog extends StatelessWidget {
  const BiometricSetupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: const Color(0xFF2DD4BF).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 3,
              child: LottieBuilder.asset(
                AppImages.fingerPrint,
                height: 200,
                width: 200,
                repeat: true,
                frameRate: FrameRate(60),
              ),
            ),
            SizedBox(height: 24.h),
            CustomText(
              text: 'Set Up Biometric Unlock',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              textAlign: TextAlign.center,
              bottom: 12.h,
            ),
            CustomText(
              text: 'Use Face ID or Fingerprint to unlock\nNichLine quickly and securely.',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.7),
              textAlign: TextAlign.center,
              maxLines: 2,
              bottom: 24.h,
            ),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () => _handleEnableBiometric(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DD4BF),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Enable Fingerprint',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton(
                onPressed: _handleSkipBiometric,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2DD4BF),
                  side: BorderSide(
                    color: const Color(0xFF2DD4BF).withOpacity(0.5),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Skip for Now',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: 'You can enable biometrics anytime in Settings →\nPrivacy & Security.',
              fontSize: 9.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.5),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Device Info Fetcher (Updated) ====================
  // এই ফাংশনটি এখন ৩টি তথ্য রিটার্ন করবে: Model, Manufacturer, UID
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
        deviceData['uid'] = androidInfo.id; // Unique ID on Android
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

  // ==================== Enable Biometric Logic ====================
  void _handleEnableBiometric(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();

    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        Get.snackbar("Error", "Device does not support biometrics");
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Scan your fingerprint/face to enable secure login',
        // options: const AuthenticationOptions(
        //   stickyAuth: true,
        //   biometricOnly: true,
        // ),
      );

      if (didAuthenticate) {
        // Save Setting
        await SharePrefsHelper.setBool('isBiometricEnabled', true);

        // ✅ Fetch Device Data (Model, Manufacturer, UID)
        Map<String, String> deviceInfo = await _getDeviceInfo();

        // Fetch Token
        String token = await SharePrefsHelper.getString(AppConstants.bearerToken);
        String timestamp = DateTime.now().toIso8601String();

        Get.back(); // Close setup dialog

        // Show Data Box with All Info
        _showTestDataBox(context, deviceInfo, token, timestamp);

      } else {
        Get.snackbar("Failed", "Biometric authentication failed");
      }
    } catch (e) {
      debugPrint("Auth Error: $e");
      Get.snackbar("Error", "Authentication error: $e");
    }
  }

  // ==================== Data Box Display ====================
  void _showTestDataBox(BuildContext context, Map<String, String> deviceInfo, String token, String timestamp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text("Biometric Data Fetched", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("This data will be sent to backend:", style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(10),
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: SingleChildScrollView(
                child: Text(
                  "{\n"
                      "  'status': 'verified',\n"
                      "  'method': 'biometric',\n"
                      "  'device_info': {\n"
                      "     'model': '${deviceInfo['model']}',\n"
                      "     'manufacturer': '${deviceInfo['manufacturer']}',\n"
                      "     'uid': '${deviceInfo['uid']}'\n"
                      "  },\n"
                      "  'timestamp': '$timestamp',\n"
                      "  'token': '${token.isNotEmpty ? token.substring(0, 10) + "..." : "No Token"}'\n"
                      "}",
                  style: TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 12.sp),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2DD4BF)),
            onPressed: () {
              Get.back();
              Get.offAll(() => const SubscriptionScreenOne());
            },
            child: const Text("OK, Proceed", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  // ==================== Skip Logic ====================
  void _handleSkipBiometric() async {
    await SharePrefsHelper.setBool('isBiometricEnabled', false);
    Get.offAll(() => const SubscriptionScreenOne());
  }
}