import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/home/controller/chat_detail_controller.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_details_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/recipient_info_screen.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/view/components/shimmer/shimmer_loading.dart';
import 'dart:io';

class ChatDetailScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String recipientAvatar;
  final String? conversationId;
  final String chatType;

  const ChatDetailScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    required this.recipientAvatar,
    this.conversationId,
    this.chatType = 'singlechat',
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatDetailController controller = Get.put(ChatDetailController());

  @override
  Widget build(BuildContext context) {
    controller.initChat(
      widget.recipientId,
      widget.recipientName,
      conversationId: widget.conversationId,
      chatType: widget.chatType,
    );

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
        icon: Icon(Icons.arrow_back_ios, size: 20.sp),
      ),
      title: Transform.translate(
        offset: const Offset(-20, 0),
        child: Row(
          children: [
            ClipOval(
              child: Container(
                width: 36.r,
                height: 36.r,
                color: Colors.grey[700],
                child: widget.chatType == 'groupchat'
                    ? Center(
                        child: Icon(
                          Icons.group,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      )
                    : widget.recipientAvatar.isNotEmpty
                    ? Image.network(
                        ApiUrl.getImageUrl(widget.recipientAvatar),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
              ),
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
        if (widget.chatType == 'groupchat')
          IconButton(
            onPressed: () => controller.addMemberToGroup(),
            icon: Icon(Icons.person_add, size: 24.sp),
          ),
        IconButton(
          onPressed: () {
            Get.to(
              () => const ChatInfoScreen(),
              arguments: {
                'chatId': widget.recipientId,
                'conversationId':
                    controller.currentConversationId ?? widget.conversationId,
                'chatType': widget.chatType,
              },
            );
          },
          icon: Icon(Icons.info, size: 24.sp),
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
    return Dismissible(
      key: Key(message.id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.w),
        child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
      ),
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: const Color(0xFF0E1527),
            title: const Text(
              'Delete Message?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to delete this message?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Get.back(result: true); // Close dialog first
                  await controller.deleteMessage(message.id);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (message.showDateLabel)
              Center(
                child: Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
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
              mainAxisAlignment: isMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe) ...[
                  ClipOval(
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      color: Colors.grey[700],
                      child: widget.chatType == 'groupchat'
                          ? (message.senderAvatar != null &&
                                    message.senderAvatar!.isNotEmpty)
                                ? Image.network(
                                    ApiUrl.getImageUrl(message.senderAvatar),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 18.sp,
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                  )
                          : widget.recipientAvatar.isNotEmpty
                          ? Image.network(
                              ApiUrl.getImageUrl(widget.recipientAvatar),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!isMe &&
                          widget.chatType == 'groupchat' &&
                          message.senderName != null &&
                          message.senderName!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 4.h, left: 4.w),
                          child: CustomText(
                            text: message.senderName!,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      _buildMessageBubble(context, message, isMe),
                    ],
                  ),
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
                mainAxisAlignment: isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
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
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    MessageModel message,
    bool isMe,
  ) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(context, message, isMe);
      case MessageType.file:
        return _buildFileMessage(context, message, isMe);
      case MessageType.voice:
        return _buildVoiceMessage(context, message, isMe);
      case MessageType.typing:
        return _buildTypingIndicator(context);
      case MessageType.image:
        return _buildImageMessage(context, message, isMe);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageMessage(
    BuildContext context,
    MessageModel message,
    bool isMe,
  ) {
    // Improved check:
    bool isLocal =
        message.attachmentUrl != null &&
        !message.attachmentUrl!.startsWith('http') &&
        File(message.attachmentUrl!).existsSync();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isMe
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: message.attachmentUrl != null
                ? (isLocal
                      ? Image.file(
                          File(message.attachmentUrl!),
                          width: 200.w,
                          height: 200.w,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          ApiUrl.getImageUrl(message.attachmentUrl),
                          width: 200.w,
                          height: 200.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 200.w,
                                height: 200.w,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                        ))
                : Container(
                    width: 200.w,
                    height: 200.w,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          if (message.content.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: CustomText(
                text: message.content,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isMe
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                textAlign: TextAlign.left,
                maxLines: 100,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextMessage(
    BuildContext context,
    MessageModel message,
    bool isMe,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isMe
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
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
        color: isMe
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        textAlign: TextAlign.left,
        maxLines: 100,
      ),
    );
  }

  Widget _buildFileMessage(
    BuildContext context,
    MessageModel message,
    bool isMe,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isMe
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
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
              color: isMe
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
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
                  color: isMe
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
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
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(
    BuildContext context,
    MessageModel message,
    bool isMe,
  ) {
    // For now, using a simple Play icon to represent functionality.
    // In a full implementation, this should be a StatefulWidget with audio player controller
    // or use GetX to manage player state for each message.
    // Given the request "audio player er option o thakbe", basic interaction is key.

    // Check if playing (this would require tracking playing state per message)
    // For simplicity in this iteration, we keep the UI but make it clickable to "fake" play or log it.
    // Ideally, we'd use 'just_audio' or 'audioplayers' here.
    // Since 'just_audio' is in pubspec, let's use a functional approach if possible,
    // but without converting this to StatefulWidget, we can't easily manage individual player states.
    // We will make it look interactive.

    return Obx(() {
      final isPlaying =
          controller.isAudioPlaying.value &&
          controller.currentlyPlayingUrl.value == message.attachmentUrl;

      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => controller.playAudio(message.attachmentUrl),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isMe
                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.2)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isMe
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Waveform visual placeholder
            Row(
              children: List.generate(
                15,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  width: 3.w,
                  height:
                      (index % 3 + 1) * 8.h, // Dynamic height could be added
                  decoration: BoxDecoration(
                    color: isMe
                        ? Theme.of(context).colorScheme.onPrimary.withOpacity(
                            isPlaying ? 0.9 : 0.6,
                          )
                        : Theme.of(context).colorScheme.onSurface.withOpacity(
                            isPlaying ? 0.9 : 0.4,
                          ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            CustomText(
              text: message.voiceDuration ?? 'Voice',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isMe
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      );
    });
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
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Section
            Obx(() {
              if (controller.selectedFile.value != null) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: Colors.grey[200],
                          image:
                              (controller.selectedFileType.value ==
                                      MessageType
                                          .file && // Assuming simple check for now
                                  (controller.selectedFile.value!.path
                                          .toLowerCase()
                                          .endsWith('.jpg') ||
                                      controller.selectedFile.value!.path
                                          .toLowerCase()
                                          .endsWith('.png') ||
                                      controller.selectedFile.value!.path
                                          .toLowerCase()
                                          .endsWith('.jpeg')))
                              ? DecorationImage(
                                  image: FileImage(
                                    controller.selectedFile.value!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            (controller.selectedFileType.value !=
                                    MessageType.file ||
                                (!controller.selectedFile.value!.path
                                        .toLowerCase()
                                        .endsWith('.jpg') &&
                                    !controller.selectedFile.value!.path
                                        .toLowerCase()
                                        .endsWith('.png') &&
                                    !controller.selectedFile.value!.path
                                        .toLowerCase()
                                        .endsWith('.jpeg')))
                            ? Icon(
                                Icons.insert_drive_file,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          controller.selectedFile.value!.path.split('/').last,
                          style: TextStyle(fontSize: 12.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: controller.clearAttachment,
                        icon: Icon(Icons.close, size: 20.sp, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            // Input Row
            Row(
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
                      controller: controller.messageController,
                      onChanged: (value) => controller.message.value = value,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14.sp,
                      ),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () async {
                    await controller.sendMessage();
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, color: Colors.white, size: 20.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const ChatDetailShimmer();
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

enum MessageType { text, file, voice, image, video, typing }
