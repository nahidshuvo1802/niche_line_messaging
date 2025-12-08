import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/core/app_routes/app_routes.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/final_recovery_screen.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/widget/setup_line_widget.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/widget/setup_widget.dart';

// ==================== Verify Recovery Key Screen ====================
class RecoveryScreen3 extends StatelessWidget {
  RecoveryScreen3({super.key});

  // ==================== Controllers for 4 Input Fields ====================
  final TextEditingController segment1Controller = TextEditingController();
  final TextEditingController segment2Controller = TextEditingController();
  final TextEditingController segment3Controller = TextEditingController();
  final TextEditingController segment4Controller = TextEditingController();

  // Focus nodes for auto-focus management
  final FocusNode focus1 = FocusNode();
  final FocusNode focus2 = FocusNode();
  final FocusNode focus3 = FocusNode();
  final FocusNode focus4 = FocusNode();

  // ==================== Reactive State ====================
  final RxBool isVerifying = false.obs;
  final RxBool isButtonPressed = false.obs;

  // Actual recovery key from previous screen
  final String actualRecoveryKey = 'M2K4-9LQX-5T7A-2V0F';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        // LayoutBuilder ব্যবহার করা হয়েছে স্ক্রিনের হাইট পাওয়ার জন্য
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // ConstrainedBox নিশ্চিত করে যে কন্টেন্ট কম হলেও পেজটি পুরো স্ক্রিন জুড়ে থাকে
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // spaceBetween দেওয়ার ফলে Spacer এর কাজ করবে (উপরের কন্টেন্ট উপরে, বাটন নিচে)
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // টপ পার্ট (লোগো, ইনপুট, স্টেপস) একসাথে রাখা হলো
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
                            text: 'This key is unique to you. Save it\nsomewhere secure.',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.7),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            bottom: 40.h,
                          ),

                          // ==================== 4 Input Segments ====================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSegmentInput(segment1Controller, focus1, focus2),
                              SizedBox(width: 12.w),
                              _buildSegmentInput(segment2Controller, focus2, focus3),
                              SizedBox(width: 12.w),
                              _buildSegmentInput(segment3Controller, focus3, focus4),
                              SizedBox(width: 12.w),
                              _buildSegmentInput(segment4Controller, focus4, null),
                            ],
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
                              Obx(() => buildStepIndicator(3, 'Verify', isButtonPressed.value)),
                            ],
                          ),
                        ],
                      ),

                      // ==================== Verify Button (Bottom Part) ====================
                      Padding(
                        padding: EdgeInsets.only(top: 20.h), // নিচে একটু গ্যাপ রাখা
                        child: Obx(
                              () => SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: isVerifying.value ? null : _handleVerify,
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

  // ==================== Segment Input Widget ====================
  Widget _buildSegmentInput(
      TextEditingController controller,
      FocusNode currentFocus,
      FocusNode? nextFocus,
      ) {
    return Container(
      width: 70.w,
      height: 70.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: const Color(0xFF2DD4BF).withOpacity(0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: currentFocus,
          textAlign: TextAlign.center,
          maxLength: 4,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2DD4BF),
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            counterText: '',
            hintText: '••••',
            hintStyle: TextStyle(
              color: const Color(0xFF2DD4BF).withOpacity(0.3),
              fontSize: 20.sp,
              letterSpacing: 4,
            ),
          ),
          onChanged: (value) {
            if (value.length == 4 && nextFocus != null) {
              FocusScope.of(Get.context!).requestFocus(nextFocus);
            }
          },
          onSubmitted: (_) {
            if (nextFocus != null) {
              FocusScope.of(Get.context!).requestFocus(nextFocus);
            }
          },
        ),
      ),
    );
  }

  // ==================== Verify Recovery Key ====================
  void _handleVerify() async {
    String enteredKey =
        '${segment1Controller.text}-${segment2Controller.text}-${segment3Controller.text}-${segment4Controller.text}';

    if (segment1Controller.text.length != 4 ||
        segment2Controller.text.length != 4 ||
        segment3Controller.text.length != 4 ||
        segment4Controller.text.length != 4) {
      Get.snackbar(
        'Invalid Input',
        'Please enter all 4 segments of the recovery key',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isVerifying.value = true;

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (enteredKey.toUpperCase() == actualRecoveryKey.toUpperCase()) {
        isVerifying.value = false;
        Get.snackbar(
          'Success',
          'Recovery key verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        isButtonPressed.value = true;
        Get.offAll(() => const FinalRecoveryScreen());
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

        segment1Controller.clear();
        segment2Controller.clear();
        segment3Controller.clear();
        segment4Controller.clear();
        FocusScope.of(Get.context!).requestFocus(focus1);
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