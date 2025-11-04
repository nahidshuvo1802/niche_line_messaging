
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/screens/splash_screen/splash_screen.dart';




class AppRoutes {
  ///===========================Splash Screen==========================
  static const String splashScreen = "/SplashScreen";
  static const String splashScreenTwo = "/SplashScreenTwo";
  static const String loginScreen = "/LoginScreen";
  static const String createAccountScreen = "/CreateAccountScreen";
  static const String verifyPicCodeScreen = "/VerifyPicCodeScreen";
  static const String verifypiccodescreenForget = '/VerifyPicCodeScreenForget';
  static const String forgotPasswordScreen = "/ForgotPasswordScreen";
  static const String resetPasswordScreen = "/ResetPasswordScreen";
  static const String navbar = "/Navbar";
  static const String homeScreen = "/HomeScreen";
  static const String qrCodeScreen = "/QrCodeScreen";
  static const String socialScreen = "/SocialScreen";
  static const String socialProfileView = "/SocialProfileView";
  static const String uploadScreen = "/UploadScreen";
  static const String profileScreen = "/ProfileScreen";
  static const String settingScreen = "/SettingScreen";
  static const String editProfileSetting = "/EditProfileSetting";
  static const String changePasswordScreen = "/ChangePasswordScreen";
  static const String aboutUsScreen = "/AboutUsScreen";
  static const String privacyPolicyScreen = "/PrivacyPolicyScreen";
  static const String termsConditionScreen = "/TermsConditionScreen";


  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
///===============================Auth Routes===========================
  //  GetPage(name: verifypiccodescreenForget, page: () => VerifyPicCodeScreenForget()),


  //   ///===========================Splash Screen==========================
  //   GetPage(name: splashScreen, page: () => SplashScreen()),
  //   GetPage(name: splashScreenTwo, page: () => SplashScreenTwo()),
    // GetPage(name: loginScreen, page: () => LoginScreen()),
  //   GetPage(name: createAccountScreen, page: () => CreateAccountScreen()),
  //   GetPage(name: verifyPicCodeScreen, page: () => VerifyPicCodeScreen()),
  //   GetPage(name: forgotPasswordScreen, page: () => ForgotPasswordScreen()),
  //   GetPage(name: resetPasswordScreen, page: () => ResetPasswordScreen(userId: Get.arguments)),
  //   GetPage(name: navbar, page: () => Navbar()),
  //   GetPage(name: homeScreen, page: () => HomeScreen()),
  //   GetPage(name: qrCodeScreen, page: () => QrScannerScreen()),
  //   GetPage(name: socialScreen, page: () => SocialScreen()),
  //   GetPage(name: uploadScreen, page: () => UploadScreen()),
  //   GetPage(name: profileScreen, page: () => ProfileScreen()),
  //   GetPage(name: settingScreen, page: () => SettingScreen()),
  //   GetPage(name: editProfileSetting, page: () => EditProfileSetting()),
  //   GetPage(name: changePasswordScreen, page: () => ChangePasswordScreen()),
  //   GetPage(name: aboutUsScreen, page: () => AboutUsScreen()),
  //   GetPage(name: privacyPolicyScreen, page: () => PrivacyPolicyScreen()),
  //   GetPage(name: termsConditionScreen, page: () => TermsConditionScreen()),

  ];
}
