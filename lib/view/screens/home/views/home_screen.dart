import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/home/controller/chatlist_controller.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/create_group_chat_screen.dart';
import 'package:niche_line_messaging/view/screens/home/views/new_chat_screen.dart';
import 'package:niche_line_messaging/view/screens/settings/views/settings_main_screen.dart';

final controller = Get.put(ChatListController());

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1527), // Deep background
      body: SafeArea(
        child: Column(
          children: [
            // ================== Custom App Bar ==================
            _buildCustomAppBar(context),

            // ================== Quick Actions & Active Users ==================
            // এখানে Create Group বাটনটি হাইলাইট করা হয়েছে
            _buildQuickActionsRow(context),

            SizedBox(height: 20.h),

            // ================== Search & Filter ==================
            _buildSearchField(context),

            SizedBox(height: 10.h),

            // ================== Chat List ==================
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingState(context);
                  }
                  if (controller.filteredChats.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return _buildChatList(context);
                }),
              ),
            ),
          ],
        ),
      ),
      // Floating button for direct New Chat
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => NewChatScreen()),
        backgroundColor: const Color(0xFF2DD4BF),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(
          Icons.add_comment_rounded,
          color: Colors.white,
          size: 28.sp,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CustomImage(
                imageSrc: AppImages.splashScreenImage,
                height: 35.h,
                width: 35.h,
              ),
              SizedBox(width: 10.w),
              /* CustomText(
                text: 'NichLine',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ), */
            ],
          ),
          GestureDetector(
            onTap: () => Get.to(() => const SettingsScreen()),
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2DD4BF), width: 1.5),
              ),
              child: CircleAvatar(
                radius: 18.r,
                backgroundImage: const NetworkImage(
                  'https://i.pravatar.cc/150?img=5',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20.w),
        children: [
          // 1. Create Group Shortcut (Highlight)
          _buildQuickActionItem(
            context,
            icon: Icons.group_add,
            label: 'New Group',
            isSpecial: true,
            onTap: () => Get.to(() => CreateGroupScreen()),
          ),

          // 2. Active Users (Demo Data)
          _buildActiveUserItem('Emma', 'https://i.pravatar.cc/150?img=64'),
          _buildActiveUserItem('Alex', 'https://i.pravatar.cc/150?img=1'),
          _buildActiveUserItem('Sarah', 'https://i.pravatar.cc/150?img=5'),
          _buildActiveUserItem('Mike', 'https://i.pravatar.cc/150?img=12'),
          _buildActiveUserItem('Lisa', 'https://i.pravatar.cc/150?img=9'),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSpecial,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Container(
              height: 60.h,
              width: 60.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSpecial
                    ? const Color(0xFF2DD4BF).withOpacity(0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: const Color(0xFF2DD4BF),
                  width: 2, // Dashed effect could be added here
                ),
              ),
              child: Icon(icon, color: const Color(0xFF2DD4BF), size: 28.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: isSpecial ? const Color(0xFF2DD4BF) : Colors.white70,
                fontSize: 12.sp,
                fontWeight: isSpecial ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUserItem(String name, String imgUrl) {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 60.h,
                width: 60.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.transparent, width: 2),
                  image: DecorationImage(
                    image: NetworkImage(imgUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  height: 14.h,
                  width: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0E1527),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            name,
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: TextField(
          controller: controller.searchController,
          onChanged: controller.searchChats,
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: TextStyle(color: Colors.white38, fontSize: 14.sp),
            prefixIcon: Icon(Icons.search, color: Colors.white38, size: 22.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 80.h),
      itemCount: controller.filteredChats.length,
      itemBuilder: (context, index) {
        final chat = controller.filteredChats[index];
        return _buildChatTile(context, chat);
      },
    );
  }

  Widget _buildChatTile(BuildContext context, ChatModel chat) {
    return GestureDetector(
      onTap: () => controller.openChat(chat),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: chat.isGroup
                      ? const Color(0xFF2DD4BF).withOpacity(0.2)
                      : Colors.grey[800],
                  backgroundImage: chat.avatar.isNotEmpty
                      ? NetworkImage(chat.avatar)
                      : null,
                  child: chat.isGroup
                      ? Icon(
                          Icons.groups,
                          color: const Color(0xFF2DD4BF),
                          size: 28.sp,
                        )
                      : (chat.avatar.isEmpty
                            ? Text(
                                chat.name[0],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                ),
                              )
                            : null),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0E1527),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        chat.timestamp,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: chat.unreadCount > 0
                              ? const Color(0xFF2DD4BF)
                              : Colors.white38,
                          fontWeight: chat.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: chat.unreadCount > 0
                                ? Colors.white
                                : Colors.white54,
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2DD4BF),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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

  Widget _buildLoadingState(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF)));

  Widget _buildEmptyState(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.chat_bubble_outline, size: 60.sp, color: Colors.white24),
        SizedBox(height: 10.h),
        Text(
          "No chats found",
          style: TextStyle(color: Colors.white38, fontSize: 16.sp),
        ),
      ],
    ),
  );
}
