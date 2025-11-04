/*
// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'package:counta_flutter_app/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'custom_image_add_send_controller.dart';

class CustomImageAddSend extends StatefulWidget {
  final Color? fillColor;
  final Color? hintTextColor;
  final Color? textColor;
  final Color? imageIconColor;
  final Function()? imageOnTapButton;
  final Function()? sendOnTapButton;
  final TextEditingController? textEditingController;

  const CustomImageAddSend({
    super.key,
    this.fillColor,
    this.hintTextColor,
    this.textColor,
    this.sendOnTapButton,
    this.imageIconColor,
    this.textEditingController,
    this.imageOnTapButton,
  });

  @override
  State<CustomImageAddSend> createState() => _CustomImageAddSendState();
}

class _CustomImageAddSendState extends State<CustomImageAddSend> {
  final CustomImageAddSendController customImageAddSendController =
      Get.find<CustomImageAddSendController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () {
            return customImageAddSendController.images.isNotEmpty
                ? Row(
                    children: List.generate(
                      customImageAddSendController.images.length,
                      (index) {
                        final image =
                            customImageAddSendController.images[index];
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(image.path),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => customImageAddSendController
                                    .removeImage(index),
                                child: CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 8,
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : SizedBox();
          },
        ),

        //   },
        // ),
        //   ],
        // ),

        SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.textEditingController,
                //controller: customImageAddSendController.messageController,
                style: TextStyle(color: widget.textColor ?? Colors.white),
                decoration: InputDecoration(
                  focusColor: Colors.grey,

                   //focusedBorder: InputBorder.none,
                 // enabledBorder: InputBorder.none,
                  suffixIcon: GestureDetector(
                    onTap: widget.imageOnTapButton,
                    // onTap: customImageAddSendController.pickImage,
                    child: Icon(Icons.image,
                        color: widget.imageIconColor ?? Colors.white),
                  ),
                  hintText: 'Type a message',
                  hintStyle:
                      TextStyle(color: widget.hintTextColor ?? Colors.white),
                  filled: true,
                  fillColor: widget.fillColor ?? Colors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            SizedBox(
              width: 4.w,
            ),
            GestureDetector(
              onTap: widget.sendOnTapButton,
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(70),
                ),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
            */
/*   IconButton(
                  onPressed: customImageAddSendController.sendMessage,
                  icon: Icon(Icons.send, color: Colors.blue),
                ),*//*

          ],
        ),
      ],
    );
  }
}
*/
