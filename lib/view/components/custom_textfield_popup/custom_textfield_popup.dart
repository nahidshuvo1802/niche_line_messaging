import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_strings/app_strings.dart';
import '../custom_text/custom_text.dart';
import '../custom_text_field/custom_text_field.dart';

class CustomTextfieldWithPopup extends StatefulWidget {
  const CustomTextfieldWithPopup({
    super.key,
    required this.items,
    this.onChanged,
    this.icons,
    this.fillColor,
    this.popupColor,
    this.hintText,
    this.controller, this.validator,
  });

  final List<String> items;
  final ValueChanged<String>? onChanged;
  final IconData? icons;
  final Color? fillColor;
  final Color? popupColor;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;


  @override
  CustomTextfieldWithPopupState createState() =>
      CustomTextfieldWithPopupState();
}

class CustomTextfieldWithPopupState extends State<CustomTextfieldWithPopup> {
  final GlobalKey<PopupMenuButtonState<String>> _popupMenuKey = GlobalKey();

  void _showPopupMenu() {
    final dynamic state = _popupMenuKey.currentState;
    state?.showButtonMenu(); // Open the popup menu
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPopupMenu,
      child: AbsorbPointer(
        child: CustomTextField(
          inputTextStyle: TextStyle(color: AppColors.white),
          onChanged: widget.onChanged,
          fieldBorderRadius: 12,
          validator: widget.validator,
          fillColor: widget.fillColor ?? AppColors.white_50,
          hintText: widget.hintText ?? AppStrings.selectSpecialization,
          hintStyle: TextStyle(color: AppColors.white,),
          textEditingController: widget.controller,
          fieldBorderColor: AppColors.white_50.withValues(alpha: .2),
          readOnly: true,
          suffixIcon: PopupMenuButton<String>(
            borderRadius: BorderRadius.circular(12),
            key: _popupMenuKey,
            color: widget.popupColor ?? AppColors.red,
            icon: Icon(
              widget.icons ?? Icons.arrow_drop_down,
              color: AppColors.white,
            ),
            onSelected: (String value) {
              setState(() {
                widget.controller?.text = value;  
                widget.onChanged?.call(value);
              });
            },
            itemBuilder: (context) => widget.items.map((String item) {
              return PopupMenuItem<String>(
                value: item,
                child: CustomText(
                  textAlign: TextAlign.center,
                  text: item,
                  color: AppColors.white,
                  fontSize: 16.w,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
