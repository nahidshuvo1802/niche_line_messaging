// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:get/get.dart';

// // // ==================== Two-Factor Authentication Screen ====================
// // // OTP verification screen for 2FA
// // class TwoFactorAuthScreen extends StatelessWidget {
// //   TwoFactorAuthScreen({super.key});

// //   // ==================== Controllers & State ====================
// //   // 4 separate controllers for 4 OTP boxes
// //   final TextEditingController otp1Controller = TextEditingController();
// //   final TextEditingController otp2Controller = TextEditingController();
// //   final TextEditingController otp3Controller = TextEditingController();
// //   final TextEditingController otp4Controller = TextEditingController();

// //   // Focus nodes for auto-focus on next field
// //   final FocusNode focus1 = FocusNode();
// //   final FocusNode focus2 = FocusNode();
// //   final FocusNode focus3 = FocusNode();
// //   final FocusNode focus4 = FocusNode();

// //   // Reactive variables
// //   final RxBool isVerifying = false.obs;
// //   final RxInt resendTimer = 24.obs; // Timer for resend code (00:24 format)

// //   @override
// //   Widget build(BuildContext context) {
// //     // Start countdown timer
// //     _startResendTimer();

// //     return Scaffold(
// //       backgroundColor: const Color(0xFF0E1527), // Dark navy background
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: EdgeInsets.symmetric(horizontal: 24.w),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.center,
// //             children: [
// //               SizedBox(height: 60.h),

// //               // ==================== Logo ====================
// //               Text(
// //                 'NichLine',
// //                 style: TextStyle(
// //                   fontSize: 32.sp,
// //                   fontWeight: FontWeight.bold,
// //                   color: const Color(0xFF2DD4BF), // Cyan color
// //                 ),
// //               ),

// //               SizedBox(height: 60.h),

// //               // ==================== Title ====================
// //               Text(
// //                 'Two-Factor Authentication',
// //                 style: TextStyle(
// //                   fontSize: 20.sp,
// //                   fontWeight: FontWeight.w600,
// //                   color: Colors.white,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),

// //               SizedBox(height: 12.h),

// //               // ==================== Subtitle ====================
// //               Text(
// //                 'Check your authenticator app or SMS.',
// //                 style: TextStyle(
// //                   fontSize: 14.sp,
// //                   color: Colors.white.withOpacity(0.7),
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),

// //               SizedBox(height: 40.h),

// //               // ==================== OTP Input Boxes ====================
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   _buildOTPBox(otp1Controller, focus1, focus2, true),
// //                   SizedBox(width: 16.w),
// //                   _buildOTPBox(otp2Controller, focus2, focus3, false),
// //                   SizedBox(width: 16.w),
// //                   _buildOTPBox(otp3Controller, focus3, focus4, false),
// //                   SizedBox(width: 16.w),
// //                   _buildOTPBox(otp4Controller, focus4, null, false),
// //                 ],
// //               ),

// //               SizedBox(height: 30.h),

// //               // ==================== Resend Code Timer ====================
// //               Obx(() => Text(
// //                     'Resend code in 00:${resendTimer.value.toString().padLeft(2, '0')}',
// //                     style: TextStyle(
// //                       fontSize: 14.sp,
// //                       color: Colors.white.withOpacity(0.5),
// //                     ),
// //                   )),

// //               SizedBox(height: 40.h),

// //               // ==================== Verify Button ====================
// //               Obx(() => SizedBox(
// //                     width: double.infinity,
// //                     height: 56.h,
// //                     child: ElevatedButton(
// //                       onPressed: isVerifying.value ? null : _handleVerify,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFF2DD4BF),
// //                         foregroundColor: const Color(0xFF0E1527),
// //                         elevation: 0,
// //                         disabledBackgroundColor:
// //                             const Color(0xFF2DD4BF).withOpacity(0.5),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12.r),
// //                         ),
// //                       ),
// //                       child: Text(
// //                         isVerifying.value ? 'Verifying...' : 'Verify',
// //                         style: TextStyle(
// //                           fontSize: 16.sp,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ),
// //                   )),

// //               SizedBox(height: 20.h),

// //               // ==================== Back to Login Link ====================
// //               TextButton(
// //                 onPressed: () {
// //                   // Navigate back to login
// //                   Get.back();
// //                   // Or: Get.offAllNamed(AppRoutes.loginScreen);
// //                 },
// //                 child: Text(
// //                   'Back to Login',
// //                   style: TextStyle(
// //                     fontSize: 14.sp,
// //                     color: const Color(0xFF2DD4BF),
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ),

