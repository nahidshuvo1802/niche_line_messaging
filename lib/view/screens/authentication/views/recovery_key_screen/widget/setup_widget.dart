
// ==================== Step Indicator Widget ====================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';

Widget buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF2DD4BF)
                : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2DD4BF), width: 2),
          ),
          child: Center(
            child: isActive
                ? Icon(Icons.check, color: AppColors.primary, size: 20.sp)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8.h),
        CustomText(
          text: label,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isActive
              ? const Color(0xFF2DD4BF)
              : Colors.white.withOpacity(0.5),
        ),
      ],
    );
  }