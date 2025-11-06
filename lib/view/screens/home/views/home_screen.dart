import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/home/controller/chatlist_controller.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/new_chat_screen.dart';

final controller = Get.put(ChatListController());
// ==================== Chat List Screen ====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search Field (animated)
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: controller.isSearching.value ? 70.h : 0,
                child: controller.isSearching.value
                    ? _buildSearchField()
                    : const SizedBox.shrink(),
              )),

          // Chat List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.filteredChats.isEmpty) {
                return _buildEmptyState();
              }

              return _buildChatList();
            }),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ==================== AppBar ====================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo
          CustomImage(
            imageSrc: AppImages.splashScreenImage,
            height: 30.h,
            width: 30.h,
          ),
          const Spacer(),
          // Title
          CustomText(
            text: 'Chats',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          const Spacer(),
          // Search Icon
          Obx(() => IconButton(
                onPressed: controller.toggleSearch,
                icon: Icon(
                  controller.isSearching.value ? Icons.close : Icons.search,
                  color: const Color(0xFF2DD4BF),
                  size: 24.sp,
                ),
              )),
          SizedBox(width: 8.w),
          // Profile Avatar
          GestureDetector(
            onTap: () {
              debugPrint('Profile tapped');
            },
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: const Color(0xFF2DD4BF),
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=5',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Search Field ====================
  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.searchChats,
        autofocus: true,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          hintText: 'Search chats...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF2DD4BF),
            size: 20.sp,
          ),
          suffixIcon: controller.searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.searchController.clear();
                    controller.searchChats('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withOpacity(0.5),
                    size: 20.sp,
                  ),
                )
              : const SizedBox.shrink(),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: const Color(0xFF2DD4BF).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: const Color(0xFF2DD4BF).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(
              color: Color(0xFF2DD4BF),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Chat List ====================
  Widget _buildChatList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: controller.filteredChats.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.white.withOpacity(0.1),
        height: 1,
        thickness: 1,
        indent: 88.w,
        endIndent: 0,
      ),
      itemBuilder: (context, index) {
        final chat = controller.filteredChats[index];
        return _buildChatItem(chat);
      },
    );
  }

  // ==================== Chat Item ====================
  Widget _buildChatItem(ChatModel chat) {
    return InkWell(
      onTap: () => controller.openChat(chat),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor:
                      chat.isGroup ? const Color(0xFF2DD4BF) : Colors.grey,
                  backgroundImage:
                      chat.avatar.isNotEmpty ? NetworkImage(chat.avatar) : null,
                  child: chat.isGroup
                      ? Icon(Icons.group, color: Colors.white, size: 28.sp)
                      : null,
                ),
                if (!chat.isGroup && chat.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: chat.name,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      CustomText(
                        text: chat.timestamp,
                        textAlign: TextAlign.left,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: chat.lastMessage,
                          fontSize: 14.sp,
                          textAlign: TextAlign.left,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.7),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2DD4BF),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: CustomText(
                            text: chat.unreadCount > 99
                                ? '99+'
                                : chat.unreadCount.toString(),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Loading & Empty ====================
  Widget _buildLoadingState() => Center(
        child: CircularProgressIndicator(color: const Color(0xFF2DD4BF)),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 80.sp, color: Colors.white.withOpacity(0.3)),
            SizedBox(height: 16.h),
            CustomText(
              text: controller.searchController.text.isNotEmpty
                  ? 'No chats found'
                  : 'No chats yet',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: controller.searchController.text.isNotEmpty
                  ? 'Try searching with different keywords'
                  : 'Start a new conversation',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      );

  // ==================== FAB ====================
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: (){
        debugPrint('New chat tapped');
      Get.to(() => NewChatScreen());
      },
      backgroundColor: const Color(0xFF2DD4BF),
      child: Icon(Icons.chat_bubble, color: AppColors.primary, size: 28.sp),
    );
  }
}

