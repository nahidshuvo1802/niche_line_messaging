import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/home/views/home_screen.dart';

// ==================== Recovery Key Setup Complete Screen ====================
// Recovery key setup complete হলে এই screen দেখাবে
// User কে biometric setup করতে বলবে অথবা চাইলে skip করতে পারবে
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

              // ==================== Logo ====================
              // ),
              Center(
                child: CustomImage(
                  imageSrc: AppImages.finalrecovery,
                  height: 200.h,
                  width: 200.w,
                  boxFit: BoxFit.fitHeight,
                  fit: BoxFit.cover,
                  scale: 2,
                  //imageColor: AppColors.loading,
                ),
              ),

              SizedBox(height: 30.h),

              // ==================== Success Message Box ====================
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
                      text:
                          'Your messages and encryption keys are\nnow securely backed up.',
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

              // ==================== Go to Chats Button ====================
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _handleGoToChats,
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

              // ==================== View Backup Settings Button ====================
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

  // ==================== Go to Chats ====================
  void _handleGoToChats() {
    // Biometric setup dialog দেখাবে
    _showBiometricSetupDialog();
  }

  // ==================== View Backup Settings ====================
  void _handleViewBackupSettings() {
    // TODO: Navigate to backup settings screen
    Get.snackbar(
      'Info',
      'Opening backup settings...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2DD4BF),
      colorText: AppColors.primary,
    );

    debugPrint('✅ Opening Backup Settings');
  }

  // ==================== Show Biometric Setup Dialog ====================
  void _showBiometricSetupDialog() {
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
            // ==================== Fingerprint Icon ====================
            Transform.scale(scale: 3,child: LottieBuilder.asset(AppImages.fingerPrint,height: 200,width: 200,repeat: true,frameRate: FrameRate(60),)),

            SizedBox(height: 24.h),

            // ==================== Title ====================
            CustomText(
              text: 'Set Up Biometric Unlock',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              textAlign: TextAlign.center,
              bottom: 12.h,
            ),

            // ==================== Description ====================
            CustomText(
              text:
                  'Use Face ID or Fingerprint to unlock\nNichLine quickly and securely.',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.7),
              textAlign: TextAlign.center,
              maxLines: 2,
              bottom: 24.h,
            ),

            // ==================== Enable Fingerprint Button ====================
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _handleEnableBiometric,
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

            // ==================== Skip for Now Button ====================
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

            // ==================== Footer Note ====================
            CustomText(
              text:
                  'You can enable biometrics anytime in Settings →\nPrivacy & Security.',
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

  // ==================== Enable Biometric ====================
  void _handleEnableBiometric() async {
    Get.back(); // Close dialog

    // TODO: Implement device biometric authentication
    // Use local_auth package for biometric authentication
    // Example:
    // final LocalAuthentication auth = LocalAuthentication();
    // final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    // if (canAuthenticateWithBiometrics) {
    //   try {
    //     final bool didAuthenticate = await auth.authenticate(
    //       localizedReason: 'Please authenticate to enable biometric unlock',
    //       options: const AuthenticationOptions(biometricOnly: true),
    //     );
    //
    //     if (didAuthenticate) {
    //       // Save biometric enabled status
    //       await ApiClient.postData(ApiUrl.enableBiometric, {'enabled': true});
    //
    //       Get.snackbar(
    //         'Success',
    //         'Biometric unlock enabled successfully',
    //         snackPosition: SnackPosition.BOTTOM,
    //         backgroundColor: Colors.green,
    //         colorText: Colors.white,
    //       );
    //
    //       // Navigate to home
    //       Get.offAllNamed(AppRoutes.homeScreen);
    //     }
    //   } catch (e) {
    //     Get.snackbar(
    //       'Error',
    //       'Failed to enable biometric unlock',
    //       snackPosition: SnackPosition.BOTTOM,
    //       backgroundColor: Colors.red,
    //       colorText: Colors.white,
    //     );
    //   }
    // }

    // Temporary simulation
    await Future.delayed(const Duration(seconds: 1));

    Get.snackbar(
      'Success',
      'Biometric unlock enabled successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    debugPrint('✅ Biometric Enabled');

    // Navigate to home screen
    // TODO: 
    Get.offAll(() => HomeScreen());
  }

  // ==================== Skip Biometric ====================
  void _handleSkipBiometric() { // Close dialog

    Get.snackbar(
      'Info',
      'You can enable biometric unlock later in Settings',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2DD4BF),
      colorText: AppColors.primary,
    );
   
    debugPrint('✅ Biometric Skipped');

    // Navigate to home screen directly
    // TODO: Get.offAllNamed(AppRoutes.homeScreen);
     Get.offAll(()=>HomeScreen());
  }
}
