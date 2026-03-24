import 'package:get/get.dart';
import 'package:niche_line_messaging/view/screens/authentication/controller/auth_controller.dart';
import 'package:niche_line_messaging/view/screens/splash_screen/splash_screen.dart';
import 'package:niche_line_messaging/view/screens/onboarding_screen/views/onboarding_screen.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/auth_screen/auth_screen.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/verify_pincode_screen/verify_pincode_screen.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/recovery_screen1.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/recovery_key_screen/final_recovery_screen.dart';
import 'package:niche_line_messaging/view/screens/home/views/home_screen.dart';
import 'package:niche_line_messaging/view/screens/subscription/view/subscription_screen_one.dart';

class AppRoutes {
  // ==================== Route Names ====================
  static const String splashScreen = '/splash_screen';
  static const String onboardingScreen = '/onboarding';

  // Auth Flow
  static const String authScreen = '/auth'; // Login & Signup
  static const String verifyPicCodeScreen = "/verify_otp"; // 2FA Screen

  // Recovery Flow (Sequential)
  static const String recoverySetupScreen =
      '/recovery_setup_1'; // Recovery Screen 1
  static const String finalRecoveryScreen = '/final_recovery'; // Success Screen

  // App Core
  static const String homeScreen = '/home';
  static const String subscriptionScreen = '/subscription';

  // Settings & Others
  static const String settingScreen = "/SettingScreen";

  // ==================== Pages List ====================
  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: onboardingScreen, page: () => const OnboardingScreen()),
    GetPage(name: authScreen, page: () => const AuthScreen()),

    // Create Account এর পর এখানে আসবে
    GetPage(
      name: verifyPicCodeScreen,
      page: () => TwoFactorAuthScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),

    // OTP Verify হওয়ার পর এখানে আসবে (Recovery Step 1)
    GetPage(
      name: recoverySetupScreen,
      page: () => RecoveryKeySetupScreenOne(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),

    // Recovery সব স্টেপ শেষ হলে এখানে আসবে
    GetPage(name: finalRecoveryScreen, page: () => const FinalRecoveryScreen()),

    GetPage(name: homeScreen, page: () => const HomeScreen()),
    GetPage(
      name: subscriptionScreen,
      page: () => const SubscriptionScreenOne(),
    ),
  ];
}
