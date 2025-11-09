import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/screens/secure_media_library/views/secure_media_screen.dart';

class SecureFolderScreen extends StatefulWidget {
  const SecureFolderScreen({super.key});

  @override
  State<SecureFolderScreen> createState() => _SecureFolderScreenState();
}

class _SecureFolderScreenState extends State<SecureFolderScreen> {
  final RxBool isAuthenticated = false.obs;
  final List<String> pin = ['', '', '', ''];
  int currentIndex = 0;

  void _onPinEntered(String value) {
    if (currentIndex < 4) {
      setState(() {
        pin[currentIndex] = value;
        currentIndex++;
      });

      if (currentIndex == 4) {
        // Verify PIN (demo: 1234)
        final enteredPin = pin.join();
        if (enteredPin == '1234') {
          Get.snackbar(
            'Success',
            'Folder unlocked successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          // Navigate to secure folder content
        } else {
          Get.snackbar(
            'Error',
            'Incorrect PIN. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          _resetPin();
        }
      }
    }
  }

  void _resetPin() {
    setState(() {
      pin.fillRange(0, 4, '');
      currentIndex = 0;
    });
  }

  void _authenticateWithBiometrics() {
    // Simulate biometric authentication
    Get.snackbar(
      'Biometric Authentication',
      'Please verify your identity',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2DD4BF),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    
    // Simulate successful authentication after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      Get.snackbar(
        'Success',
        'Folder unlocked successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1527),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2DD4BF)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Secure Folder',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF000000),
              Color(0xFF1A1F3A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),

              // Lock Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2DD4BF).withOpacity(0.15),
                ),
                child: Icon(
                  Icons.lock,
                  size: 40.sp,
                  color: const Color(0xFF2DD4BF),
                ),
              ),

              SizedBox(height: 24.h),

              // Title
              Text(
                'Secure Folder',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 12.h),

              // Subtitle
              Text(
                'Access your encrypted media. Only you can unlock it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.5,
                ),
              ),

              SizedBox(height: 40.h),

              // Biometric Authentication Button
              GestureDetector(
                onTap: _authenticateWithBiometrics,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3B5A),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF2DD4BF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fingerprint,
                        color: const Color(0xFF2DD4BF),
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Use Face ID / Fingerprint',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white.withOpacity(0.2),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white.withOpacity(0.2),
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // PIN Input Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pin[index].isNotEmpty
                          ? const Color(0xFF2DD4BF)
                          : Colors.transparent,
                      border: Border.all(
                        color: pin[index].isNotEmpty
                            ? const Color(0xFF2DD4BF)
                            : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 16.h),

              // Hint Text
              Text(
                'Next time, unlock instantly with your fingerprint or face.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.5),
                  height: 1.5,
                ),
              ),

              SizedBox(height: 32.h),

              // Unlock Folder Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: currentIndex == 4
                      ? () {
                          // Verify PIN
                          final enteredPin = pin.join();
                          if (enteredPin == '1234') {
                            Get.to(() => SecureMediaScreen());
                            Get.snackbar(
                              'Success',
                              'Folder unlocked successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              'Error',
                              'Incorrect PIN',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            _resetPin();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A6B8C),
                    disabledBackgroundColor: const Color(0xFF3A4A6C),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Unlock Folder',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Number Pad
              _buildNumberPad(),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          SizedBox(height: 16.h),
          // Row 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          SizedBox(height: 16.h),
          // Row 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          SizedBox(height: 16.h),
          // Row 4: blank, 0, backspace
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 70.w, height: 70.w), // Empty space
              _buildNumberButton('0'),
              _buildBackspaceButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onPinEntered(number),
      child: Container(
        width: 70.w,
        height: 70.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2A3B5A).withOpacity(0.5),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: () {
        if (currentIndex > 0) {
          setState(() {
            currentIndex--;
            pin[currentIndex] = '';
          });
        }
      },
      child: Container(
        width: 70.w,
        height: 70.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2A3B5A).withOpacity(0.5),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}