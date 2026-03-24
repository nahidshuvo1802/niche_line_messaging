import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer base color for dark theme
const Color _shimmerBaseColor = Color(0xFF2C3545);

/// Shimmer highlight color for dark theme
const Color _shimmerHighlightColor = Color(0xFF3F4A5E);

/// Reusable shimmer wrapper widget
class ShimmerWrapper extends StatelessWidget {
  final Widget child;

  const ShimmerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBaseColor,
      highlightColor: _shimmerHighlightColor,
      child: child,
    );
  }
}

/// Shimmer loading for HomeScreen chat list
class ChatListShimmer extends StatelessWidget {
  final int itemCount;

  const ChatListShimmer({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 80.h),
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildChatItemShimmer(),
    );
  }

  Widget _buildChatItemShimmer() {
    return ShimmerWrapper(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            // Avatar shimmer
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 16.w),
            // Content shimmer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16.h,
                    width: 120.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 12.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading for Chat Detail Screen (Messages)
class ChatDetailShimmer extends StatelessWidget {
  const ChatDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      itemCount: 10,
      itemBuilder: (context, index) {
        bool isMe = index % 2 == 0;
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: ShimmerWrapper(
              child: Container(
                width: 200.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: isMe
                        ? Radius.circular(16.r)
                        : Radius.circular(4.r),
                    bottomRight: isMe
                        ? Radius.circular(4.r)
                        : Radius.circular(16.r),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer loading for profile/account screen
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          // Profile card shimmer
          ShimmerWrapper(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 14, 21, 39),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  // Avatar shimmer
                  Container(
                    width: 100.r,
                    height: 100.r,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Name shimmer
                  Container(
                    height: 20.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Email shimmer
                  Container(
                    height: 14.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Location shimmer
                  Container(
                    height: 12.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Device info shimmer
          ShimmerWrapper(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 14, 21, 39),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        height: 16.h,
                        width: 140.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(height: 1.h, color: Colors.white.withOpacity(0.1)),
                  SizedBox(height: 16.h),
                  _buildInfoRowShimmer(),
                  SizedBox(height: 12.h),
                  _buildInfoRowShimmer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowShimmer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 14.h,
          width: 80.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        Container(
          height: 14.h,
          width: 120.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }
}

/// Generic shimmer box
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

/// Shimmer circle for avatars
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
