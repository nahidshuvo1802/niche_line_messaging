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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.to(() => const HomeScreen()),
        ),
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.to(const SecureFolderScreen()),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.folder_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Folder',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Access and manage your encrypted media',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Column(
              children: [
                _buildSettingOption(
                  context,
                  icon: Icons.folder_outlined,
                  title: 'Secure Folder',
                  subtitle: 'Access and manage your encrypted media',
                  onTap: () {
                    debugPrint('Secure Folder clicked');
                    Get.to(const SecureFolderScreen());
                  },
                ),
                _buildDivider(context),
                _buildSettingOption(
                  context,
                  icon: Icons.person_outline,
                  title: 'Account',
                  subtitle: 'Manage your account and devices',
                  onTap: () {
                    debugPrint('Account clicked');
                    Get.to(() => const AccountScreen());
                  },
                ),
                _buildDivider(context),
                _buildSettingOption(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Privacy & Security',
                  subtitle: 'Control who sees your info and how your data is protected',
                  onTap: () {
                    debugPrint('Privacy & Security clicked');
                    Get.to(() => PrivacySecurityScreen());
                  },
                ),
                _buildDivider(context),
                _buildSettingOption(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage message alerts and Do Not Disturb',
                  onTap: () {
                    debugPrint('Notifications clicked');
                    Get.to(() => NotificationsScreen());
                  },
                ),
                _buildDivider(context),
                _buildSettingOption(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Customize theme, font, and chat look',
                  onTap: () {
                    debugPrint('Appearance clicked');
                    Get.to(() => AppearanceScreen());
                  },
                ),
                _buildDivider(context),
                _buildSettingOption(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Learn more about the app',
                  onTap: () {
                    debugPrint('About clicked');
                    Get.to(() => const AboutScreen());
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

  Widget _buildSettingOption(BuildContext context, {
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
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodySmall?.color,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: Theme.of(context).dividerColor,
      height: 1,
      thickness: 1,
    );
  }
}