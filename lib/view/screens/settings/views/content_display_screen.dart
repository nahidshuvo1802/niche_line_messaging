import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:niche_line_messaging/view/screens/settings/controller/settings_content_controller.dart';
import 'package:niche_line_messaging/core/app_navigation.dart';

class ContentDisplayScreen extends StatefulWidget {
  final String title;
  final ContentType contentType;

  const ContentDisplayScreen({
    super.key,
    required this.title,
    required this.contentType,
  });

  @override
  State<ContentDisplayScreen> createState() => _ContentDisplayScreenState();
}

class _ContentDisplayScreenState extends State<ContentDisplayScreen> {
  final SettingsContentController controller = Get.put(
    SettingsContentController(),
  );

  @override
  void initState() {
    super.initState();
    controller.fetchContent(widget.contentType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1527),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF0E1527),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2DD4BF)),
          onPressed: () => AppNav.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Html(
            data: controller.content.value,
            style: {
              "body": Style(
                color: Colors.white,
                fontSize: FontSize(14.sp),
                fontFamily: 'Roboto', // Or app's default font
              ),
              "p": Style(color: Colors.white70, lineHeight: LineHeight.em(1.5)),
              "h1": Style(color: const Color(0xFF2DD4BF)),
              "h2": Style(color: const Color(0xFF2DD4BF)),
              "h3": Style(color: const Color(0xFF2DD4BF)),
              "a": Style(
                color: const Color(0xFF2DD4BF),
                textDecoration: TextDecoration.none,
              ),
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 20.h),
            ...List.generate(
              15,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Container(
                  width: double.infinity,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
