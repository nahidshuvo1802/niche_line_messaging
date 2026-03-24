import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:niche_line_messaging/utils/app_images/app_images.dart';
import 'package:niche_line_messaging/view/components/custom_image/custom_image.dart';

import 'package:niche_line_messaging/view/screens/home/controller/chatlist_controller.dart';
import 'package:niche_line_messaging/view/screens/home/model/conversation_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/create_group_chat_screen.dart';
import 'package:niche_line_messaging/view/screens/home/views/new_chat_screen.dart';
import 'package:niche_line_messaging/view/screens/settings/views/settings_main_screen.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/view/components/shimmer/shimmer_loading.dart';
import 'package:niche_line_messaging/view/screens/settings/views/secure_folder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ChatListController controller;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChatListController());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPress == null ||
            now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          Fluttertoast.showToast(
            msg: 'Press back again to exit',
            toastLength: Toast.LENGTH_SHORT,
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ================== Custom App Bar ==================
            _buildCustomAppBar(context),

            // ================== Quick Actions & Active Users ==================
            _buildQuickActionsRow(context),

            // ================== Secure Folder Banner ==================
            _buildSecureFolderBanner(context),

            SizedBox(height: 20.h),

            // ================== Filter Tabs ==================
            _buildFilterTabs(context),

            SizedBox(height: 16.h),

            // ================== Search & Filter ==================
            _buildSearchField(context),

            SizedBox(height: 10.h),

            // ================== Chat List ==================
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).cardColor.withOpacity(0.5), // Adaptive container
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingState(context);
                  }
                  if (controller.filteredConversations.isEmpty) {
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
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(
          Icons.add_comment_rounded,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 28.sp,
        ),
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
            ],
          ),
          Obx(() {
            String imageUrl = controller.myProfileImageUrl.value;
            // Prepend base URL if relative path logic - kept simple as before
            return GestureDetector(
              onTap: () => Get.to(
                () => SettingsScreen(),
              ), // Navigate to Theme Settings directly for ease? Or SettingsMain
              // User asked for theme change, usually in Settings -> Appearance.
              // Assuming this profile icon goes to SettingsMainScreen generally.
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    width: 36.r,
                    height: 36.r,
                    color: Theme.of(context).dividerColor,
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ApiUrl.getImageUrl(imageUrl),
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                ShimmerCircle(size: 36.r),
                            errorWidget: (context, url, error) {
                              return Icon(
                                Icons.person,
                                size: 24.sp,
                                color: Theme.of(context).iconTheme.color,
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            size: 24.sp,
                            color: Theme.of(context).iconTheme.color,
                          ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: Obx(() {
        if (controller.isUsersLoading.value) {
          // Loading State (Shimmer)
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 20.w),
            itemCount: 6, // 1 Group + 5 Shimmers
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildQuickActionItem(
                  context,
                  icon: Icons.group_add,
                  label: 'New Group',
                  isSpecial: true,
                  onTap: () => Get.to(() => CreateGroupScreen()),
                );
              }
              return _buildShimmerUserItem(context);
            },
          );
        }

        // Data State
        return ListView.builder(
          controller: controller.userScrollController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: 20.w),
          itemCount:
              controller.allUsers.length +
              1 +
              (controller.isMoreUsersLoading.value ? 1 : 0),
          itemBuilder: (context, index) {
            // First Item: New Group
            if (index == 0) {
              return _buildQuickActionItem(
                context,
                icon: Icons.group_add,
                label: 'New Group',
                isSpecial: true,
                onTap: () => Get.to(() => CreateGroupScreen()),
              );
            }

            // Last Item: Load More Spinner
            if (index == controller.allUsers.length + 1) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
            }

            // User Items
            final user = controller.allUsers[index - 1];
            return _buildActiveUserItem(
              context,
              user.name ?? 'Unknown',
              user.photo ?? '', // Handle empty photo logic in widget
              () => controller.openChatWithUser(user),
            );
          },
        );
      }),
    );
  }

  Widget _buildSecureFolderBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const SecureFolderScreen()),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF203A43).withOpacity(0.5),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2DD4BF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.security_rounded,
                color: const Color(0xFF2DD4BF),
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Secure Folder",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DD4BF),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "NEW",
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Now you have secure folder to store all your data",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerUserItem(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Column(
        children: [
          Container(
            height: 60.h,
            width: 60.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 10.h,
            width: 40.w,
            color: Theme.of(context).cardColor,
          ),
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
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: isSpecial
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12.sp,
                fontWeight: isSpecial ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUserItem(
    BuildContext context,
    String name,
    String imgUrl,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Container(
                    height: 60.h,
                    width: 60.h,
                    color: Theme.of(context).cardColor,
                    child: imgUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ApiUrl.getImageUrl(imgUrl),
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                ShimmerCircle(size: 60.h),
                            errorWidget: (context, url, error) {
                              return Icon(
                                Icons.person,
                                size: 30.sp,
                                color: Theme.of(context).iconTheme.color,
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            size: 30.sp,
                            color: Theme.of(context).iconTheme.color,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              name,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    // Correctly using Theme colors instead of managing manual dark mode check
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: TextField(
          controller: controller.searchController,
          onChanged: controller.searchChats,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 14.sp,
          ),
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).textTheme.bodySmall?.color,
              size: 22.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState(context);
      }

      if (controller.filteredConversations.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshChats,
          color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(height: 0.7.sh, child: _buildEmptyState(context)),
          ),
        );
      }

      return AnimationLimiter(
        child: RefreshIndicator(
          onRefresh: controller.refreshChats,
          color: Theme.of(context).primaryColor,
          child: ListView.builder(
            controller: controller.chatScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 80.h),
            itemCount:
                controller.filteredConversations.length +
                (controller.isMoreChatLoading.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.filteredConversations.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final chat = controller.filteredConversations[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: _buildChatTile(context, chat)),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildChatTile(BuildContext context, AllConversations chat) {
    bool isGroup = chat.chat == 'groupchat';
    final participant = (!isGroup && chat.participants?.isNotEmpty == true)
        ? chat.participants![0]
        : null;

    String name = isGroup
        ? (chat.groupname ?? "Group Chat")
        : (participant?.name ?? "Unknown");

    String? avatar = (!isGroup && participant != null)
        ? participant.photo
        : null;

    return GestureDetector(
      onTap: () => controller.openChat(chat),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Theme.of(
            context,
          ).cardColor, // Use cardColor instead of gradient for reliable theming
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Avatar Section
              Stack(
                children: [
                  Container(
                    child: ClipOval(
                      child: Container(
                        width: 50.r,
                        height: 50.r,
                        color: isGroup
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Theme.of(context).disabledColor.withOpacity(0.1),
                        child: isGroup
                            ? Icon(
                                Icons.groups_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 28.sp,
                              )
                            : (avatar != null && avatar.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: ApiUrl.getImageUrl(avatar),
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    ShimmerCircle(size: 50.r),
                                errorWidget: (context, url, error) {
                                  return Center(
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : "?",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),

              // Details Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chat.updatedAt != null)
                          Text(
                            _formatTime(chat.updatedAt),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Last message row hidden as per user request
                    /*
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage ?? "No messages yet",
                            style: TextStyle(
                                                        color: Theme.of(context).textTheme.bodyMedium?.color,

                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Unread Counter Badge (Optional - can be added if data exists)
                        // For now just partial placeholder logic if we had unreadCount
                        // if (chat.unreadCount > 0) ...[ ... ]
                      ],
                    ),
                    */
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return "";
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
      DateTime now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return DateFormat('hh:mm a').format(date);
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day - 1) {
        return "Yesterday";
      } else {
        return DateFormat('dd MMM').format(date);
      }
    } catch (e) {
      return "";
    }
  }

  Widget _buildLoadingState(BuildContext context) => const ChatListShimmer();

  Widget _buildEmptyState(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_chat_unread_rounded,
            size: 50.sp,
            color: Theme.of(context).disabledColor,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          "No conversations yet",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Start chatting with your friends!",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 14.sp,
          ),
        ),
      ],
    ),
  );

  Widget _buildFilterTabs(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _buildFilterChip(context, 'All', 'all'),
          SizedBox(width: 12.w),
          _buildFilterChip(context, 'Chats', 'singlechat'),
          SizedBox(width: 12.w),
          _buildFilterChip(context, 'Groups', 'groupchat'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String value) {
    return Obx(() {
      bool isSelected = controller.selectedFilter.value == value;
      return GestureDetector(
        onTap: () => controller.changeFilter(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }
}
