import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/components/custom_button/custom_button.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/components/custom_text_field/custom_text_field.dart';
import 'package:niche_line_messaging/view/screens/authentication/controller/auth_controller.dart';
import 'package:niche_line_messaging/core/app_navigation.dart';

class RecoveryKeyInputScreen extends StatelessWidget {
  RecoveryKeyInputScreen({super.key});

  final AuthController controller = Get.find<AuthController>();
  final TextEditingController recoveryKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => AppNav.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: const Color(0xFF2DD4BF),
            size: 20.sp,
          ),
        ),
        title: const CustomText(
          text: 'Security Verification',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w).copyWith(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
              SizedBox(height: 32.h),

              // Lock Icon
              Center(
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2DD4BF).withOpacity(0.1),
                    border: Border.all(
                      color: const Color(0xFF2DD4BF),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: const Color(0xFF2DD4BF),
                    size: 36.sp,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              const CustomText(
                text: 'Enter Recovery Key',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),

              SizedBox(height: 8.h),

              CustomText(
                text:
                    'Your account requires additional verification. Please enter your unique recovery key to proceed.',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.7),
                maxLines: 4,
                textAlign: TextAlign.start,
              ),

              SizedBox(height: 32.h),

              // Recovery Key Input
              CustomTextField(
                textEditingController: recoveryKeyController,
                hintText: 'Enter your recovery key',
                prefixIcon: const Icon(
                  Icons.vpn_key_outlined,
                  color: Colors.white70,
                ),
                maxLines: 1,
              ),

              SizedBox(height: 48.h),

              // Submit Button
              Obx(
                () => controller.isRecoveryLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2DD4BF),
                        ),
                      )
                    : CustomButton(
                        title: 'Verify & Continue',
                        onTap: () {
                          if (recoveryKeyController.text.trim().isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Please enter your recovery key',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          controller.submitRecoveryKey(
                            recoveryKeyController.text.trim(),
                          );
                        },
                      ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
