import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/home/controller/chat_detail_controller.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_details_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/recipient_info_screen.dart';

final TextEditingController messageController = TextEditingController();
RxString message = ''.obs;
// ==================== Chat Detail Screen ====================
class ChatDetailScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String recipientAvatar;

  ChatDetailScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    required this.recipientAvatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatDetailController controller = Get.put(ChatDetailController());

  @override
  Widget build(BuildContext context) {
    // Initialize with recipient info
    controller.initChat(widget.recipientId, widget.recipientName);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.messages.isEmpty) {
                return _buildEmptyState();
              }

              return _buildMessagesList();
            }),
          ),

          // Message Input
          _buildMessageInput(),
        ],
      ),
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
      title: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: const Color(0xFF2DD4BF),
            backgroundImage: widget.recipientAvatar.isNotEmpty
                ? NetworkImage(widget.recipientAvatar)
                : null,
            child: widget.recipientAvatar.isEmpty
                ? Text(
                    widget.recipientName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: widget.recipientName,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                  text: 'Online',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF2DD4BF),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Search in chat
            debugPrint('Search in chat');
          },
          icon: Icon(
            Icons.search,
            color: const Color(0xFF2DD4BF),
            size: 24.sp,
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Open chat settings
            // debugPrint('Chat settings');
            Get.to(()=>ChatInfoScreen());
          },
          icon: Icon(
            Icons.info,
            color: const Color(0xFF2DD4BF),
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  // ==================== Messages List ====================
  Widget _buildMessagesList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      reverse: true,
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        return _buildMessageItem(message);
      },
    );
  }

  // ==================== Message Item ====================
  Widget _buildMessageItem(MessageModel message) {
    final isMe = message.senderId == 'me';

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Date Label (if needed)
          if (message.showDateLabel)
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: CustomText(
                  text: message.dateLabel ?? '',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),

          // Message Bubble
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: const Color(0xFF2DD4BF),
                  backgroundImage: widget.recipientAvatar.isNotEmpty
                      ? NetworkImage(widget.recipientAvatar)
                      : null,
                  child: widget.recipientAvatar.isEmpty
                      ? Text(
                          widget.recipientName[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: _buildMessageBubble(message, isMe),
              ),
            ],
          ),

          // Timestamp and Status
          Padding(
            padding: EdgeInsets.only(
              top: 4.h,
              left: isMe ? 0 : 48.w,
              right: isMe ? 8.w : 0,
            ),
            child: Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                CustomText(
                  text: message.timestamp,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.5),
                ),
                if (isMe) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    message.isRead
                        ? Icons.done_all
                        : message.isDelivered
                            ? Icons.done_all
                            : Icons.done,
                    size: 14.sp,
                    color: message.isRead
                        ? const Color(0xFF2DD4BF)
                        : Colors.white.withOpacity(0.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Message Bubble ====================
  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(message, isMe);
      case MessageType.file:
        return _buildFileMessage(message, isMe);
      case MessageType.voice:
        return _buildVoiceMessage(message, isMe);
      case MessageType.typing:
        return _buildTypingIndicator();
      default:
        return const SizedBox.shrink();
    }
  }

  // ==================== Text Message ====================
  Widget _buildTextMessage(MessageModel message, bool isMe) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF2DD4BF) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
          bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
          bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
        ),
      ),
      child: CustomText(
        text: message.content,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: isMe ? Colors.white : Colors.black87,
        textAlign: TextAlign.left,
        maxLines: 100,
      ),
    );
  }

  // ==================== File Message ====================
  Widget _buildFileMessage(MessageModel message, bool isMe) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF2DD4BF) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.insert_drive_file,
              color: isMe ? Colors.white : Colors.black87,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: message.fileName ?? 'File',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isMe ? Colors.white : Colors.black87,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: message.fileSize ?? '0 KB',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: isMe
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black54,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Voice Message ====================
  Widget _buildVoiceMessage(MessageModel message, bool isMe) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF2DD4BF) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              color: isMe ? Colors.white : Colors.black87,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          // Waveform representation
          Row(
            children: List.generate(
              15,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                width: 3.w,
                height: (index % 3 + 1) * 8.h,
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.white.withOpacity(0.6)
                      : Colors.black45,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          CustomText(
            text: message.voiceDuration ?? '0:23',
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isMe ? Colors.white : Colors.black87,
          ),
        ],
      ),
    );
  }

  // ==================== Typing Indicator ====================
  Widget _buildTypingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: 'Alex is typing',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Message Input ====================
Widget _buildMessageInput() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: AppColors.primary,
      border: Border(
        top: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
    ),
    child: SafeArea(
      child: Row(
        children: [
          // Attachment Button
          GestureDetector(
            onTap: controller.showAttachmentOptions,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: const BoxDecoration(
                color: Color(0xFF2DD4BF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Text Input
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: messageController,
                onChanged: (value) => message.value = value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Send / Mic Button (Reactive)
          Obx(() {
            final isEmpty = message.value.trim().isEmpty;
            return GestureDetector(
              onTap: isEmpty
                  ? controller.startVoiceRecording
                  : () {
                      controller.sendMessage();
                      messageController.clear();
                      message.value = '';
                    },
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF2DD4BF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEmpty ? Icons.mic : Icons.send,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            );
          }),
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
            Icons.chat_bubble_outline,
            size: 80.sp,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: 'No messages yet',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: 'Say hi to ${widget.recipientName}!',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

// ==================== Message Type Enum ====================
enum MessageType {
  text,
  file,
  voice,
  image,
  video,
  typing,
}

