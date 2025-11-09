 import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/screens/home/views/home_screen.dart';
import 'package:niche_line_messaging/view/screens/settings/views/about_screen.dart';
import 'package:niche_line_messaging/view/screens/settings/views/accounts_screen.dart';
import 'package:niche_line_messaging/view/screens/settings/views/apperance_screen.dart';
import 'package:niche_line_messaging/view/screens/settings/views/notification_screen.dart';
import 'package:niche_line_messaging/view/screens/settings/views/privacy_security_screen.dart';
import 'package:niche_line_messaging/view/screens/settings/views/secure_folder_screen.dart';

// ==================== Settings Screen - UI Only ====================
// Controller and API integration করবেন পরে
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1527), // Dark navy background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1527),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2DD4BF)),
          onPressed: () => Get.to(() => HomeScreen()),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 8.h),

            // ==================== Secure Folder Highlight Card ====================
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF2DD4BF),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  GestureDetector(
                    onTap: () => Get.to(SecureFolderScreen()),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2DD4BF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.folder_outlined,
                        color: const Color(0xFF2DD4BF),
                        size: 28.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Folder',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Access and manage your encrypted media',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ==================== Settings Options List ====================
            Column(
              children: [
                // Secure Folder
                _buildSettingOption(
                  icon: Icons.folder_outlined,
                  title: 'Secure Folder',
                  subtitle: 'Access and manage your encrypted media',
                  onTap: () {
                    debugPrint('Secure Folder clicked');
                    Get.to(SecureFolderScreen());
                    // TODO: Navigate to Secure Folder screen
                    // Get.toNamed(AppRoutes.secureFolder);
                  },
                ),

                _buildDivider(),

                // Account
                _buildSettingOption(
                  icon: Icons.person_outline,
                  title: 'Account',
                  subtitle: 'Manage your account and devices',
                  onTap: () {
                    debugPrint('Account clicked');
                    // TODO: Navigate to Account screen
                    Get.to(() => AccountScreen());
                  },
                ),

                _buildDivider(),

                // Privacy & Security
                _buildSettingOption(
                  icon: Icons.lock_outline,
                  title: 'Privacy & Security',
                  subtitle: 'Control who sees your info and how your data is protected',
                  onTap: () {
                    debugPrint('Privacy & Security clicked');
                    Get.to(() => PrivacySecurityScreen());
                    // TODO: Navigate to Privacy & Security screen
                    // Get.toNamed(AppRoutes.privacySecurity); 
                  },
                ),

                _buildDivider(),

                // Notifications
                _buildSettingOption(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage message alerts and Do Not Disturb',
                  onTap: () {
                    debugPrint('Notifications clicked');
                    // TODO: Navigate to Notifications screen
                    Get.to(() => NotificationsScreen());
                  },
                ),

                _buildDivider(),

                // Appearance
                _buildSettingOption(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Customize theme, font, and chat look',
                  onTap: () {
                    debugPrint('Appearance clicked');
                    // TODO: Navigate to Appearance screen
                     Get.to(() => AppearanceScreen());
                  },
                ),

                _buildDivider(),

                // About
                _buildSettingOption(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Customize theme, font, and chat look',
                  onTap: () {
                    debugPrint('About clicked');
                    // TODO: Navigate to About screen
                    Get.to(() => AboutScreen());
                  },
                ),
              ],
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ==================== Setting Option Widget ====================
  Widget _buildSettingOption({
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
            // Icon
            Icon(
              icon,
              color: const Color(0xFF2DD4BF),
              size: 24.sp,
            ),

            SizedBox(width: 16.w),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Divider Widget ====================
  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.1),
      height: 1,
      thickness: 1,
    );
  }
}