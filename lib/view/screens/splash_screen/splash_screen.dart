// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/screens/onboarding_screen/views/onboarding_screen_one.dart';
import '../../../core/app_routes/app_routes.dart';
import '../../../utils/app_images/app_images.dart';
import '../../components/custom_image/custom_image.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for 10 seconds
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Create animation from 0.0 to 1.0
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      Get.offAll(() => OnboardingScreenOne(),transition: Transition.fade ,duration: Duration(milliseconds: 500));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            color: const Color.fromARGB(255, 14, 21, 39),
            height: double.infinity,
            width: double.infinity,
          ),

          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                CustomImage(
                  imageSrc: AppImages.splashScreenImage,
                  boxFit: BoxFit.fill,
                  fit: BoxFit.fill,
                  height: 100.h,
                  width: 50.w,
                  scale: 10,
                ),
            
                // Slogan Text
                Transform.translate(
                  offset: Offset(0, -65.9.h),
                  child: CustomImage(
                    imageSrc: AppImages.sloganText,
                    boxFit: BoxFit.none,
                    fit: BoxFit.none,
                    height: 100.h,
                    width: 50.w,
                    scale: 2,
                  ),
                ),
              
                // Animated Loading Bar
                Transform.translate(
                  offset: Offset(0, -70),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70.w),
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: SizedBox(
                            height: 6.h,
                            child: LinearProgressIndicator(
                              value: _animation.value,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.loading,
                              ),
                              minHeight: 6.h,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}