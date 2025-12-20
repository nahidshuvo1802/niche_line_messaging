import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/authentication/controller/auth_controller.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/recovery_screen2.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/widget/setup_line_widget.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/widget/setup_widget.dart';

// ==================== Recovery Key Setup Screen ====================
// User-কে recovery key setup করতে guide করে
// 4টা step: Setup → Generate → Save → Verify
class RecoveryKeySetupScreenOne extends StatelessWidget {
  RecoveryKeySetupScreenOne({super.key});

  // ==================== Reactive State ====================
  // Current step track করার জন্য (0 = Setup, 1 = Generate, 2 = Save, 3 = Verify)
  final RxInt currentStep = 0.obs;

  // Loading state for generate button
  final RxBool isGenerating = false.obs;

  // Generated recovery key (পরে API থেকে পাবেন)
  final RxString recoveryKey = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Dark navy background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ==================== Logo ====================
              // Text(
              //   'NichLine',
              //   style: TextStyle(
              //     fontSize: 32.sp,
              //     fontWeight: FontWeight.bold,
              //     color: const Color(0xFF2DD4BF), // Cyan
              //   ),
              // ),
              CustomImage(
                imageSrc: AppImages.splashScreenImage,
                height: 50.h,
                width: 50.h,
              ),

              SizedBox(height: 30.h),

              // ==================== Title ====================
              CustomText(
                text: 'Set Up Your Recovery Key',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),

              SizedBox(height: 12.h),

              // ==================== Subtitle ====================
              CustomText(
                text: 'Check your authenticator app or SMS.',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.7),
              ),

              SizedBox(height: 5.h),

              // ==================== Icon Container ====================
              Center(
                child: CustomImage(
                  imageSrc: AppImages.recoveryOne,
                  height: 200.h,
                  width: 200.w,
                  boxFit: BoxFit.fill,
                  fit: BoxFit.cover,
                  scale: 1,
                  //imageColor: AppColors.loading,
                ),
              ),

              SizedBox(height: 2.h),

              // ==================== Description ====================
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                child: CustomText(
                  text:
                      'Your recovery key protects your messages and keys. If you lose your device, you can restore access securely.',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                  maxLines: 4,
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 30.h),

              // ==================== Progress Steps ====================
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildStepIndicator(0, 'Setup', true),
                    buildStepLine(currentStep.value >= 1),
                    buildStepIndicator(1, 'Generate', false),
                    buildStepLine(currentStep.value >= 2),
                    buildStepIndicator(2, 'Save', currentStep.value >= 2),
                    buildStepLine(currentStep.value >= 3),
                    buildStepIndicator(3, 'Verify', currentStep.value >= 3),
                  ],
                ),
              ),

              SizedBox(height: 60.h),

              // ==================== Generate Button ====================
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: isGenerating.value ? null : _handleGenerateKey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DD4BF),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      disabledBackgroundColor: const Color(
                        0xFF2DD4BF,
                      ).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: isGenerating.value
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Generate My Key',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              //SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  final AuthController authController = Get.find<AuthController>();

  // ==================== Generate Recovery Key Handler ====================
  void _handleGenerateKey() async {
    // Start loading
    isGenerating.value = true;

    try {
      // API Call Simulation via Controller
      await Future.delayed(const Duration(seconds: 2));

      authController.generateRecoveryKey();

      // Update local state if needed, or just rely on controller state in next screen
      recoveryKey.value = authController.recoveryKey.value;

      isGenerating.value = false;

      // Success message
      Get.snackbar(
        'Success',
        'Recovery key generated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      //================Get to Next Screen===============================

      // Update step to "Generate" complete
      currentStep.value = 1;
      Get.to(() => RecoveryScreen2());
      // Navigate to next screen (Save key screen)

      debugPrint('✅ Recovery Key Generated: ${recoveryKey.value}');
    } catch (e) {
      isGenerating.value = false;

      Get.snackbar(
        'Error',
        'Failed to generate recovery key. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      debugPrint('❌ Generate Recovery Key Error: $e');
    }
  }
}
