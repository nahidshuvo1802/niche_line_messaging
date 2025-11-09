import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/default_transitions.dart';
import 'package:niche_line_messaging/core/app_routes/app_routes.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/screens/onboarding_screen/views/onboarding_screen_two.dart';

class OnboardingScreenOne extends StatelessWidget {
  const OnboardingScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1527),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Spacer(flex: 2),

              // Image Placeholder
              Center(
                child: CustomImage(
                  imageSrc: AppImages.onBoardingOne,
                  height: 350.h,
                  width: 300.w,
                  boxFit: BoxFit.fitHeight,
                  fit: BoxFit.cover,
                  scale: 2,
                  //imageColor: AppColors.loading,
                ),
              ),

              SizedBox(height: 80.h),

              // Title
              Text(
                'Your Privacy, Our Priority',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              // Description
              Text(
                'Only you and your recipient can read\nmessages.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40.h),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIndicator(isActive: true),
                  SizedBox(width: 8.w),
                  _buildIndicator(isActive: false),
                  SizedBox(width: 8.w),
                  _buildIndicator(isActive: false),
                ],
              ),

              const Spacer(flex: 2),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to next onboarding screen or login
                    HapticFeedback.lightImpact();
                    Get.to(() => OnboardingScreenTwo());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    foregroundColor: const Color(0xFF0E1527),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Next',
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

  Widget _buildIndicator({required bool isActive}) {
    return Container(
      height: 8.h,
      width: isActive ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF2DD4BF)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