// //               SizedBox(height: 40.h),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ==================== OTP Box Widget ====================
// //   // Individual box for single digit input
// //   Widget _buildOTPBox(
// //     TextEditingController controller,
// //     FocusNode currentFocus,
// //     FocusNode? nextFocus,
// //     bool isFirst,
// //   ) {
// //     return Container(
// //       width: 60.w,
// //       height: 70.h,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12.r),
// //       ),
// //       child: TextField(
// //         controller: controller,
// //         focusNode: currentFocus,
// //         textAlign: TextAlign.center,
// //         keyboardType: TextInputType.number,
// //         maxLength: 1,
// //         style: TextStyle(
// //           fontSize: 24.sp,
// //           fontWeight: FontWeight.bold,
// //           color: Colors.black,
// //         ),
// //         decoration: InputDecoration(
// //           counterText: '', // Hide character counter
// //           border: InputBorder.none,
// //           contentPadding: EdgeInsets.zero,
// //         ),
// //         // Auto-focus next field when digit entered
// //         onChanged: (value) {
// //           if (value.length == 1 && nextFocus != null) {
// //             FocusScope.of(Get.context!).requestFocus(nextFocus);
// //           }
// //           // Auto-focus previous field when deleted
// //           if (value.isEmpty && !isFirst) {
// //             FocusScope.of(Get.context!).previousFocus();
// //           }
// //         },
// //         // Auto-focus first field on screen load
// //         autofocus: isFirst,
// //       ),
// //     );
// //   }

// //   // ==================== Verify OTP Handler ====================
// //   void _handleVerify() {
// //     // Get complete OTP from all 4 boxes
// //     String otp = otp1Controller.text +
// //         otp2Controller.text +
// //         otp3Controller.text +
// //         otp4Controller.text;

// //     // Validation
// //     if (otp.length < 4) {
// //       Get.snackbar(
// //         'Error',
// //         'Please enter complete 4-digit code',
// //         snackPosition: SnackPosition.BOTTOM,
// //         backgroundColor: Colors.red,
// //         colorText: Colors.white,
// //       );
// //       return;
// //     }

// //     // Start verification
// //     isVerifying.value = true;

// //     // Simulate API call (replace with actual API)
// //     Future.delayed(const Duration(seconds: 2), () {
// //       isVerifying.value = false;

// //       // Success case
// //       print('OTP Verified: $otp');
// //       Get.snackbar(
// //         'Success',
// //         'Authentication successful!',
// //         snackPosition: SnackPosition.BOTTOM,
// //         backgroundColor: Colors.green,
// //         colorText: Colors.white,
// //       );

// //       // Navigate to home screen
// //       // Get.offAllNamed(AppRoutes.home);

// //       // Error case (uncomment for testing)
// //       // Get.snackbar(
// //       //   'Error',
// //       //   'Invalid code. Please try again.',
// //       //   snackPosition: SnackPosition.BOTTOM,
// //       //   backgroundColor: Colors.red,
// //       //   colorText: Colors.white,
// //       // );
// //     });
// //   }

// //   // ==================== Resend Timer ====================
// //   void _startResendTimer() {
// //     // Start from 24 seconds
// //     resendTimer.value = 24;

// //     // Countdown every second
// //     Future.doWhile(() async {
// //       await Future.delayed(const Duration(seconds: 1));
// //       if (resendTimer.value > 0) {
// //         resendTimer.value--;
// //         return true; // Continue loop
// //       }
// //       return false; // Stop loop
// //     });
// //   }

// //   // ==================== Resend OTP Handler ====================
// //   void _handleResendOTP() {
// //     if (resendTimer.value > 0) {
// //       Get.snackbar(
// //         'Info',
// //         'Please wait ${resendTimer.value} seconds before resending',
// //         snackPosition: SnackPosition.BOTTOM,
// //         backgroundColor: Colors.orange,
// //         colorText: Colors.white,
// //       );
// //       return;
// //     }

// //     // Resend OTP API call
// //     print('Resending OTP...');
// //     Get.snackbar(
// //       'Success',
// //       'OTP has been resent',
// //       snackPosition: SnackPosition.BOTTOM,
// //       backgroundColor: Colors.green,
// //       colorText: Colors.white,
// //     );

// //     // Restart timer
// //     _startResendTimer();
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
// import 'package:niche_line_messaging/view/components/custom_pin_code/custom_pin_code.dart';
// import 'package:niche_line_messaging/view/screens/authentication/controller/auth_controller.dart';

// import '../../../../core/app_routes/app_routes.dart';
// import '../../../../utils/app_images/app_images.dart';
// import '../../../../utils/app_strings/app_strings.dart';
// import '../../../components/custom_button/custom_button.dart';
// import '../../../components/custom_image/custom_image.dart';
// import '../../../components/custom_text/custom_text.dart';
//   final authController = Get.put(AuthController());
// class VerifyPicCodeScreen extends StatelessWidget {
//   const VerifyPicCodeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
  

