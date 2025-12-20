import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/helper/shared_prefe/shared_prefe.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/auth_screen/auth_screen.dart';
import 'package:niche_line_messaging/view/screens/home/views/home_screen.dart';
import 'package:niche_line_messaging/view/screens/onboarding_screen/views/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward().whenComplete(() {
      _navigateNext();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Navigation Logic
  Future<void> _navigateNext() async {
    // Using simple checks as requested, relying on the animation for the delay
    String? token = await SharePrefsHelper.getString('userToken');

    if (token != null && token.isNotEmpty) {
      Get.offAll(() => HomeScreen());
      return;
    }

    bool seenOnboarding =
        await SharePrefsHelper.getBool('seenOnboarding') ?? false;

    if (seenOnboarding) {
      Get.offAll(() => OnboardingScreen());
    } else {
      Get.offAll(() => OnboardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: CustomImage(
                  imageSrc: AppImages.splashScreenImage,
                  height: 100.h,
                  width: 280.w,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Private. Secure. Yours.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 20.h),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SizedBox(
                  width: 250.w,
                  child: LinearProgressIndicator(
                    value: _controller.value,
                    backgroundColor: AppColors.loading.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.loading,
                    ),
                    minHeight: 5.h,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
