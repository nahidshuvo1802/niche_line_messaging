  // ==================== Step Line Widget ====================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildStepLine(bool isActive) {
    return Container(
      width: 30.w,
      height: 2.h,
      margin: EdgeInsets.only(bottom: 30.h),
      color: isActive ? const Color(0xFF2DD4BF) : Colors.white.withOpacity(0.2),
    );
  }