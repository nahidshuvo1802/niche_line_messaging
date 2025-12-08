import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/home/controller/new_chat_controller.dart';
import 'package:niche_line_messaging/view/screens/home/views/create_group_chat_screen.dart';

// ==================== New Chat Screen ====================
class NewChatScreen extends StatefulWidget {
  NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final NewChatController controller = Get.put(NewChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search Field
          _buildSearchField(),

          SizedBox(height: 16.h),

          // Recipients List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.filteredRecipients.isEmpty) {
                return _buildEmptyState();
              }

              return _buildRecipientsList();
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
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: const Color(0xFF2DD4BF),
          size: 20.sp,
        ),
      ),
      title: CustomText(
        text: 'New Chat',
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      centerTitle: true,
    );
  }

  // ==================== Search Field ====================
  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.searchRecipients,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          hintText: 'Search recipients',
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
                    controller.searchRecipients('');
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

  // ==================== Recipients List ====================
  Widget _buildRecipientsList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: controller.filteredRecipients.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.white.withOpacity(0.1),
        height: 1,
        thickness: 1,
        indent: 68.w,
        endIndent: 0,
      ),
      itemBuilder: (context, index) {
        final recipient = controller.filteredRecipients[index];
        return _buildRecipientItem(recipient);
      },
    );
  }

  // ==================== Recipient Item ====================
  Widget _buildRecipientItem(RecipientModel recipient) {
    return InkWell(
      onTap: () => controller.startChat(recipient),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: Colors.grey,
                  backgroundImage: recipient.avatar.isNotEmpty
                      ? NetworkImage(recipient.avatar)
                      : null,
                  child: recipient.avatar.isEmpty
                      ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 26.sp,
                        )
                      : null,
                ),
                if (recipient.isOnline)
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
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: 12.w),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: recipient.name,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text: recipient.status,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.6),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Loading State ====================
  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: const Color(0xFF2DD4BF),
      ),
    );
  }

  // ==================== Empty State ====================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 80.sp,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: controller.searchController.text.isNotEmpty
                ? 'No recipients found'
                : 'No contacts available',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: controller.searchController.text.isNotEmpty
                ? 'Try searching with different keywords'
                : 'Add some contacts to start chatting',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  // ==================== Floating Action Button ====================
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Navigate to create group screen
        Get.to(()=>CreateGroupScreen());
        debugPrint('Create group tapped');
        Get.snackbar(
          'Create Group',
          'Group creation feature coming soon',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2DD4BF),
          colorText: AppColors.primary,
        );
      },
      backgroundColor: const Color(0xFF2DD4BF),
      child: Icon(
        Icons.group_add,
        color: AppColors.primary,
        size: 28.sp,
      ),
    );
  }
}

// ==================== Recipient Model ====================
class RecipientModel {
  final String id;
  final String name;
  final String status;
  final String avatar;
  final bool isOnline;

  RecipientModel({
    required this.id,
    required this.name,
    required this.status,
    required this.avatar,
    this.isOnline = false,
  });

  // Factory method to create from API response
  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      avatar: json['avatar'] ?? '',
      isOnline: json['isOnline'] ?? false,
    );
  }

  // Method to convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'avatar': avatar,
      'isOnline': isOnline,
    };
  }
}