//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       body: Stack(
//         children: [
//           /* CustomImage(
//             imageSrc: AppImages.backgroundImage,
//             boxFit: BoxFit.fill,
//             height: MediaQuery.sizeOf(context).height,
//             width: MediaQuery.sizeOf(context).width,
//             fit: BoxFit.cover,
//             imageColor: AppColors.primary,
//           ), */
//           Padding(
//             padding: const EdgeInsets.only(left: 20, right: 20, top: 200),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Center(
//                   child: Column(
//                     children: [
//                       CustomText(
//                         text: "Two Factor Authorization",
//                         fontSize: 20.w,
//                         fontWeight: FontWeight.w600,
//                         bottom: 20,
//                       ),
//                       CustomText(
//                         text: "Check your authenticator app or SMS.",
//                         fontSize: 14.w,
//                         fontWeight: FontWeight.w400,
//                         maxLines: 2,
//                         bottom: 30.h,
//                       ),
//                     ],
//                   ),
//                 ),
      
//                 CustomPinCode(controller: authController.otpController),
//                 SizedBox(height: 20.h),
      
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CustomText(
//                       text: AppStrings.iDidntFind,
//                       fontSize: 14.w,
//                       fontWeight: FontWeight.w400,
//                       right: 6.w,
//                     ),
      
//                     GestureDetector(
//                       onTap: ()=> authController.sendAgainOtp() ,
//                       child: CustomText(
//                         text: AppStrings.sendAgain,
//                         fontSize: 14.w,
//                         fontWeight: FontWeight.w400,
//                         color: Colors.blueAccent,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 80.h),
      
//                 Obx(() => CustomButton(
//                       title: authController.isOtpVerifying.value
//                           ? "Verifying..."
//                           : AppStrings.confirm,
//                       onTap: authController.isOtpVerifying.value
//                           ? () => Get.snackbar("Failed","OTP is missing")
//                           : () {
//                               authController.verifyOtp();
//                             },
//                     )),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/components/custom_pin_code/custom_pin_code.dart';
import 'package:niche_line_messaging/view/screens/authentication/controller/auth_controller.dart';
import '../../../../utils/app_strings/app_strings.dart';
import '../../../components/custom_button/custom_button.dart';
import '../../../components/custom_text/custom_text.dart';

// ==================== Two-Factor Authentication OTP Screen ====================
// 6-digit OTP verification for 2FA
class TwoFactorAuthScreen extends StatelessWidget {
  TwoFactorAuthScreen({super.key});

  // ==================== OTP Controllers ====================
  // 6টা আলাদা controller - প্রতিটা digit এর জন্য একটা
  final TextEditingController otpController = TextEditingController();
  // final TextEditingController otp2Controller = TextEditingController();
  // final TextEditingController otp3Controller = TextEditingController();
  // final TextEditingController otp4Controller = TextEditingController();
  // final TextEditingController otp5Controller = TextEditingController();
  // final TextEditingController otp6Controller = TextEditingController();

  // ==================== Focus Nodes ====================
  // final FocusNode focus1 = FocusNode();
  // final FocusNode focus2 = FocusNode();
  // final FocusNode focus3 = FocusNode();
  // final FocusNode focus4 = FocusNode();
  // final FocusNode focus5 = FocusNode();
  // final FocusNode focus6 = FocusNode();

  // ==================== Reactive States ====================
  final RxBool isVerifying = false.obs;
  final RxInt resendTimer = 24.obs; // Countdown timer

  @override
  Widget build(BuildContext context) {
    // Timer শুরু করা
    _startResendTimer();

    return Scaffold(
      backgroundColor: AppColors.primary, // Dark navy background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 2.h),

              // ==================== Logo ====================
               //SizedBox(height: 40.h),

              // ==================== Logo ====================
              CustomImage(
                imageSrc: AppImages.splashScreenImage,
                height: 50.h,
                width: 50.h,
              ),

              SizedBox(height: 80.h),

              // ==================== Title ====================
              CustomText(
                text: 'Two-Factor Authentication',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),

              SizedBox(height: 12.h),

              // ==================== Subtitle ====================
              CustomText(
                text: 'Check your authenticator app or SMS.',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.7),
              ),

              SizedBox(height: 40.h),

              // ==================== 6 OTP Input Boxes ====================
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     _buildOTPBox(otp1Controller, focus1, focus2, true),
              //     SizedBox(width: 12.w),
              //     _buildOTPBox(otp2Controller, focus2, focus3, false),
              //     SizedBox(width: 12.w),
              //     _buildOTPBox(otp3Controller, focus3, focus4, false),
              //     SizedBox(width: 12.w),
              //     _buildOTPBox(otp4Controller, focus4, focus5, false),
              //     SizedBox(width: 12.w),
              //     _buildOTPBox(otp5Controller, focus5, focus6, false),
              //     SizedBox(width: 12.w),
              //     _buildOTPBox(otp6Controller, focus6, null, false),
              //   ],
              // ),
              CustomPinCode(controller: otpController),
              SizedBox(height: 30.h),

              // ==================== Resend Code Timer ====================
              Obx(() => CustomText(
                    text:
                        'Resend code in 00:${resendTimer.value.toString().padLeft(2, '0')}',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.5),
                  )),

              SizedBox(height: 40.h),

              // ==================== Verify Button ====================
              Obx(() => CustomButton(
                height: 50.h,
                fontSize: 15.h,
                width: 600.w,
                fillColor: AppColors.loading,
                    title: isVerifying.value ? 'Verifying...' : 'Verify',
                    onTap:(){} //isVerifying.value ? null : _handleVerifyOtp,
                  )),

              SizedBox(height: 20.h),

              // ==================== Resend OTP Row ====================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: AppStrings.iDidntFind,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7),
                    right: 6.w,
                  ),
                  Obx(() => GestureDetector(
                        onTap: resendTimer.value == 0
                            ? _handleResendOTP
                            : () {
                                Get.snackbar(
                                  'Info',
                                  'Please wait ${resendTimer.value} seconds',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                              },
                        child: CustomText(
                          text: AppStrings.sendAgain,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: resendTimer.value == 0
                              ? const Color(0xFF2DD4BF)
                              : Colors.grey,
                        ),
                      )),
                ],
              ),

              SizedBox(height: 20.h),

              // ==================== Back to Login Link ====================
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: CustomText(
                  text: 'Back to Login',
                  fontSize: 14.sp,
                  color: const Color(0xFF2DD4BF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== OTP Box Widget ====================
  // Single digit input box
  Widget _buildOTPBox(
    TextEditingController controller,
    FocusNode currentFocus,
    FocusNode? nextFocus,
    bool isFirst,
  ) {
    return Container(
      width: 50.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF2DD4BF).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          counterText: '', // Hide character counter
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          // Auto-focus next field when digit entered
          if (value.length == 1 && nextFocus != null) {
            FocusScope.of(Get.context!).requestFocus(nextFocus);
          }
          // Auto-focus previous field when deleted
          if (value.isEmpty && !isFirst) {
            FocusScope.of(Get.context!).previousFocus();
          }
        },
        autofocus: isFirst,
      ),
    );
  }

  // ==================== Verify OTP Handler ====================
  void _handleVerifyOtp() async {
    // Get complete OTP from all 6 boxes
    String otp = otpController.value.text;

    // Validation check
    if (otp.length < 6) {
      Get.snackbar(
        'Error',
        'Please enter complete 6-digit code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Loading start
    isVerifying.value = true;

    try {
      // TODO: Replace with your actual 2FA verification API
      // Example:
      // final body = {"code": otp};
      // final response = await ApiClient.postData(ApiUrl.verify2FA, jsonEncode(body));

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Simulate success
      bool isSuccess = true;

      if (isSuccess) {
        isVerifying.value = false;

        Get.snackbar(
          'Success',
          'Authentication successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to home screen
        // Get.offAllNamed(AppRoutes.homeScreen);

        debugPrint('✅ 2FA Verified: $otp');
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      isVerifying.value = false;

      Get.snackbar(
        'Error',
        'Invalid code. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      debugPrint('❌ 2FA Verify Error: $e');
    }
  }

  // ==================== Resend Timer ====================
  void _startResendTimer() {
    resendTimer.value = 24;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer.value > 0) {
        resendTimer.value--;
        return true;
      }
      return false;
    });
  }

  // ==================== Resend OTP Handler ====================
  void _handleResendOTP() async {
    if (resendTimer.value > 0) {
      Get.snackbar(
        'Info',
        'Please wait ${resendTimer.value} seconds before resending',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // TODO: Replace with your actual resend 2FA OTP API
      // Example:
      // var response = await ApiClient.getData(ApiUrl.resend2FAOTP);

      await Future.delayed(const Duration(seconds: 1));

      bool isSuccess = true;

      if (isSuccess) {
        Get.snackbar(
          'Success',
          'OTP has been resent to your device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear all OTP fields
        otpController.clear();

        // Restart timer
        _startResendTimer();

        // Focus on first field
        //FocusScope.of(Get.context!).requestFocus(focus1);

        debugPrint('✅ 2FA OTP Resent');
      } else {
        throw Exception('Failed to resend');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      debugPrint('❌ Resend 2FA OTP Error: $e');
    }
  }
}