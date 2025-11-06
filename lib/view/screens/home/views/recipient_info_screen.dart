import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/home/controller/recipient_controller.dart';

// ==================== Chat Info Screen ====================
class ChatInfoScreen extends StatelessWidget {
  const ChatInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatInfoController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        final chatInfo = controller.chatInfo.value;
        if (chatInfo == null) {
          return _buildErrorState();
        }

        return _buildContent(chatInfo, controller);
      }),
    );
  }

  // ==================== AppBar ====================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: const Color(0xFF2DD4BF),
          size: 20.sp,
        ),
      ),
      title: CustomText(
        text: 'Chat Info',
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      centerTitle: true,
    );
  }

  // ==================== Content ====================
  Widget _buildContent(dynamic chatInfo, ChatInfoController controller) {
    return Container(
      height: double.infinity,
      width: double.infinity,
     decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF000000),
            Color.fromARGB(255, 31, 41, 55),
          ],
          tileMode: TileMode.mirror,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
             SizedBox(height: 12.h),
            _buildProfileSection(chatInfo),
            SizedBox(height: 30.h),
            _buildSwitchOption(
              icon: Icons.notifications_off_outlined,
              title: 'Mute Notifications',
              subtitle: 'Stop alerts for this chat',
              value: chatInfo.isMuted ?? false,
              onChanged: controller.toggleMuteNotifications,
              isLoading: controller.isMuteToggling,
            ),
            //========================DIVIDER===============================
             Container(height: 0.3.h,width: 350.h,color: const Color.fromARGB(209, 255, 255, 255),),
            _buildNavigationOption(
              icon: Icons.image_outlined,
              title: 'View Media',
              onTap: controller.viewMedia,
            ),
            SizedBox(height: 20.h),
            _buildNavigationOption(
              icon: Icons.shield,
              title: 'Encryption Info',
              subtitle: 'Your messages are end-to-end encrypted',
              onTap: controller.viewEncryptionInfo,
              iconColor: const Color(0xFF2DD4BF),
              borderRadius:  BorderRadius.vertical(top: Radius.circular(12.r))
            ),
             //========================DIVIDER===============================
             Container(height: 0.3.h,width: 350.h,color: const Color.fromARGB(209, 255, 255, 255),),
            _buildNavigationOption(
              
              icon: Icons.cloud_upload_outlined,
              title: 'Export Chat (Encrypted)',
              subtitle: 'Save a secure backup of this conversation',
              onTap: controller.exportChat,
              borderRadius:  BorderRadius.vertical(bottom: Radius.circular(12.r))
            ),
            SizedBox(height: 20.h),
            _buildNavigationOption(
              icon: Icons.delete_outline,
              title: 'Delete Chat',
              subtitle: 'Remove all messages from this chat on your device',
              onTap: controller.deleteChat,
              iconColor: Colors.red,
              titleColor: Colors.red,
              borderRadius:  BorderRadius.vertical(top: Radius.circular(12.r))
            ),
             //========================DIVIDER===============================
             Container(height: 0.3.h,width: 350.h,color: const Color.fromARGB(209, 255, 255, 255),),
             
            _buildNavigationOption(
              icon: Icons.block_outlined,
              title: 'Block or Report User',
              subtitle: 'Prevent future messages and optionally report abuse',
              onTap: controller.blockOrReportUser,
              iconColor: Colors.red,
              titleColor: Colors.red,
               borderRadius:  BorderRadius.vertical(bottom: Radius.circular(12.r))
            ),
            SizedBox(height: 32.h),
            _buildFooterNote(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ==================== Loading State ====================
  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(color: const Color(0xFF2DD4BF)),
    );
  }

  // ==================== Error State ====================
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.sp,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: 'No chat info available',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: 'Failed to load chat information',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  // ==================== Profile Section ====================
  Widget _buildProfileSection(dynamic chatInfo) {
    return Container(
      width: 370.w,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      decoration: BoxDecoration(
        color:  const Color.fromARGB(255, 14, 21, 39),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.r),top:  Radius.circular(15.r)),
      ),
      child: Column(
        children: [
          _buildProfileAvatar(chatInfo),
          SizedBox(height: 16.h),
          CustomText(
            text: chatInfo.name,
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: CustomText(
              text: chatInfo.bio ?? 'No bio available',
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.6),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Profile Avatar ====================
  Widget _buildProfileAvatar(dynamic chatInfo) {
    final hasImage = chatInfo.profileImage != null && 
                      chatInfo.profileImage!.isNotEmpty;
    
    return Stack(
      children: [
        CircleAvatar(
          radius: 50.r,
          backgroundColor: Colors.grey[700],
          backgroundImage: hasImage ? NetworkImage(chatInfo.profileImage!) : null,
          child: !hasImage
              ? Text(
                  chatInfo.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(255, 14, 21, 39),
                width: 3,
              ),
            ),
            child: Icon(Icons.edit, size: 12.sp, color: const Color.fromARGB(255, 0, 0, 0)),
          ),
        ),
      ],
    );
  }

  // ==================== Switch Option ====================
  Widget _buildSwitchOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required RxBool isLoading,
  }) {
    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 14, 21, 39),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r) ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 2.h),
                  CustomText(
                    text: subtitle,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.5),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            if (isLoading.value)
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: const Color(0xFF2DD4BF),
                ),
              )
            else
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF2DD4BF),
                activeTrackColor: const Color(0xFF2DD4BF).withOpacity(0.3),
                inactiveThumbColor: Colors.grey[600],
                inactiveTrackColor: Colors.grey[800],
              ),
          ],
        ),
      ),
    );
  }

  // ==================== Navigation Option ====================
  Widget  _buildNavigationOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
    BorderRadius? borderRadius
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 14, 21, 39),
          borderRadius: borderRadius,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.white.withOpacity(0.7),
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? Colors.white,
                    textAlign: TextAlign.left,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    CustomText(
                      text: subtitle,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.5),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Footer Note ====================
  Widget _buildFooterNote() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: CustomText(
        text:
            'End-to-end encryption protects your messages. Only verified devices can decrypt them.',
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.4),
        textAlign: TextAlign.center,
        maxLines: 3,
      ),
    );
  }
}