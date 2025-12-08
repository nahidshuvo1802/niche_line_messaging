// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../utils/app_colors/app_colors.dart';

class CustomPinCode extends StatelessWidget {
  const CustomPinCode({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      
      child: PinCodeTextField(
        keyboardType: TextInputType.number,
        appContext: context,
        length: 4,
        enableActiveFill: true,
        animationType: AnimationType.fade,
        animationDuration: Duration(milliseconds: 300),
        controller: controller,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(15),
          fieldHeight: 60,
          fieldWidth: size.width * 0.15,
          inactiveColor: AppColors.black_80,
          activeColor: AppColors.black_02, // active color
          activeFillColor: AppColors.black_02,
          inactiveFillColor: AppColors.white,
          selectedFillColor: AppColors.white, // selected color
          disabledColor: AppColors.white,
          selectedColor: AppColors.white,
        ),
      ),
    );
  }
}
