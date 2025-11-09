import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/screens/subscription/view/subscription_screen_pricing.dart';
import 'package:niche_line_messaging/view/screens/subscription/view/subscription_screen_trial.dart';

class SubscriptionScreenOne extends StatelessWidget {
  const SubscriptionScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),

              // Logo and Title
              Column(
                children: [
                  // SizedBox(height: 16.h),
                  // NichLine Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Transform.scale(scale: 1.2,child: CustomImage(imageSrc: AppImages.splashScreenTwo,height: 250,width: 250,)),
                      // SizedBox(width: 8.w),
                     /*  Text(
                        'NichLine',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2DD4BF),
                          letterSpacing: 0.5,
                        ),
                      ), */
                    ],
                  ),
                ],
              ),

              // SizedBox(height: 10.h),

              // Welcome Text
              Text(
                'Welcome to NichLine',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              // SizedBox(height: 4.h),

              // Description
              Text(
                'Your private, encrypted space for\nconversations that stay yours. Enjoy 60\ndays free.',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Decorative Circle Background
              Center(
                child: Icon(
                  Icons.lock,
                  color: const Color.fromARGB(29, 45, 212, 190).withOpacity(0.22),
                  size: 120.sp,
                ),
              ),

              const Spacer(),

              // Start Free Trial Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => SubscriptionScreenTrial());
                    Get.snackbar(
                      'Trial Started',
                      'Your 60-day free trial has begun!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2DD4BF),
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                    shadowColor: const Color(0xFF2DD4BF).withOpacity(0.5),
                  ),
                  child: Text(
                    'Start Your Free 60-Day Trial',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Upgrade Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Get.to(() => SubscriptionUpgradeScreen());
                    Get.snackbar(
                      'Upgrade',
                      'Opening upgrade options...',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2DD4BF),
                      colorText: Colors.white,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2DD4BF),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF2DD4BF),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Upgrade Now to Keep Your\nMessages Secure',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Footer Text
              Text(
                'No Ads. No Data Selling. Ever.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

// Alternative version with animated shield
class NichLineWelcomeScreenAnimated extends StatefulWidget {
  const NichLineWelcomeScreenAnimated({super.key});

  @override
  State<NichLineWelcomeScreenAnimated> createState() =>
      _NichLineWelcomeScreenAnimatedState();
}

class _NichLineWelcomeScreenAnimatedState
    extends State<NichLineWelcomeScreenAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 60.h),

              // Animated Logo and Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      // Shield Logo
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2DD4BF),
                              Color(0xFF14B8A6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2DD4BF).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shield,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // NichLine Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield,
                            color: const Color(0xFF2DD4BF),
                            size: 28.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'NichLine',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2DD4BF),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Welcome Text
              Text(
                'Welcome to NichLine',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24.h),

              // Description
              Text(
                'Your private, encrypted space for\nconversations that stay yours. Enjoy 60\ndays free.',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Decorative Circle Background
              Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2DD4BF).withOpacity(0.15),
                      const Color(0xFF2DD4BF).withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.lock_outline,
                    color: const Color(0xFF2DD4BF).withOpacity(0.3),
                    size: 80.sp,
                  ),
                ),
              ),

              const Spacer(),

              // Start Free Trial Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.snackbar(
                      'Trial Started',
                      'Your 60-day free trial has begun!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2DD4BF),
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                    shadowColor: const Color(0xFF2DD4BF).withOpacity(0.5),
                  ),
                  child: Text(
                    'Start Your Free 60-Day Trial',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Upgrade Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Get.snackbar(
                      'Upgrade',
                      'Opening upgrade options...',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2DD4BF),
                      colorText: Colors.white,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2DD4BF),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF2DD4BF),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Upgrade Now to Keep Your\nMessages Secure',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Footer Text
              Text(
                'No Ads. No Data Selling. Ever.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}