import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  // Reactive states for switches
  final RxBool isSoundEnabled = true.obs;
  final RxBool isVibrateEnabled = true.obs;
  final RxBool isGroupMentionsEnabled = true.obs;
  final RxBool isGroupMessagesEnabled = true.obs;
  final RxBool isShowUnreadCountEnabled = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1527),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2DD4BF)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
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
          ),
          
          // Content
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),

                // ==================== Message Alerts Section ====================
                _buildSectionCard(
                  title: 'Message Alerts',
                  children: [
                    // Sound
                    Obx(() => _buildSwitchOption(
                          icon: Icons.volume_up_outlined,
                          title: 'Sound',
                          subtitle: 'Play a tone when a new message arrives',
                          value: isSoundEnabled.value,
                          onChanged: (value) {
                            isSoundEnabled.value = value;
                          },
                        )),

                    Divider(color: Colors.white.withOpacity(0.1), height: 1),

                    // Vibrate
                    Obx(() => _buildSwitchOption(
                          icon: Icons.vibration,
                          title: 'Vibrate',
                          subtitle: 'Vibrate for incoming messages',
                          value: isVibrateEnabled.value,
                          onChanged: (value) {
                            isVibrateEnabled.value = value;
                          },
                        )),
                  ],
                ),

                SizedBox(height: 16.h),

                // ==================== Group & Mentions Section ====================
                _buildSectionCard(
                  title: 'Group & Mentions',
                  children: [
                    // Group Mentions
                    Obx(() => _buildSwitchOption(
                          icon: Icons.alternate_email,
                          title: 'Group Mentions',
                          subtitle: 'Notify when someone mentions you',
                          value: isGroupMentionsEnabled.value,
                          onChanged: (value) {
                            isGroupMentionsEnabled.value = value;
                           /*  Get.snackbar(
                              'Success',
                              value
                                  ? 'Group mentions enabled'
                                  : 'Group mentions disabled',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(milliseconds: 600),
                            ); */
                          },
                        )),

                    Divider(color: Colors.white.withOpacity(0.1), height: 1),

                    // Group Messages
                    Obx(() => _buildSwitchOption(
                          icon: Icons.groups_outlined,
                          title: 'Group Messages',
                          subtitle: 'Alert for messages in groups',
                          value: isGroupMessagesEnabled.value,
                          onChanged: (value) {
                            isGroupMessagesEnabled.value = value;
                           /*  Get.snackbar(
                              'Success',
                              value
                                  ? 'Group messages enabled'
                                  : 'Group messages disabled',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 1),
                            ); */
                          },
                        )),
                  ],
                ),

                SizedBox(height: 16.h),

                // ==================== App Badge Section ====================
                _buildSectionCard(
                  title: 'App Badge',
                  children: [
                    // Show Unread Count
                    Obx(() => _buildSwitchOption(
                          icon: Icons.circle_notifications,
                          title: 'Show Unread Count',
                          subtitle: 'Display unread count on app icon',
                          value: isShowUnreadCountEnabled.value,
                          onChanged: (value) {
                            isShowUnreadCountEnabled.value = value;
                          /*   Get.snackbar(
                              'Success',
                              value
                                  ? 'Unread count enabled'
                                  : 'Unread count disabled',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 1),
                            ); */
                          },
                        )),
                  ],
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Section Card Widget ====================
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 14, 21, 39),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF2DD4BF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  // ==================== Switch Option Widget ====================
  Widget _buildSwitchOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFF2DD4BF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2DD4BF),
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2DD4BF),
            activeTrackColor: const Color(0xFF2DD4BF).withOpacity(0.5),
            inactiveThumbColor: Colors.grey[600],
            inactiveTrackColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }
}