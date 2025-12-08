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
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back()
          ),
          title: const Text('Appearance'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              _buildSectionCard(
                context,
                title: 'Theme Settings',
                children: [
                  _buildThemeOption(
                    context,
                    icon: Icons.light_mode,
                    title: 'Light Mode',
                    subtitle: 'Use a bright theme',
                    isSelected: themeController.themeMode.value == 'light',
                    onTap: () => themeController.setThemeMode('light'),
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor,
                    height: 1,
                  ),
                  _buildThemeOption(
                    context,
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Best for low light and privacy',
                    isSelected: themeController.themeMode.value == 'dark',
                    onTap: () => themeController.setThemeMode('dark'),
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor,
                    height: 1,
                  ),
                  _buildThemeOption(
                    context,
                    icon: Icons.settings_system_daydream,
                    title: 'System',
                    subtitle: 'Follow the device theme',
                    isSelected: themeController.themeMode.value == 'system',
                    onTap: () => themeController.setThemeMode('system'),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildSectionCard(
                context,
                title: 'Font Size',
                children: [
                  SizedBox(height: 8.h),
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
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Theme.of(context).colorScheme.primary,
                                inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                thumbColor: Theme.of(context).colorScheme.primary,
                                overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Text(
                          'Sample chat message preview',
                          style: TextStyle(
                            fontSize: themeController.fontSize.value.sp,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
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
      );
    });
  }

  Widget _buildSectionCard(BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
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
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, {
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22.sp),
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
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
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
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                  width: 2,
                ),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
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

class AppTheme {
  static ThemeData lightTheme(double baseFontSize) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2DD4BF),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w600)
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2DD4BF),
      secondary: Color(0xFF2DD4BF),
      background: Color(0xFFF5F5F5),
      surface: Colors.white,
      onBackground: Colors.black,
      onSurface: Colors.black,
    ),
    cardColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.black),
    dividerColor: Colors.black.withOpacity(0.1),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: (baseFontSize * 1.5).sp, color: Colors.black),
      displayMedium: TextStyle(fontSize: (baseFontSize * 1.25).sp, color: Colors.black),
      displaySmall: TextStyle(fontSize: (baseFontSize * 1.15).sp, color: Colors.black),
      headlineMedium: TextStyle(fontSize: (baseFontSize * 1.1).sp, color: Colors.black),
      headlineSmall: TextStyle(fontSize: (baseFontSize * 1.05).sp, color: Colors.black),
      titleLarge: TextStyle(fontSize: baseFontSize.sp, color: Colors.black),
      bodyLarge: TextStyle(fontSize: baseFontSize.sp, color: Colors.black),
      bodyMedium: TextStyle(fontSize: (baseFontSize * 0.9).sp, color: Colors.black87),
      bodySmall: TextStyle(fontSize: (baseFontSize * 0.8).sp, color: Colors.black54),
    ),
  );

  static ThemeData darkTheme(double baseFontSize) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2DD4BF),
    scaffoldBackgroundColor: const Color(0xFF0E1527),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0E1527),
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF2DD4BF)),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600)
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2DD4BF),
      secondary: Color(0xFF2DD4BF),
      background: Color(0xFF0E1527),
      surface: Color(0xFF1A1F3A),
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    cardColor: const  Color(0xFF0E1527),
    iconTheme: const IconThemeData(color: Colors.white),
    dividerColor: Colors.white.withOpacity(0.1),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: (baseFontSize * 1.5).sp, color: Colors.white),
      displayMedium: TextStyle(fontSize: (baseFontSize * 1.25).sp, color: Colors.white),
      displaySmall: TextStyle(fontSize: (baseFontSize * 1.15).sp, color: Colors.white),
      headlineMedium: TextStyle(fontSize: (baseFontSize * 1.1).sp, color: Colors.white),
      headlineSmall: TextStyle(fontSize: (baseFontSize * 1.05).sp, color: Colors.white),
      titleLarge: TextStyle(fontSize: baseFontSize.sp, color: Colors.white),
      bodyLarge: TextStyle(fontSize: baseFontSize.sp, color: Colors.white),
      bodyMedium: TextStyle(fontSize: (baseFontSize * 0.9).sp, color: Colors.white70),
      bodySmall: TextStyle(fontSize: (baseFontSize * 0.8).sp, color: Colors.white54),
    ),
  );
}
