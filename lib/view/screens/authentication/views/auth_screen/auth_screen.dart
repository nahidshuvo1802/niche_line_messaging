import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:niche_line_messaging/helper/shared_prefe/shared_prefe.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_from_card/custom_from_card.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/screens/authentication/controller/auth_controller.dart';
import 'package:niche_line_messaging/view/screens/authentication/views/verify_pincode_screen/verify_pincode_screen.dart';
import 'package:niche_line_messaging/view/screens/home/views/home_screen.dart';

import '../../../../../core/app_routes/app_routes.dart';

// ==================== Auth Screen - Login & SignUp Combined ====================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final authController = Get.put(AuthController());
  final RxBool isLoginTab = true.obs;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    // Check for biometric login on screen load
    _checkBiometricLogin();
  }

  Future<void> _checkBiometricLogin() async {
    // Check if biometric is enabled in settings
    bool isBiometricEnabled = await SharePrefsHelper.getBool('isBiometricEnabled') ?? false;

    if (isBiometricEnabled) {
      try {
        final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
        final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

        if (canAuthenticate) {
          final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'Scan your fingerprint/face to enable secure login',
            // Remove 'options: const AuthenticationOptions('
            // Pass these directly:
            //stickyAuth: true,
            biometricOnly: true,
          );

          if (didAuthenticate) {
            Get.snackbar(
                "Success",
                "Biometric Login Successful",
                backgroundColor: Colors.green,
                colorText: Colors.white
            );
            // Navigate to Home
            Get.offAll(() => const HomeScreen());
          }
        }
      } catch (e) {
        debugPrint("Biometric Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10.h),

              // ==================== Logo ====================
              CustomImage(
                imageSrc: AppImages.splashScreenImage,
                height: 50.h,
                width: 50.h,
              ),

              SizedBox(height: 40.h),

              // ==================== Tab Buttons ====================
              Obx(() => Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    // Sign In Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () => isLoginTab.value = true,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isLoginTab.value
                                ? const Color(0xFF2DD4BF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isLoginTab.value
                                    ? AppColors.primary
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Create Account Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () => isLoginTab.value = false,
                        child: Container(
                          decoration: BoxDecoration(
                            color: !isLoginTab.value
                                ? const Color(0xFF2DD4BF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: !isLoginTab.value
                                    ? AppColors.primary
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),

              SizedBox(height: 30.h),

              // ==================== Dynamic Form Container ====================
              Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: isLoginTab.value
                    ? _buildLoginForm(authController)
                    : _buildSignUpForm(authController),
              )),

              SizedBox(height: 30.h),

              // ==================== Action Button ====================
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLoginTab.value) {
                      // Login button press
                      // authController.loginUser();
                      Get.offAll(() => const HomeScreen());
                    } else {
                      // Create Account button press
                      // Skip 2FA/OTP screen logic as requested
                       //authController.createAccount();
                      //Get.offAll(() => const HomeScreen());
                      Get.to(() => TwoFactorAuthScreen());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: authController.isLoginLoading.value ||
                      authController.isSignupLoading.value
                      ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    isLoginTab.value ? 'Continue' : 'Create Account',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )),

              // ==================== Biometric Login Button (Manual Trigger) ====================
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _checkBiometricLogin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint, color: const Color(0xFF2DD4BF), size: 24.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "Login with Biometrics",
                      style: TextStyle(
                          color: const Color(0xFF2DD4BF),
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // ==================== Forgot Password ====================
              TextButton(
                onPressed: () {
                  //Get.toNamed(AppRoutes.forgotPassword);
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF2DD4BF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // ==================== Terms & Privacy ====================
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                  children: [
                    const TextSpan(
                      text: 'By continuing, you agree to NichLine\'s ',
                    ),
                    TextSpan(
                      text: 'Terms',
                      style: TextStyle(
                        color: const Color(0xFF2DD4BF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: const Color(0xFF2DD4BF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Login Form UI ====================
  Widget _buildLoginForm(AuthController controller) {
    return Container(
      key: const ValueKey('login'),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email/Phone Field
          CustomFormCard(
            title: 'Email or Phone',
            hintText: 'Enter email or phone number',
            controller: controller.loginEmailController,
            titleColor: Colors.black87,
            fontSize: 14.sp,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Colors.grey,
              size: 20.sp,
            ),
            keyboardType: TextInputType.emailAddress,
          ),

          // Password Field
          CustomFormCard(
            title: 'Password',
            hintText: 'Enter password',
            controller: controller.loginPasswordController,
            isPassword: true,
            titleColor: Colors.black87,
            fontSize: 14.sp,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Colors.grey,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Sign Up Form UI ====================
  Widget _buildSignUpForm(AuthController controller) {
    return Container(
      key: const ValueKey('signup'),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          CustomFormCard(
            title: 'Full Name',
            hintText: 'Enter your name',
            controller: controller.nameController,
            titleColor: Colors.black87,
            fontSize: 14.sp,
            prefixIcon: Icon(
              Icons.person_outline,
              color: Colors.grey,
              size: 20.sp,
            ),
            keyboardType: TextInputType.name,
          ),

          // Email Field
          CustomFormCard(
            title: 'Email',
            hintText: 'Enter your email',
            controller: controller.emailController,
            titleColor: Colors.black87,
            fontSize: 14.sp,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Colors.grey,
              size: 20.sp,
            ),
            keyboardType: TextInputType.emailAddress,
          ),

          // Location Field
          CustomFormCard(
            title: 'Location',
            hintText: 'Enter your location',
            controller: controller.locationController,
            titleColor: Colors.black87,
            fontSize: 14.sp,
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: Colors.grey,
              size: 20.sp,
            ),
            keyboardType: TextInputType.text,
          ),

          // Password Field
          CustomFormCard(
            title: 'Password',
            hintText: 'Choose a strong password',
            controller: controller.passwordController,
            isPassword: true,
            titleColor: Colors.black87,
            fontSize: 14.sp,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Colors.grey,
              size: 20.sp,
            ),
          ),

          // Confirm Password Field
          CustomFormCard(
            title: 'Confirm Password',
            hintText: 'Re-enter your password',
            controller: controller.confirmPasswordController,
            isPassword: true,
            titleColor: Colors.black87,
            fontSize: 14.sp,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Colors.grey,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}