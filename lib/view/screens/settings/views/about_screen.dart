import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1527),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2DD4BF)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'About',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000000), Color.fromARGB(255, 31, 41, 55)],
                tileMode: TileMode.mirror,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),

                // ==================== App Logo & Info Card ====================
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(30.w),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 14, 21, 39),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF2DD4BF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // App Logo/Name
                      CustomImage(
                        imageSrc: AppImages.splashScreenImage,
                        height: 50.h,
                        width: 50.h,
                      ),

                      SizedBox(height: 5.h),

                      // Tagline
                      Text(
                        'Private. Secure. Yours.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Version Info Box
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF2DD4BF).withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'v1.0.0 • Build 125',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // ==================== Legal & Documents Section ====================
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 14, 21, 39),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF2DD4BF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Legal & Documents',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Privacy Policy
                      _buildDocumentOption(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Learn how we protect your data',
                        onTap: () {
                          Get.snackbar(
                            'Privacy Policy',
                            'Opening privacy policy...',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF2DD4BF),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 1),
                          );
                        },
                      ),

                      Divider(color: Colors.white.withOpacity(0.1), height: 1),

                      // Security Whitepaper
                      _buildDocumentOption(
                        icon: Icons.security_outlined,
                        title: 'Security Whitepaper',
                        subtitle: 'Understand NichLine\'s encryption methods',
                        onTap: () {
                          Get.snackbar(
                            'Security Whitepaper',
                            'Opening security whitepaper...',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF2DD4BF),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 1),
                          );
                        },
                      ),

                      Divider(color: Colors.white.withOpacity(0.1), height: 1),

                      // Terms of Service
                      _buildDocumentOption(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        subtitle: 'Read our terms and conditions',
                        onTap: () {
                          Get.snackbar(
                            'Terms of Service',
                            'Opening terms of service...',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF2DD4BF),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 1),
                          );
                        },
                      ),
                    ],
                  ),
                ),


                // ==================== Footer ====================
                SizedBox(height: 20.h),
                Text(
                  '© 2025 NichLine. All rights reserved.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Document Option Widget ====================
  Widget _buildDocumentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: const Color(0xFF2DD4BF), size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
