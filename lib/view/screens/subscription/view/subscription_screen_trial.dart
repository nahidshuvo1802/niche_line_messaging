import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/screens/home/views/home_screen.dart';
import 'package:niche_line_messaging/view/screens/subscription/view/subscription_screen_pricing.dart';

class SubscriptionScreenTrial extends StatelessWidget {
  const SubscriptionScreenTrial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              SizedBox(height: 80.h),

              // Shield Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A3A4A),
                  border: Border.all(
                    color: const Color(0xFF2DD4BF),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DD4BF).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shield,
                  color: const Color(0xFF2DD4BF),
                  size: 40.sp,
                ),
              ),

              SizedBox(height: 24.h),

              // Title
              Text(
                'Your Secure Messaging Space',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              // Progress Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgressDot(true, true),
                  _buildProgressLine(true),
                  _buildProgressDot(true, false),
                  _buildProgressLine(false),
                  _buildProgressDot(false, false),
                ],
              ),

              SizedBox(height: 48.h),

              // Days Active
              Text(
                '7',
                style: TextStyle(
                  fontSize: 56.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2DD4BF),
                  height: 1,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                'Days Active',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),

              SizedBox(height: 32.h),

              // Message
              Text(
                'You\'ve been using NichLine for 1 week! How\'s your\nsecure messaging going?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => HomeScreen());
                    Get.snackbar(
                      'Welcome Back',
                      'Continuing to NichLine...',
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
                  ),
                  child: Text(
                    'Continue to Enjoy NichLine',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Trial Reminder
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withOpacity(0.5),
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      children: [
                        const TextSpan(text: 'Don\'t forget! Your trial ends in '),
                        TextSpan(
                          text: '53 days',
                          style: TextStyle(
                            color: const Color(0xFF2DD4BF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool isActive, bool isCurrent) {
    return Container(
      width: isCurrent ? 12.w : 8.w,
      height: isCurrent ? 12.w : 8.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? const Color(0xFF2DD4BF)
            : Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      width: 40.w,
      height: 2.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF2DD4BF)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1.r),
      ),
    );
  }
}

// Alternative with animation
class NichLineTrialStatusAnimated extends StatefulWidget {
  const NichLineTrialStatusAnimated({super.key});

  @override
  State<NichLineTrialStatusAnimated> createState() =>
      _NichLineTrialStatusAnimatedState();
}

class _NichLineTrialStatusAnimatedState
    extends State<NichLineTrialStatusAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<int> _counterAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _counterAnimation = IntTween(begin: 0, end: 7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
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
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              SizedBox(height: 80.h),

              // Animated Shield Icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A3A4A),
                    border: Border.all(
                      color: const Color(0xFF2DD4BF),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2DD4BF).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shield,
                    color: const Color(0xFF2DD4BF),
                    size: 40.sp,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Title
              Text(
                'Your Secure Messaging Space',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              // Progress Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgressDot(true, true),
                  _buildProgressLine(true),
                  _buildProgressDot(true, false),
                  _buildProgressLine(false),
                  _buildProgressDot(false, false),
                ],
              ),

              SizedBox(height: 48.h),

              // Animated Days Active Counter
              AnimatedBuilder(
                animation: _counterAnimation,
                builder: (context, child) {
                  return Text(
                    '${_counterAnimation.value}',
                    style: TextStyle(
                      fontSize: 56.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2DD4BF),
                      height: 1,
                    ),
                  );
                },
              ),

              SizedBox(height: 8.h),

              Text(
                'Days Active',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),

              SizedBox(height: 32.h),

              // Message
              Text(
                'You\'ve been using NichLine for 1 week! How\'s your\nsecure messaging going?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.snackbar(
                      'Welcome Back',
                      'Continuing to NichLine...',
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
                  ),
                  child: Text(
                    'Continue to Enjoy NichLine',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Trial Reminder
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withOpacity(0.5),
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      children: [
                        const TextSpan(text: 'Don\'t forget! Your trial ends in '),
                        TextSpan(
                          text: '53 days',
                          style: TextStyle(
                            color: const Color(0xFF2DD4BF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool isActive, bool isCurrent) {
    return Container(
      width: isCurrent ? 12.w : 8.w,
      height: isCurrent ? 12.w : 8.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? const Color(0xFF2DD4BF)
            : Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      width: 40.w,
      height: 2.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF2DD4BF)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1.r),
      ),
    );
  }
}