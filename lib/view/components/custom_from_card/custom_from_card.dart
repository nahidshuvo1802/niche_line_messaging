import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_colors/app_colors.dart';
import '../custom_text/custom_text.dart';
import '../custom_text_field/custom_text_field.dart';

class CustomFormCard extends StatelessWidget {
  final String title;
  final String? hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool? hasSuffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool hasBackgroundColor;
  final bool isMultiLine;
  final String? Function(dynamic)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLine;
  final double? fontSize;
  final Color? titleColor;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;

  const CustomFormCard({
    super.key,
    required this.title,
    required this.controller,
    this.isPassword = false,
    this.hasSuffixIcon,
    this.readOnly = false,
    this.onTap,
    this.hasBackgroundColor = false,
    this.isMultiLine = false,
    this.validator,
    this.hintText,
    this.suffixIcon,
    this.maxLine,
    this.fontSize,
    this.titleColor,
    this.prefixIcon, this.keyboardType, this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: title,
          color: titleColor ?? AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? 18.w,
          bottom: 12.h,
          maxLines: 2,
        ),
        CustomTextField(
          isDens: true,
          onChanged: onChanged,
          prefixIcon: prefixIcon,
          validator: validator,
          readOnly: readOnly,
          hintText: hintText,
          cursorColor: const Color.fromARGB(255, 0, 0, 0),
          hintStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: const Color.fromARGB(71, 0, 0, 0)),
          suffixIcon: suffixIcon,
          isPassword: isPassword,
          textEditingController: controller,
          inputTextStyle: GoogleFonts.inter(color: AppColors.black, fontSize: 18.sp),
          fillColor: hasBackgroundColor ? AppColors.black : Colors.transparent,
          fieldBorderColor: AppColors.loading.withValues(alpha: .7),
          keyboardType: keyboardType ?? (isPassword ? TextInputType.visiblePassword : TextInputType.text),
          onTap: onTap,
          maxLines: isPassword ? 1 : maxLine,
          fieldBorderRadius: 10,
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}
