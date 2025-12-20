import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/helper/shared_prefe/shared_prefe.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/auth_screen/auth_screen.dart';

import '../../../../core/app_routes/app_routes.dart';
// import 'package:niche_line_messaging/utils/app_images/app_images.dart'; // আপনার ইমেজ পাথ ইমপোর্ট করুন

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // অনবোর্ডিং ডাটা (আপনার প্রয়োজন মতো টেক্সট এবং ইমেজ পরিবর্তন করুন)
  List<Map<String, String>> onboardingData = [
    {
      "title": "Secure Messaging",
      "text":
          "End-to-end encryption keeps your conversations private and secure.",
      // "image": AppImages.onboarding1, // আপনার ইমেজের পাথ দিন
      "image": AppImages.onBoardingOne, // Placeholder
    },

    {
      "title": "Recovery Key",
      "text":
          "Never lose access to your account with our secure recovery key system.",
      // "image": AppImages.onboarding3,
      "image": AppImages.onBoardingThree, // Placeholder
    },
  ];

  // অনবোর্ডিং দেখা শেষ হলে এই ফাংশন কল হবে
  void _finishOnboarding() async {
    // সেভ করে রাখা হচ্ছে যে ইউজার অনবোর্ডিং দেখেছে
    await SharePrefsHelper.setBool('seenOnboarding', true);
    // Auth স্ক্রিনে যাওয়া
    Get.offAll(() => AuthScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            // ================== PageView Content ==================
            PageView.builder(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) => OnboardingContent(
                title: onboardingData[index]["title"]!,
                text: onboardingData[index]["text"]!,
                image: onboardingData[index]["image"]!,
              ),
            ),

            // ================== Skip Button (Top Right) ==================
            Positioned(
              top: 20.h,
              right: 20.w,
              child: TextButton(
                onPressed: _finishOnboarding, // সরাসরি Auth স্ক্রিনে যাবে
                child: Text(
                  "Skip",
                  style: TextStyle(
                    color: const Color(0xFF2DD4BF),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // ================== Bottom Section (Dots & Button) ==================
            Positioned(
              bottom: 40.h,
              left: 24.w,
              right: 24.w,
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(index: index),
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // Next / Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == onboardingData.length - 1) {
                          _finishOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DD4BF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        _currentPage == onboardingData.length - 1
                            ? "Get Started"
                            : "Next",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dot Indicator Widget
  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 8.w),
      height: 8.h,
      width: _currentPage == index ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF2DD4BF)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}

// Single Page Content Widget
class OnboardingContent extends StatelessWidget {
  final String title, text, image;
  const OnboardingContent({
    super.key,
    required this.title,
    required this.text,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          const Spacer(),
          // Image placeholder - use CustomImage if available
          Image.asset(image, height: 350.h, width: 350.w),
          //const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16.sp,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
