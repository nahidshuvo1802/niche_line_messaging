import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/screens/home/views/home_screen.dart';

class SubscriptionUpgradeScreen extends StatelessWidget {
  const SubscriptionUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              SizedBox(height: 16.h),

              Icon(Icons.shield, color: AppColors.loading, size: 42.sp),

              SizedBox(height: 10.h),

              Text(
                "Unlock Even More with NichLine",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10.h),

              Text(
                "You've been loving NichLine! Upgrade to our Best Value or Commit & Save Big options and get 15-30% off your subscription.",
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.5,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 28.h),

              _featureCard(
                title: "Best Value",
                saveTextColor: Colors.greenAccent,
                saveLabel: "Save 30%",
                features: [
                  "End-to-end encryption",
                  "Premium security features",
                  "Priority support",
                ],
              ),

              SizedBox(height: 18.h),

              _featureCard(
                title: "Best Value",
                saveTextColor: Colors.orangeAccent,
                saveLabel: "Save 15%",
                features: [
                  "3 years of secure messaging",
                  "Price lock guarantee",
                  "Maximum savings",
                ],
              ),

              SizedBox(height: 28.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    "Upgrade to \$9.99/year →",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFF2DD4BF), width: 1.3),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    "Upgrade to \$24.99 for 3 years →",
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2DD4BF)),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              TextButton(
                onPressed: () {
                  Get.to(() => HomeScreen());
                },
                child: Text(
                  "Maybe later",
                  style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                ),
              ),

              SizedBox(height: 18.h),

              Text(
                "🔒 256-bit encryption     🛡️ Zero logs",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white38,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard({
    required String title,
    required String saveLabel,
    required Color saveTextColor,
    required List<String> features,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.primary,
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: saveTextColor.withOpacity(.15),
                ),
                child: Text(
                  saveLabel,
                  style: TextStyle(color: saveTextColor, fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...features.map(
            (f) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16.sp, color: const Color(0xFF2DD4BF)),
                  SizedBox(width: 8.w),
                  Text(f, style: TextStyle(color: Colors.white70, fontSize: 13.5.sp)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
