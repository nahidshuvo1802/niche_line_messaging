import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/authentication/controller/auth_controller.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/recovery_screen3.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/widget/setup_line_widget.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/widget/setup_widget.dart';

// ==================== Save Recovery Key Screen ====================
// User এর generated recovery key display করে এবং copy করার option দেয়
// Backend থেকে key আসবে, frontend এ শুধু display এবং copy
class RecoveryScreen2 extends StatelessWidget {
  RecoveryScreen2({super.key});

  // ==================== Controller ====================
  final AuthController authController = Get.find<AuthController>();

  //Loading state
  final RxBool isLoading = true.obs;
  final RxBool isRegenerating = false.obs;

  @override
  Widget build(BuildContext context) {
    // Screen load হলেই recovery key fetch করবে
    _fetchRecoveryKey();

    return Scaffold(
      backgroundColor: AppColors.primary, // Dark navy background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Obx(
            () => isLoading.value ? _buildLoadingState() : _buildMainContent(),
          ),
        ),
      ),
    );
  }

  // ==================== Loading State ====================
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: const Color(0xFF2DD4BF)),
          SizedBox(height: 20.h),
          CustomText(
            text: 'Fetching your recovery key...',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  // ==================== Main Content ====================
  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ==================== Logo ====================
        CustomImage(
          imageSrc: AppImages.splashScreenImage,
          height: 50.h,
          width: 50.h,
        ),

        SizedBox(height: 20.h),

        // ==================== Title Box ====================
        Container(
          width: double.infinity,
          child: Column(
            children: [
              CustomText(
                text: 'Your Recovery Key',
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
              ),
            ],
          ),
        ),

        SizedBox(height: 30.h),

        // ==================== Recovery Key Display Box ====================
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: const Color(0xFF2DD4BF).withOpacity(0.5),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Obx(
            () => SelectableText(
              authController.recoveryKey.value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2DD4BF),
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // ==================== Copy Button ====================
        GestureDetector(
          onTap: _handleCopyKey,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF2DD4BF).withOpacity(0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy, color: const Color(0xFF2DD4BF), size: 18.sp),
                SizedBox(width: 8.w),
                CustomText(
                  text: 'Copy',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2DD4BF),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10.h),

        // ==================== Warning Message ====================
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              CustomText(
                text:
                    'Keep this safe - it\'s the only way to restore your encrypted messages.',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.8),
                textAlign: TextAlign.center,
                maxLines: 3,
                bottom: 12.h,
              ),
              CustomText(
                text: 'NichLine cannot recover your data if this key is lost.',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.red.withOpacity(0.8),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        // ==================== Regenerate Key Link ====================
        Obx(
          () => GestureDetector(
            onTap: isRegenerating.value ? null : _handleRegenerateKey,
            child: CustomText(
              text: isRegenerating.value ? 'Regenerating...' : 'Regenerate Key',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isRegenerating.value
                  ? Colors.grey
                  : const Color(0xFF2DD4BF),
            ),
          ),
        ),

        SizedBox(height: 30.h),

        // ==================== Progress Steps ====================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildStepIndicator(0, 'Setup', true),
            buildStepLine(true),
            buildStepIndicator(1, 'Generate', true),
            buildStepLine(true),
            buildStepIndicator(2, 'Save', false),
            buildStepLine(false),
            buildStepIndicator(3, 'Verify', false),
          ],
        ),

        Spacer(flex: 1),

        // ==================== Continue Button ====================
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: _handleContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DD4BF),
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Continue',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Fetch Recovery Key ====================
  void _fetchRecoveryKey() async {
    // If key is empty, mock fetch delay. If present, show immediately or simulate fetch.
    if (authController.recoveryKey.value.isEmpty) {
      isLoading.value = true;
      try {
        await Future.delayed(const Duration(seconds: 1));
        authController.generateRecoveryKey();
        isLoading.value = false;
        debugPrint(
          '✅ Recovery Key Fetched: ${authController.recoveryKey.value}',
        );
      } catch (e) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to load recovery key.');
      }
    } else {
      isLoading.value = false;
    }
  }

  // ==================== Copy Recovery Key to Clipboard ====================
  void _handleCopyKey() async {
    if (authController.recoveryKey.value.isEmpty) {
      Get.snackbar(
        'Error',
        'No recovery key to copy',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: authController.recoveryKey.value),
    );

    Get.snackbar(
      'Copied',
      'Recovery key copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // ==================== Regenerate Recovery Key ====================
  void _handleRegenerateKey() async {
    // Confirmation dialog
    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: const Color(0xFF2DD4BF).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        title: CustomText(
          text: 'Regenerate Key?',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        content: CustomText(
          text:
              'This will replace your current recovery key. Make sure you\'ve saved the current one.',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.8),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: CustomText(
              text: 'Cancel',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: CustomText(
              text: 'Regenerate',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2DD4BF),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isRegenerating.value = true;

    try {
      await Future.delayed(const Duration(seconds: 2));

      authController.generateRecoveryKey();

      isRegenerating.value = false;

      Get.snackbar(
        'Success',
        'New recovery key generated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      debugPrint(
        '✅ New Recovery Key Generated: ${authController.recoveryKey.value}',
      );
    } catch (e) {
      isRegenerating.value = false;
      Get.snackbar(
        'Error',
        'Failed to regenerate key. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==================== Continue to Next Step ====================
  void _handleContinue() {
    Get.to(() => RecoveryScreen3());

    Get.snackbar(
      'Info',
      'Proceeding to next step...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2DD4BF),
      colorText: AppColors.primary,
    );
  }
}
