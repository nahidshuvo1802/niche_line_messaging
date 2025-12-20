import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/components/custom_pin_code/custom_pin_code.dart';
import 'package:niche_line_messaging/view/screens/authentication/controller/auth_controller.dart';
import '../../../../../utils/app_strings/app_strings.dart';
import '../../../../components/custom_button/custom_button.dart';
import '../../../../components/custom_text/custom_text.dart';

// ==================== Two-Factor Authentication OTP Screen ====================
class TwoFactorAuthScreen extends StatelessWidget {
  TwoFactorAuthScreen({super.key});

  final AuthController authController = Get.find<AuthController>();
  final RxInt resendTimer = 24.obs;

  @override
  Widget build(BuildContext context) {
    _startResendTimer();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              CustomImage(
                imageSrc: AppImages.splashScreenImage,
                height: 50.h,
                width: 50.h,
              ),
              SizedBox(height: 80.h),

              CustomText(
                text: 'Two-Factor Authentication',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: 'Check your email/SMS for the code.',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.7),
              ),
              SizedBox(height: 40.h),

              // PIN Code Input (Connected to Controller)
              CustomPinCode(controller: authController.otpController),

              SizedBox(height: 30.h),

              Obx(
                () => CustomText(
                  text:
                      'Resend code in 00:${resendTimer.value.toString().padLeft(2, '0')}',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),

              SizedBox(height: 40.h),

              // Verify Button
              Obx(
                () => CustomButton(
                  height: 50.h,
                  fontSize: 26.sp,
                  width: double.infinity,
                  fillColor: AppColors.loading,
                  title: authController.isOtpVerifying.value
                      ? 'Verifying...'
                      : 'Verify',
                  onTap: authController.isOtpVerifying.value
                      ? () {}
                      : () {
                          // This calls the controller logic which navigates to Recovery Setup
                          authController.verifyOtp();
                        },
                ),
              ),

              SizedBox(height: 20.h),

              // Resend Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: AppStrings.iDidntFind,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7),
                    right: 6.w,
                  ),
                  Obx(
                    () => GestureDetector(
                      onTap: resendTimer.value == 0
                          ? () {
                              authController.sendAgainOtp();
                              _startResendTimer();
                            }
                          : () {},
                      child: CustomText(
                        text: AppStrings.sendAgain,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: resendTimer.value == 0
                            ? const Color(0xFF2DD4BF)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Back Button
              TextButton(
                onPressed: () => Get.back(),
                child: CustomText(
                  text: 'Back',
                  fontSize: 14.sp,
                  color: const Color(0xFF2DD4BF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startResendTimer() {
    resendTimer.value = 24;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer.value > 0) {
        resendTimer.value--;
        return true;
      }
      return false;
    });
  }
}
