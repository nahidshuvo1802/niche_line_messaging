import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
      backgroundColor: const Color(0xFF0A0E1A),
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
            _buildProfileSection(chatInfo, controller),
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
            Container(
              height: 0.3.h,
              width: 350.w,
              color: const Color.fromARGB(209, 255, 255, 255),
            ),
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
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            //========================DIVIDER===============================
            Container(
              height: 0.3.h,
              width: 350.w,
              color: const Color.fromARGB(209, 255, 255, 255),
            ),
            _buildNavigationOption(
              icon: Icons.cloud_upload_outlined,
              title: 'Export Chat (Encrypted)',
              subtitle: 'Save a secure backup of this conversation',
              onTap: controller.exportChat,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(12.r)),
            ),
            SizedBox(height: 20.h),
            _buildNavigationOption(
              icon: Icons.delete_outline,
              title: 'Delete Chat',
              subtitle: 'Remove all messages from this chat on your device',
              onTap: controller.deleteChat,
              iconColor: Colors.red,
              titleColor: Colors.red,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            //========================DIVIDER===============================
            Container(
              height: 0.3.h,
              width: 350.w,
              color: const Color.fromARGB(209, 255, 255, 255),
            ),

            _buildNavigationOption(
              icon: Icons.block_outlined,
              title: 'Block or Report User',
              subtitle: 'Prevent future messages and optionally report abuse',
              onTap: controller.blockOrReportUser,
              iconColor: Colors.red,
              titleColor: Colors.red,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(12.r)),
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
  Widget _buildProfileSection(
      dynamic chatInfo, ChatInfoController controller) {
    return Container(
      width: 370.w,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 14, 21, 39),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          _buildProfileAvatar(chatInfo, controller),
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

  // ==================== Profile Avatar with Edit ====================
  Widget _buildProfileAvatar(
      dynamic chatInfo, ChatInfoController controller) {
    final hasImage =
        chatInfo.profileImage != null && chatInfo.profileImage!.isNotEmpty;

    return Stack(
      children: [
        CircleAvatar(
          radius: 50.r,
          backgroundColor: Colors.grey[700],
          backgroundImage:
              hasImage ? NetworkImage(chatInfo.profileImage!) : null,
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
          child: GestureDetector(
            onTap: () => _showImagePickerOptions(controller),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 14, 21, 39),
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.edit,
                size: 12.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Show Image Picker Options ====================
  void _showImagePickerOptions(ChatInfoController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 14, 21, 39),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            CustomText(
              text: 'Change Profile Picture',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              bottom: 20.h,
            ),

            // Camera Option
            _buildImagePickerOption(
              icon: Icons.camera_alt,
              label: 'Take Photo',
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
              },
            ),

            SizedBox(height: 12.h),

            // Gallery Option
            _buildImagePickerOption(
              icon: Icons.photo_library,
              label: 'Choose from Gallery',
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.gallery);
              },
            ),

            SizedBox(height: 12.h),

            // Remove Photo Option (if image exists)
            if (controller.chatInfo.value?.profileImage != null &&
                controller.chatInfo.value!.profileImage!.isNotEmpty)
              _buildImagePickerOption(
                icon: Icons.delete_outline,
                label: 'Remove Photo',
                iconColor: Colors.red,
                labelColor: Colors.red,
                onTap: () {
                  Get.back();
                  controller.removeProfileImage();
                },
              ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  // ==================== Image Picker Option Widget ====================
  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? labelColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? const Color(0xFF2DD4BF),
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            CustomText(
              text: label,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: labelColor ?? Colors.white,
            ),
          ],
        ),
      ),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
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
  Widget _buildNavigationOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
    BorderRadius? borderRadius,
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

// ==================== Extension for ChatInfoController ====================
// Add these methods to your existing ChatInfoController

extension ImagePickerExtension on ChatInfoController {
  // ==================== Pick Image ====================
  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('❌ No image selected');
        return;
      }

      debugPrint('✅ Image selected: ${image.path}');

      // TODO: Upload image to server
      // Example:
      // final formData = FormData.fromMap({
      //   'profile_image': await MultipartFile.fromFile(image.path),
      //   'userId': chatInfo.value?.userId,
      // });
      // final response = await ApiClient.postData(ApiUrl.uploadProfileImage, formData);
      // if (response.statusCode == 200) {
      //   chatInfo.value = chatInfo.value!.copyWith(
      //     profileImage: response.body['data']['imageUrl']
      //   );
      // }

      // Simulate upload
      await Future.delayed(const Duration(seconds: 2));

      // Update local state with new image URL (mock)
      chatInfo.value = chatInfo.value!.copyWith(
        profileImage: image.path, // In production, use server URL
      );

      Get.snackbar(
        'Success',
        'Profile picture updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      debugPrint('✅ Profile image updated');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile picture',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('❌ Pick Image Error: $e');
    }
  }

  // ==================== Remove Profile Image ====================
  Future<void> removeProfileImage() async {
    try {
      // Show confirmation
      bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: const Color(0xFF0E1527),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Remove Profile Picture?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to remove your profile picture?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // TODO: Remove image from server
      // await ApiClient.deleteData(ApiUrl.removeProfileImage(userId: chatInfo.value!.userId));

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Update local state
      chatInfo.value = chatInfo.value!.copyWith(profileImage: '');

      Get.snackbar(
        'Success',
        'Profile picture removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      debugPrint('✅ Profile image removed');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove profile picture',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('❌ Remove Image Error: $e');
    }
  }
}