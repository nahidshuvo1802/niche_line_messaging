import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/home/controller/chatlist_controller.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/new_chat_screen.dart';
import 'package:niche_line_messaging/view/screens/settings/views/settings_main_screen.dart';

final controller = Get.put(ChatListController());

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: controller.isSearching.value ? 70.h : 0,
                child: controller.isSearching.value
                    ? _buildSearchField(context)
                    : const SizedBox.shrink(),
              )),
          Expanded(
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
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          CustomImage(
            imageSrc: AppImages.splashScreenImage,
            height: 30.h,
            width: 30.h,
          ),
          const Spacer(),
          const CustomText(
            text: 'Chats',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          const Spacer(),
          Obx(() => IconButton(
                onPressed: controller.toggleSearch,
                icon: Icon(
                  controller.isSearching.value ? Icons.close : Icons.search,
                  size: 24.sp,
                ),
              )),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              Get.to(() => const SettingsScreen());
            },
            child: CircleAvatar(
              radius: 18.r,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=5',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.searchChats,
        autofocus: true,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          hintText: 'Search chats...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 16.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    size: 20.sp,
                  ),
                )
              : const SizedBox.shrink(),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: controller.filteredChats.length,
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).dividerColor,
        height: 1,
        thickness: 1,
        indent: 88.w,
        endIndent: 0,
      ),
      itemBuilder: (context, index) {
        final chat = controller.filteredChats[index];
        return _buildChatItem(context, chat);
      },
    );
  }

  Widget _buildChatItem(BuildContext context, ChatModel chat) {
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
                  backgroundColor: chat.isGroup ? Theme.of(context).colorScheme.primary : Colors.grey,
                  backgroundImage:
                      chat.avatar.isNotEmpty ? NetworkImage(chat.avatar) : null,
                  child: chat.isGroup
                      ? Icon(Icons.group, color: Theme.of(context).colorScheme.onPrimary, size: 28.sp)
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
                          color: Theme.of(context).scaffoldBackgroundColor,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      CustomText(
                        text: chat.timestamp,
                        textAlign: TextAlign.left,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: chat.lastMessage,
                          fontSize: 14,
                          textAlign: TextAlign.left,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
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
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: CustomText(
                            text: chat.unreadCount > 99
                                ? '99+'
                                : chat.unreadCount.toString(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
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

  Widget _buildLoadingState(BuildContext context) => Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      );

  Widget _buildEmptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 80.sp, color: Theme.of(context).textTheme.bodySmall?.color),
            SizedBox(height: 16.h),
            CustomText(
              text: controller.searchController.text.isNotEmpty
                  ? 'No chats found'
                  : 'No chats yet',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: controller.searchController.text.isNotEmpty
                  ? 'Try searching with different keywords'
                  : 'Start a new conversation',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      );

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        debugPrint('New chat tapped');
        Get.to(() => NewChatScreen());
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(Icons.chat_bubble, color: Theme.of(context).colorScheme.onPrimary, size: 28.sp),
    );
  }
}
