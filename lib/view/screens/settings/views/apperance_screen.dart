import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/screens/settings/controller/theme_controller.dart';
import 'package:niche_line_messaging/view/screens/settings/views/settings_main_screen.dart';

// ==================== Appearance Screen ====================
class AppearanceScreen extends StatelessWidget {
  AppearanceScreen({super.key});

  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Use controller's isDarkMode instead of Theme.of(context)
      final isDark = themeController.isDarkMode;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0E1527) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? const Color(0xFF2DD4BF) : Colors.black,
            ),
            onPressed: () => Get.to(() =>SettingsScreen()),
          ),
          title: Text(
            'Appearance',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: isDark
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF000000),
                      Color.fromARGB(255, 31, 41, 55),
                    ],
                    tileMode: TileMode.mirror,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                )
              : const BoxDecoration(color: Color(0xFFF5F5F5)),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),

                // ==================== Message Alerts Section ====================
                _buildSectionCard(
                  isDark: isDark,
                  title: 'Theme Settings',
                  children: [
                    // Light Mode
                    _buildThemeOption(
                      isDark: isDark,
                      icon: Icons.light_mode,
                      title: 'Light Mode',
                      subtitle: 'Use a bright theme',
                      isSelected: themeController.themeMode == 'light',
                      onTap: () => {
                        themeController.setThemeMode('light'),
                        Get.snackbar(
                          'Theme Updated',
                          'App theme changed to Light Mode',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.green,
                          colorText: AppColors.white,
                        ),
                      },
                    ),

                    Divider(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      height: 1,
                    ),

                    // Dark Mode
                    _buildThemeOption(
                      isDark: isDark,
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      subtitle: 'Best for low light and privacy',
                      isSelected: themeController.themeMode == 'dark',
                      onTap: () => themeController.setThemeMode('dark'),
                    ),

                    Divider(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      height: 1,
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // ==================== Font Size Section ====================
                _buildSectionCard(
                  isDark: isDark,
                  title: 'Font Size',
                  children: [
                    SizedBox(height: 8.h),

                    // Font Size Slider
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.black.withOpacity(0.7),
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: const Color(0xFF2DD4BF),
                                  inactiveTrackColor: isDark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.2),
                                  thumbColor: const Color(0xFF2DD4BF),
                                  overlayColor: const Color(
                                    0xFF2DD4BF,
                                  ).withOpacity(0.2),
                                  trackHeight: 4.h,
                                ),
                                child: Slider(
                                  value: themeController.fontSize.value,
                                  min: 12.0,
                                  max: 20.0,
                                  divisions: 8,
                                  onChanged: (value) {
                                    themeController.updateFontSize(value);
                                  },
                                ),
                              ),
                            ),
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Sample Chat Preview
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            'Sample chat message preview',
                            style: TextStyle(
                              fontSize: themeController.fontSize.value.sp,
                              color: isDark
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),
                  ],
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ==================== Section Card Widget ====================
  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color.fromARGB(255, 14, 21, 39) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2DD4BF).withOpacity(0.3)
              : Colors.black.withOpacity(0.1),
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
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  // ==================== Theme Option Widget ====================
  Widget _buildThemeOption({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: const Color(0xFF2DD4BF), size: 22.sp),
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
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2DD4BF)
                      : isDark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.3),
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF2DD4BF)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Theme Data Configuration ====================
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2DD4BF),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2DD4BF),
      secondary: Color(0xFF2DD4BF),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2DD4BF),
    scaffoldBackgroundColor: const Color(0xFF000000),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0E1527),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2DD4BF),
      secondary: Color(0xFF2DD4BF),
    ),
  );
}
