
// ==================== UI SCREEN ====================
// chat_info_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/screens/home/controller/recipient_controller.dart';

class ChatInfoScreen extends StatelessWidget {
  const ChatInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatInfoController());

    return Scaffold(
      backgroundColor: const Color(0xFF0E1527), // Dark navy
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1527),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2DD4BF)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Chat Info',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
          );
        }

        final chat = controller.chatInfo.value;
        if (chat == null) {
          return const Center(
            child: Text(
              'No chat info available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // ==================== Profile Section ====================
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    // Profile Image
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: const Color(0xFF2DD4BF),
                          backgroundImage: (chat.profileImage != null && chat.profileImage!.isNotEmpty)
                              ? NetworkImage(chat.profileImage!)
                              : null,
                          child: (chat.profileImage == null || chat.profileImage!.isEmpty)
                              ? Text(
                                  chat.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2DD4BF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 16.sp,
                              color: const Color(0xFF0E1527),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Name
                    Text(
                      chat.name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Bio
                    Text(
                      chat.bio ?? 'No bio available',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              // ==================== Options List ====================
              Column(
                children: [
                  // Mute Notifications
                  _buildSwitchOption(
                    icon: Icons.notifications_off_outlined,
                    title: 'Mute Notifications',
                    subtitle: 'Stop alerts for this chat',
                    value: false, // Default false - you can add isMuted to RecipientProfileModel
                    onChanged: controller.toggleMuteNotifications,
                    iconColor: Colors.grey,
                  ),

                  _buildDivider(),

                  // View Media
                  _buildNavigationOption(
                    icon: Icons.photo_library_outlined,
                    title: 'View Media',
                    onTap: controller.viewMedia,
                    iconColor: Colors.blue,
                  ),

                  _buildDivider(),

                  // Encryption Info
                  _buildNavigationOption(
                    icon: Icons.lock_outline,
                    title: 'Encryption Info',
                    subtitle: 'Your messages are end-to-end encrypted',
                    onTap: controller.viewEncryptionInfo,
                    iconColor: Colors.green,
                  ),

                  _buildDivider(),

                  // Export Chat
                  _buildNavigationOption(
                    icon: Icons.download_outlined,
                    title: 'Export Chat (Encrypted)',
                    subtitle: 'Save a secure backup of this conversation',
                    onTap: controller.exportChat,
                    iconColor: Colors.grey,
                  ),

                  _buildDivider(),

                  // Delete Chat
                  _buildNavigationOption(
                    icon: Icons.delete_outline,
                    title: 'Delete Chat',
                    subtitle: 'Delete all messages from this chat on your device',
                    onTap: controller.deleteChat,
                    iconColor: Colors.red,
                  ),

                  _buildDivider(),

                  // Block or Report
                  _buildNavigationOption(
                    icon: Icons.block_outlined,
                    title: 'Block or Report User',
                    subtitle: 'Prevent future messages and optionally report abuse',
                    onTap: controller.blockOrReportUser,
                    iconColor: Colors.red,
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // ==================== Encryption Footer ====================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'End-to-end encryption protects your messages. Only verified devices can decrypt them.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  // ==================== Switch Option Widget ====================
  Widget _buildSwitchOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color iconColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      leading: Icon(icon, color: iconColor, size: 24.sp),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.white.withOpacity(0.6),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2DD4BF),
        activeTrackColor: const Color(0xFF2DD4BF).withOpacity(0.5),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withOpacity(0.3),
      ),
    );
  }

  // ==================== Navigation Option Widget ====================
  Widget _buildNavigationOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      leading: Icon(icon, color: iconColor, size: 24.sp),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.6),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.white.withOpacity(0.3),
        size: 24.sp,
      ),
      onTap: onTap,
    );
  }

  // ==================== Divider Widget ====================
  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.1),
      height: 1,
      indent: 24.w,
      endIndent: 24.w,
    );
  }
}