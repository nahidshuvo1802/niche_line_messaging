import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors/app_colors.dart';
import '../custom_button/custom_button.dart';
import '../custom_text/custom_text.dart';

class CustomPopUp {
  static void showPopUp({
    required BuildContext context,
    required String title,
    required String discription,
    required String dateTime,
    required String leftTextButton,
    required String rightTextButton,
    required Function() leftOnTap,
    required Function() rightOnTap,
    bool showRowButton = true,
    bool showColumnButton = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navbarClr,
        insetPadding: EdgeInsets.all(8),
        contentPadding: EdgeInsets.all(8),
        content: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomShowDialog(
            textColor: AppColors.white,
            title: title,
            discription: discription,
            dateTime: dateTime,
            showRowButton: showRowButton,
            showColumnButton: showColumnButton,
            showCloseButton: true,
            leftOnTap: leftOnTap,
            rightOnTap: rightOnTap,
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: sort_child_properties_last

class CustomShowDialog extends StatelessWidget {
  final String? title;
  final String? discription;
  final String? dateTime;
  final String? leftTextButton;
  final String? rightTextButton;
  final Function()? leftOnTap;
  final Function()? rightOnTap;
  final bool? showRowButton;
  final bool? showColumnButton;
  final bool? showCloseButton;
  final Color? textColor;
  const CustomShowDialog(
      {super.key,
        required this.title,
        required this.discription,
        this.leftOnTap,
        this.rightOnTap,
        this.leftTextButton,
        this.rightTextButton,
        this.showRowButton = false,
        this.showColumnButton = false,
        this.textColor = Colors.black,
        this.showCloseButton = true, this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //color: AppColors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          showCloseButton == true
              ? Padding(
            padding: EdgeInsets.only(right: 10.0, top: 0.h),
            child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: textColor ?? AppColors.black,
                    ))),
          )
              : SizedBox(),
          CustomText(
            top: 10.h,
            text: "$title",
            fontSize: 20.h,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.black_80,
            maxLines: 2,
            bottom: 12.h,
          ),
          CustomText(
            text: "$discription",
            fontSize: 16.h,
            fontWeight: FontWeight.w400,
            color: textColor ?? AppColors.black_80,
            bottom: 18.h,
            maxLines: 10,
          ),
          // CustomText(
          //   text: "$dateTime",
          //   fontSize: 16.h,
          //   fontWeight: FontWeight.w400,
          //   color: textColor ?? AppColors.black_80,
          //   bottom: 18.h,
          //   maxLines: 10,
          // ),
          SizedBox(height: 20.h,),
          showRowButton == true
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Flexible(
                  child: CustomButton(
                    onTap: leftOnTap ?? () => Navigator.of(context).pop(),
                    title: leftTextButton ?? "Yes",
                    height: 50.h,
                    textColor: textColor ?? AppColors.black_80,
                    // fillColor:  widget.textColor ?? AppColors.black_80,
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),
                Flexible(
                  child: CustomButton(
                    onTap:
                    rightOnTap ?? () => Navigator.of(context).pop(),
                    title: rightTextButton ?? "No",
                    height: 50.h,
                    fillColor: AppColors.white,
                    textColor: AppColors.primary,
                    isBorder: true,
                    borderWidth: 1,
                  ),
                )
              ],
            ),
          )
              : SizedBox(),
          showColumnButton == true
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                CustomButton(
                  onTap: leftOnTap ?? () => Navigator.of(context).pop(),
                  title: leftTextButton ?? "Yes",
                  height: 45.h,
                ),
                SizedBox(
                  height: 12.h,
                ),
                CustomButton(
                  onTap: rightOnTap ?? () => Navigator.of(context).pop(),
                  title: rightTextButton ?? "No",
                  height: 45.h,
                  fillColor: AppColors.white,
                  textColor: AppColors.primary,
                  isBorder: true,
                  borderWidth: 1,
                )
              ],
            ),
          )
              : SizedBox(),
        ],
      ),
      padding: EdgeInsets.only(bottom: 10.0, top: 10.h),
    );
  }
}
