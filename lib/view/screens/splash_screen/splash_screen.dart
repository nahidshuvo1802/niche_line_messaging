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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  // নতুন নেভিগেশন লজিক
  Future<void> _navigateNext() async {
    // ৩ সেকেন্ড অপেক্ষা
    await Future.delayed(const Duration(seconds: 3));

    // ১. চেক করা ইউজার লগইন আছে কিনা (আপনার টোকেন সেভ করার লজিক অনুযায়ী)
    // ধরে নিচ্ছি 'userToken' থাকলে ইউজার লগইনড
    String? token = await SharePrefsHelper.getString('userToken');

    if (token != null && token.isNotEmpty) {
      // ইউজার লগইন থাকলে সরাসরি হোম
      Get.offAll(() => HomeScreen());
      return;
    }

    // ২. যদি লগইন না থাকে, চেক করা অনবোর্ডিং দেখেছে কিনা
    bool seenOnboarding = await SharePrefsHelper.getBool('seenOnboarding') ?? false;

    if (seenOnboarding) {
      // অনবোর্ডিং দেখা থাকলে সরাসরি Auth স্ক্রিনে
      //Get.offAll(()=> AuthScreen());
      Get.offAll(()=> OnboardingScreen());
    } else {
      // প্রথমবার অ্যাপ ওপেন করলে অনবোর্ডিং স্ক্রিনে
      Get.offAll(()=> OnboardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Transform.scale(
          scale: 0.9,
          child: CustomImage(
            imageSrc: AppImages.splashScreenImage,
            height: 100.h,
            width: 280.w,
          ),
        ),
      ),
    );
  }
}