import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:niche_line_messaging/view/screens/settings/controller/theme_controller.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    this.maxLines,
    this.textAlign = TextAlign.center,
    this.left = 0,
    this.right = 0,
    this.top = 0,
    this.bottom = 0,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.color,
    required this.text,
    this.overflow = TextOverflow.ellipsis,
    this.decoration,
  });

  final double left;
  final double right;
  final double top;
  final double bottom;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final String text;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Padding(
      padding:
          EdgeInsets.only(left: left, right: right, top: top, bottom: bottom),
      child: Obx(() => Text(
        textAlign: textAlign,
        text,
        maxLines: maxLines,
        overflow: overflow,
        style: GoogleFonts.poppins(
          fontSize: (fontSize * (themeController.fontSize.value / 16.0)).sp,
          fontWeight: fontWeight,
          color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          decoration: decoration,
          decorationColor: Theme.of(context).colorScheme.onSurface,
          decorationThickness: 2,
        ),
      )),
    );
  }
}
