import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/screens/secure_media_library/views/secure_media_screen.dart';
import 'package:niche_line_messaging/view/screens/settings/controller/secure_folder_controller.dart';

class SecureFolderScreen extends StatefulWidget {
  const SecureFolderScreen({super.key});

  @override
  State<SecureFolderScreen> createState() => _SecureFolderScreenState();
}

class _SecureFolderScreenState extends State<SecureFolderScreen> {
  final SecureFolderController controller = Get.put(SecureFolderController());

  final List<String> pin = ['', '', '', ''];
  int currentIndex = 0;

  // New Account Creation State
  String? firstPin;
  bool isConfirming = false;

  void _onPinEntered(String value) {
    if (currentIndex < 4) {
      setState(() {
        pin[currentIndex] = value;
        currentIndex++;
      });

      if (currentIndex == 4) {
        final enteredPin = pin.join();

        // Logic Branch
        if (controller.hasCreatedAccount.value) {
          _handleLogin(enteredPin);
        } else {
          _handleCreation(enteredPin);
        }
      }
    }
  }

  void _handleLogin(String enteredPin) async {
    bool success = await controller.verifyOrCreatePin(enteredPin);
    if (success) {
      Get.off(() => SecureMediaScreen());
    } else {
      _resetPin();
    }
  }

  void _handleCreation(String enteredPin) async {
    if (!isConfirming) {
      // First Step: Capture PIN, ask for confirmation
      setState(() {
        firstPin = enteredPin;
        isConfirming = true;
        _resetPinUIOnly();
      });
    } else {
      // Second Step: Confirm PIN
      if (enteredPin == firstPin) {
        bool success = await controller.verifyOrCreatePin(enteredPin);
        if (success) {
          Get.off(() => SecureMediaScreen());
        } else {
          // Creation failed at API level
          setState(() {
            isConfirming = false;
            firstPin = null;
            _resetPinUIOnly();
          });
        }
      } else {
        Get.snackbar(
          'Error',
          'PINs do not match. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          isConfirming = false;
          firstPin = null;
          _resetPinUIOnly();
        });
      }
    }
  }

  void _resetPin() {
    setState(() {
      pin.fillRange(0, 4, '');
      currentIndex = 0;
    });
  }

  void _resetPinUIOnly() {
    pin.fillRange(0, 4, '');
    currentIndex = 0;
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF1A1F3A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
            );
          }

          String title = "Secure Folder";
          String subtitle = "Access your encrypted media.";

          if (!controller.hasCreatedAccount.value) {
            if (isConfirming) {
              title = "Confirm PIN";
              subtitle = "Please re-enter your PIN to confirm.";
            } else {
              title = "Create PIN";
              subtitle = "Set a 4-digit PIN for your secure folder.";
            }
          } else {
            title = "Enter PIN";
            subtitle = "Enter your PIN to access secure folder.";
          }

          return SingleChildScrollView(
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
                  title,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 12.h),

                // Subtitle
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 60.h), // More spacing
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

                SizedBox(height: 80.h),

                // Number Pad
                _buildNumberPad(),

                SizedBox(height: 40.h),
              ],
            ),
          );
        }),
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
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
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
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
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
