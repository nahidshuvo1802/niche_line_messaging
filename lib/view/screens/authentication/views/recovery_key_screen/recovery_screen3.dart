import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/components/custom_text_field/custom_text_field.dart'; // Added Import
import 'package:niche_line_messaging/view/screens/authentication/controller/auth_controller.dart';

import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/widget/setup_line_widget.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/widget/setup_widget.dart';

// ==================== Verify Recovery Key Screen ====================
class RecoveryScreen3 extends StatefulWidget {
  const RecoveryScreen3({super.key});

  @override
  State<RecoveryScreen3> createState() => _RecoveryScreen3State();
}

class _RecoveryScreen3State extends State<RecoveryScreen3> {
  // ==================== Controller ====================
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController recoveryKeyController = TextEditingController();

  // ==================== Reactive State ====================
  final RxBool isVerifying = false.obs;
  final RxBool isButtonPressed = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWarningDialog();
    });
  }

  // Track if close button should be shown
  final RxBool _showCloseButton = false.obs;

  void _showWarningDialog() {
    _showCloseButton.value = false; // Reset on dialog open

    Get.dialog(
      Obx(
        () => AlertDialog(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: Colors.red.withOpacity(0.5), width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28.sp),
              SizedBox(width: 10.w),
              Text(
                "Warning",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Recovery key is sensitive! Kindly do not lose it.\nIf lost, you will NOT be able to recover your data.",
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),

              // Show timer OR close button
              if (!_showCloseButton.value)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 0.0),
                  duration: const Duration(seconds: 5),
                  builder: (context, value, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 50.w,
                          width: 50.w,
                          child: CircularProgressIndicator(
                            value: value,
                            color: Colors.red,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            strokeWidth: 4,
                          ),
                        ),
                        Text(
                          "${(5 * value).ceil()}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                  onEnd: () {
                    _showCloseButton.value = true;
                  },
                ),

              if (_showCloseButton.value)
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DD4BF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: () {
                        if (Get.isDialogOpen ?? false) {
                          Get.back();
                        }
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 40.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          // ==================== Logo ====================
                          CustomImage(
                            imageSrc: AppImages.splashScreenImage,
                            height: 50.h,
                            width: 50.h,
                          ),

                          SizedBox(height: 20.h),

                          // ==================== Title ====================
                          CustomText(
                            text: 'Confirm Your Recovery Key',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            bottom: 12.h,
                          ),

                          CustomText(
                            text:
                                'This key is unique to you. Save it\nsomewhere secure.',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.7),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            bottom: 40.h,
                          ),

                          // ==================== Single Input Field ====================
                          CustomTextField(
                            textEditingController: recoveryKeyController,
                            hintText: 'Paste your recovery key here',
                            fillColor: Colors.white.withOpacity(0.05),
                            fieldBorderColor: const Color(
                              0xFF2DD4BF,
                            ).withOpacity(0.5),
                            fieldBorderRadius: 12.r,
                            inputTextStyle: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2DD4BF),
                              letterSpacing: 1.5,
                            ),
                            hintStyle: TextStyle(
                              color: const Color(0xFF2DD4BF).withOpacity(0.3),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 0,
                            ),
                            textAlign: TextAlign.center,
                            onChanged: (val) {
                              // Optional: Auto-verify if needed?
                            },
                          ),

                          SizedBox(height: 40.h),

                          // ==================== Progress Steps ====================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildStepIndicator(0, 'Setup', true),
                              buildStepLine(true),
                              buildStepIndicator(1, 'Generate', true),
                              buildStepLine(true),
                              buildStepIndicator(2, 'Save', true),
                              buildStepLine(true),
                              Obx(
                                () => buildStepIndicator(
                                  3,
                                  'Verify',
                                  isButtonPressed.value,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // ==================== Verify Button (Bottom Part) ====================
                      Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: Column(
                          children: [
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                height: 56.h,
                                child: ElevatedButton(
                                  onPressed: isVerifying.value
                                      ? null
                                      : _handleVerify,
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
                                  child: isVerifying.value
                                      ? SizedBox(
                                          width: 24.w,
                                          height: 24.w,
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          'Verify Key',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            // ==================== Cancel Registration Button ====================
                            TextButton(
                              onPressed: () => _showCancelDialog(),
                              child: Text(
                                'Cancel Registration',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==================== Cancel Registration Dialog ====================
  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: Colors.red.withOpacity(0.5), width: 1.5),
        ),
        title: Text(
          'Cancel Registration?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel? All your progress will be lost.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'No, Continue',
              style: TextStyle(
                color: const Color(0xFF2DD4BF),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authController.cancelRegistration();
            },
            child: Text(
              'Yes, Cancel',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Verify Recovery Key ====================
  void _handleVerify() async {
    String enteredKey = recoveryKeyController.text.trim();

    if (enteredKey.isEmpty) {
      Get.snackbar(
        'Invalid Input',
        'Please enter your recovery key',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isVerifying.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1)); // Small UX delay

      if (enteredKey.toUpperCase() ==
          authController.recoveryKey.value.toUpperCase()) {
        // 1. Key is valid. Now call Registration API
        await authController.registerUser();

        isVerifying.value = false;

        // Navigation is handled inside authController.registerUser() on success
      } else {
        isVerifying.value = false;
        Get.snackbar(
          'Verification Failed',
          'The recovery key you entered doesn\'t match. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isVerifying.value = false;
      Get.snackbar(
        'Error',
        'Failed to verify recovery key. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
