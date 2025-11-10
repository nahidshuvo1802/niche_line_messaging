import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/home/controller/chat_detail_controller.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_details_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/recipient_info_screen.dart';

final TextEditingController messageController = TextEditingController();
RxString message = ''.obs;

class ChatDetailScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String recipientAvatar;

  const ChatDetailScreen({
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
    controller.initChat(widget.recipientId, widget.recipientName);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState(context);
              }
              if (controller.messages.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildMessagesList(context);
            }),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20.sp,
        ),
      ),
      title: Transform.translate(
        offset: const Offset(-20, 0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundImage: widget.recipientAvatar.isNotEmpty
                  ? NetworkImage(widget.recipientAvatar)
                  : null,
              child: widget.recipientAvatar.isEmpty
                  ? Text(
                      widget.recipientName[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  CustomText(
                    text: 'Online',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.primary,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            debugPrint('Search in chat');
          },
          icon: Icon(
            Icons.search,
            size: 24.sp,
          ),
        ),
        IconButton(
          onPressed: () {
            Get.to(() => const ChatInfoScreen());
          },
          icon: Icon(
            Icons.info,
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      reverse: true,
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        return _buildMessageItem(context, message);
      },
    );
  }

  Widget _buildMessageItem(BuildContext context, MessageModel message) {
    final isMe = message.senderId == 'me';
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.showDateLabel)
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: CustomText(
                  text: message.dateLabel ?? '',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 16.r,
                  backgroundImage: widget.recipientAvatar.isNotEmpty
                      ? NetworkImage(widget.recipientAvatar)
                      : null,
                  child: widget.recipientAvatar.isEmpty
                      ? Text(
                          widget.recipientName[0].toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: _buildMessageBubble(context, message, isMe),
              ),
            ],
          ),
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
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodySmall?.color,
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
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, MessageModel message, bool isMe) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(context, message, isMe);
      case MessageType.file:
        return _buildFileMessage(context, message, isMe);
      case MessageType.voice:
        return _buildVoiceMessage(context, message, isMe);
      case MessageType.typing:
        return _buildTypingIndicator(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextMessage(BuildContext context, MessageModel message, bool isMe) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
          bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
          bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
        ),
      ),
      child: CustomText(
        text: message.content,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isMe ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
        textAlign: TextAlign.left,
        maxLines: 100,
      ),
    );
  }

  Widget _buildFileMessage(BuildContext context, MessageModel message, bool isMe) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.2)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.insert_drive_file,
              color: isMe ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isMe ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: message.fileSize ?? '0 KB',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isMe
                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.8)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(BuildContext context, MessageModel message, bool isMe) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.2)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              color: isMe ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Row(
            children: List.generate(
              15,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                width: 3.w,
                height: (index % 3 + 1) * 8.h,
                decoration: BoxDecoration(
                  color: isMe
                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.6)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          CustomText(
            text: message.voiceDuration ?? '0:23',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isMe ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: 'Alex is typing',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: controller.showAttachmentOptions,
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: messageController,
                  onChanged: (value) => message.value = value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14.sp,
                  ),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEmpty ? Icons.mic : Icons.send,
                    color: Theme.of(context).colorScheme.onPrimary,
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

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: 'No messages yet',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: 'Say hi to ${widget.recipientName}!',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ],
      ),
    );
  }
}

enum MessageType {
  text,
  file,
  voice,
  image,
  video,
  typing,
}

