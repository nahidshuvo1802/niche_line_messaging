import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/screens/settings/views/change_password_screen.dart';

import 'package:niche_line_messaging/view/screens/settings/controller/privacy_security_controller.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final PrivacySecurityController controller = Get.put(
    PrivacySecurityController(),
  );

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
          'Privacy & Security',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
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
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),

                // ==================== Authentication Section ====================
                _buildSectionCard(
                  title: 'Account Security',
                  children: [
                    _buildNavigationOption(
                      icon: Icons.lock_reset,
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      onTap: () => Get.to(() => ChangePasswordScreen()),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ==================== Messaging Privacy Section ====================
                _buildSectionCard(
                  title: 'Messaging Privacy',
                  children: [
                    // Blocked Contacts
                    _buildNavigationOption(
                      icon: Icons.block,
                      title: 'Blocked Contacts',
                      subtitle: 'View and manage blocked users',
                      onTap: () {},
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // ==================== Danger Zone Section ====================
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: const Color(0x0E1521),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Zone',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'These actions cannot be undone.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () => controller.beginDeleteAllMessagesFlow(),
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Delete All Messages',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

  // ==================== Widget Helpers ====================

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
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
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
          if (children.isNotEmpty) SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNavigationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2DD4BF), size: 24.sp),
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
            trailing ??
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
