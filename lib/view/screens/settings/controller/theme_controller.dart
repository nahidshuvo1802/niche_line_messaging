import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';

class ThemeController extends GetxController {
  // ============ Reactive Variables ============
  var themeMode = 'dark'.obs; // ✅ Reactive string
  var fontSize = 16.0.obs;      // ✅ Reactive double

  // ============ Computed Getter ============
  bool get isDarkMode {
    if (themeMode.value == 'dark') return true;
    if (themeMode.value == 'light') return false;
    // System default check
    final brightness = Get.context?.theme.brightness;
    return brightness == Brightness.dark;
  }

  // ============ Theme Mode Change ============
  void setThemeMode(String mode) {
    themeMode.value = mode;
    updateTheme();

    // optional feedback
    Future.delayed(const Duration(milliseconds: 10), () {
      Get.snackbar(
        'Theme Updated',
        'App theme changed to ${mode.capitalizeFirst} Mode',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.green,
        colorText: Colors.white,
      );
    });
  }

  void updateTheme() {
    if (themeMode.value == 'light') {
      Get.changeThemeMode(ThemeMode.light);
    } else if (themeMode.value == 'dark') {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  // ============ Font Size Update ============
  void updateFontSize(double newSize) {
    fontSize.value = newSize;
  }
}
