// ==================== Chat Detail Controller ====================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_details_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/chat_screen_one.dart';

class ChatDetailController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;


  String? currentRecipientId;
  String? currentRecipientName;

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void initChat(String recipientId, String recipientName) {
    currentRecipientId = recipientId;
    currentRecipientName = recipientName;
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Mock messages - Replace with API call
      messages.value = [
        MessageModel(
          id: '7',
          senderId: 'other',
          content: 'Alex is typing',
          timestamp: '',
          type: MessageType.typing,
        ),
        MessageModel(
          id: '6',
          senderId: 'me',
          content: 'Perfect! The voice message feature is working smoothly too.',
          timestamp: '10:44 AM',
          type: MessageType.text,
          isDelivered: true,
          isRead: true,
        ),
        MessageModel(
          id: '5',
          senderId: 'me',
          content: '',
          timestamp: '10:38 AM',
          type: MessageType.voice,
          voiceDuration: '0:23',
          isDelivered: true,
          isRead: false,
        ),
        MessageModel(
          id: '4',
          senderId: 'me',
          content: '',
          timestamp: '10:38 AM',
          type: MessageType.file,
          fileName: 'NichLine_v2.1.apk',
          fileSize: '132.4 MB',
          isDelivered: true,
          isRead: true,
        ),
        MessageModel(
          id: '3',
          senderId: 'other',
          content: 'Awesome! Can you send me the latest build when ready?',
          timestamp: '10:36 AM',
          type: MessageType.text,
        ),
        MessageModel(
          id: '2',
          senderId: 'me',
          content:
              'Great! Almost done with the E2E encryption implementation. Testing phase now.',
          timestamp: '10:33 AM',
          type: MessageType.text,
          isDelivered: true,
          isRead: true,
        ),
        MessageModel(
          id: '1',
          senderId: 'other',
          content: 'Hey! How\'s the new security feature coming along?',
          timestamp: '10:30 AM',
          type: MessageType.text,
          showDateLabel: true,
          dateLabel: 'Today',
        ),
      ];

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Fetch Messages Error: $e');
    }
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      content: messageController.text.trim(),
      timestamp: _formatTime(DateTime.now()),
      type: MessageType.text,
      isDelivered: false,
      isRead: false,
    );

    messages.insert(0, newMessage);
    messageController.clear();

    // TODO: Send to API
    debugPrint('✅ Message sent: ${newMessage.content}');
  }

  void showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAttachmentOption(Icons.image, 'Photo', () {
              Get.back();
              debugPrint('Photo selected');
            }),
            _buildAttachmentOption(Icons.videocam, 'Video', () {
              Get.back();
              debugPrint('Video selected');
            }),
            _buildAttachmentOption(Icons.insert_drive_file, 'Document', () {
              Get.back();
              debugPrint('Document selected');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
      IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2DD4BF), size: 24.sp),
            SizedBox(width: 16.w),
            CustomText(
              text: label,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void startVoiceRecording() {
    // TODO: Implement voice recording
    debugPrint('🎤 Voice recording started');
    Get.snackbar(
      'Voice Recording',
      'Voice recording feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2DD4BF),
      colorText: AppColors.primary,
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}