// ==================== Chat Detail Controller ====================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/service/socket_service.dart';
import 'package:niche_line_messaging/service/subscription_service.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_message_model.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_details_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/chat_screen_one.dart';
import 'package:niche_line_messaging/view/screens/home/views/add_member_screen.dart';
import 'package:niche_line_messaging/helper/shared_prefe/shared_prefe.dart';
import 'package:niche_line_messaging/utils/app_const/app_const.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart'; // Audio Player

class ChatDetailController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;

  final TextEditingController messageController = TextEditingController();
  final RxString message = ''.obs;

  // Attachment & Recording State
  final RxList<File> selectedFiles = <File>[].obs;
  final Rx<MessageType?> selectedFileType = Rx<MessageType?>(null);
  final RxBool isRecording = false.obs;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _picker = ImagePicker();

  String? currentRecipientId;
  String? currentRecipientName;
  String? currentConversationId; // Store conversation ID
  String? currentUserId;

  String? currentSubscriptionId;
  String chatType = 'singlechat'; // Store chat type

  // Audio Player State
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxString currentlyPlayingUrl = ''.obs;
  final RxBool isAudioPlaying = false
      .obs; // Renamed to avoid conflict with isRecording or isLoading if any

  @override
  void onInit() {
    super.onInit();
    _audioPlayer.playerStateStream.listen((state) {
      isAudioPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        isAudioPlaying.value = false;
        currentlyPlayingUrl.value = '';
        _audioPlayer.stop();
        _audioPlayer.seek(Duration.zero);
      }
    });
  }

  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void initChat(
    String recipientId,
    String recipientName, {
    String? conversationId,
    String chatType = 'singlechat',
  }) async {
    currentRecipientId = recipientId;
    currentRecipientName = recipientName;
    currentConversationId = conversationId;
    this.chatType = chatType;

    // Get current user ID and subscription ID
    currentUserId = await SharePrefsHelper.getString(AppConstants.userId);

    // First try to get from storage, if null fetch from API
    currentSubscriptionId = await SubscriptionService.getSubscriptionId();
    if (currentSubscriptionId == null || currentSubscriptionId!.isEmpty) {
      debugPrint('📡 Subscription ID not in storage, fetching from API...');
      currentSubscriptionId =
          await SubscriptionService.fetchAndSaveActiveSubscription();
    }

    debugPrint("═══════════════════════════════════════════════════════");
    debugPrint("📱 CHAT INIT:");
    debugPrint("   Recipient ID: $recipientId");
    debugPrint("   Conversation ID: $conversationId");
    debugPrint("   Current User ID: $currentUserId");
    debugPrint("   Subscription ID: $currentSubscriptionId");
    debugPrint("═══════════════════════════════════════════════════════");

    // Ensure socket is connected (will return immediately if already connected)
    debugPrint('Ensuring socket connection...');
    await SocketApi.init();

    // Setup socket listeners immediately
    _setupSocketListeners();

    fetchMessages();
  }

  void _setupSocketListeners() {
    // 1. Listen for new messages (Standard backend event)
    SocketApi.listen('new-message', (data) {
      debugPrint('📥 Received "new-message": $data');
      _handleIncomingMessage(data);
    });

    // 2. Listen for conversation created (New conversation started)
    SocketApi.listen('conversation-created', (data) {
      debugPrint('🆕 Conversation Created: $data');
      if (data['conversationId'] != null) {
        currentConversationId = data['conversationId'];
        debugPrint('✅ Set Conversation ID from event: $currentConversationId');
      }
      if (data['lastMessage'] != null) {
        _handleIncomingMessage(data['lastMessage']);
      }
    });

    // 3. Listen for typing
    SocketApi.listen('typing', (data) {
      debugPrint('✍️ User typing: $data');
    });

    // 4. Listen for Group Messages
    SocketApi.listen('group_send-message', (data) {
      debugPrint('📥 Received "group_send-message": $data');
      _handleIncomingMessage(data);
    });
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      if (data == null) return;

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📥 PROCESSING INCOMING MESSAGE:');
      debugPrint('   id: ${data['_id']}');
      debugPrint('   text: ${data['text']}');
      debugPrint('   msgByUserId: ${data['msgByUserId']}');
      debugPrint('   conversationId: ${data['conversationId']}');
      debugPrint('   My User ID: $currentUserId');
      debugPrint('═══════════════════════════════════════════════════════');

      // Check conversation ID
      String? msgConversationId = data['conversationId'];

      if (currentConversationId == null || currentConversationId!.isEmpty) {
        // If we are in a new chat (no ID yet), we adopt the ID from the first incoming message
        if (msgConversationId != null) {
          currentConversationId = msgConversationId;
          debugPrint(
            '✅ Conversation ID initiated from message: $currentConversationId',
          );
        }
      } else if (msgConversationId != null &&
          msgConversationId != currentConversationId) {
        debugPrint('📨 Message for different conversation, ignoring');
        return;
      }

      // Check sender
      // Backend returns 'msgByUserId' (String ID or Map)
      String? senderId;
      if (data['msgByUserId'] is Map) {
        senderId = data['msgByUserId']['_id'];
      } else {
        senderId = data['msgByUserId'];
      }

      if (senderId == currentUserId) {
        debugPrint('🔄 Own message echoed from backend, skipping');
        return;
      }

      // It's a message from the other person
      debugPrint('✅ Message is from other user ($senderId), adding to list');

      final dynamic textData = data['text'];
      String messageContent;
      if (textData is Map) {
        messageContent =
            textData['ciphertext']?.toString() ?? textData.toString();
      } else {
        messageContent = textData?.toString() ?? '';
      }

      // Extract sender info if available
      String? senderName;
      String? senderAvatar;
      if (data['msgByUserId'] is Map) {
        senderName = data['msgByUserId']['name'];
        senderAvatar = data['msgByUserId']['photo'];
      }

      // Determine Message Type and Attachment for incoming socket message
      // (Normally socket data should mirror API data structure)
      MessageType messageType = MessageType.text;
      String? attachment;

      if (data['imageUrl'] != null &&
          data['imageUrl'] is List &&
          data['imageUrl'].isNotEmpty) {
        messageType = MessageType.image;
        var firstImg = data['imageUrl'].first;
        if (firstImg is String) {
          attachment = firstImg;
        } else if (firstImg is Map) {
          // Handle encrypted Map if possible, or fallback.
          // If payload is {ciphertext: ...}, we might not be able to direct use.
          // For now, logging and avoiding crash.
          debugPrint('⚠️ Image URL is encrypted/map: $firstImg');
          // Attempt to use 'url' or 'path' if present, or just toString() as temporary (won't work for display)
          // If backend sends ciphertext, we can't display it without decryption.
          // We'll set it to null or a placeholder to avoid UI crash.
          attachment = null;
        } else {
          attachment = firstImg.toString();
        }
      } else if (data['audioUrl'] != null) {
        messageType = MessageType.voice;
        attachment = data['audioUrl'].toString();
      }

      final newMessage = MessageModel(
        id: data['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'other',
        content: messageContent,
        timestamp: _formatTime(DateTime.now()),
        type: messageType,
        isDelivered: true,
        isRead: false,
        senderName: senderName,
        senderAvatar: senderAvatar,
        attachmentUrl: attachment,
        originalMessage: data,
      );

      // Prevent duplicates if already added
      if (messages.any((msg) => msg.id == newMessage.id)) {
        debugPrint('⚠️ Message already exists in list, skipping');
        return;
      }

      messages.insert(0, newMessage);
      debugPrint('📩 New message added: ${newMessage.content}');
    } catch (e) {
      debugPrint('❌ Error handling incoming message: $e');
    }
  }

  Future<void> fetchMessages() async {
    if (currentConversationId == null || currentConversationId!.isEmpty) {
      debugPrint("❌ No Conversation ID provided, skipping fetch.");
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      String url = ApiUrl.getMessagesByConversation(currentConversationId!);
      debugPrint("🚀 Fetching messages from: $url");
      Response response = await ApiClient.getData(url);

      if (response.statusCode == 200) {
        MessageResponse apiResponse = MessageResponse.fromJson(response.body);

        if (apiResponse.success == true && apiResponse.data != null) {
          var apiMessages = apiResponse.data!.allmessage ?? [];

          messages.value = apiMessages.map((msg) {
            // Logic to determine 'me':
            // Compare sender ID with current user ID
            bool isMe = msg.msgByUserId?.sId == currentUserId;

            // Determine Message Type and Attachment
            MessageType messageType = MessageType.text;
            String? attachment;

            if (msg.imageUrl != null &&
                msg.imageUrl is List &&
                msg.imageUrl!.isNotEmpty) {
              messageType = MessageType.image;
              attachment = msg.imageUrl!.first.toString();
            } else if (msg.audioUrl != null) {
              messageType = MessageType.voice;
              attachment = msg.audioUrl.toString();
            }

            return MessageModel(
              id: msg.sId ?? '',
              senderId: isMe ? 'me' : 'other', // Mapping for UI
              content: msg.text ?? '',
              timestamp: _formatApiTime(msg.createdAt),
              type: messageType,
              isRead: msg.seen ?? false,
              isDelivered: true,
              originalMessage: msg,
              senderName: msg.msgByUserId?.name,
              senderAvatar: msg.msgByUserId?.photo,
              attachmentUrl: attachment,
            );
          }).toList();
        }
      } else {
        debugPrint("❌ Failed to fetch messages: ${response.statusText}");
      }
    } catch (e) {
      debugPrint("❌ Fetch Messages Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _formatApiTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      DateTime date = DateTime.parse(dateStr).toLocal();
      return _formatTime(date);
    } catch (e) {
      return '';
    }
  }

  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    // Allow send if text is not empty OR file is selected
    if (messageText.isEmpty && selectedFiles.isEmpty) return;

    // Determine Receiver ID
    String? targetReceiverId;
    if (chatType == 'groupchat') {
      // Find any other group member's ID from message history
      String? otherMemberId;
      try {
        final otherMessage = messages.firstWhereOrNull(
          (msg) =>
              msg.senderId == 'other' &&
              msg.originalMessage != null &&
              msg.originalMessage is ChatMessage &&
              (msg.originalMessage as ChatMessage).msgByUserId?.sId != null,
        );
        if (otherMessage != null) {
          otherMemberId =
              (otherMessage.originalMessage as ChatMessage).msgByUserId?.sId;
        }
      } catch (e) {
        debugPrint('⚠️ Error finding other member ID: $e');
      }

      if (otherMemberId != null && otherMemberId.isNotEmpty) {
        targetReceiverId = otherMemberId;
      } else {
        if (currentUserId == null || currentUserId!.isEmpty) {
          debugPrint('❌ Cannot send: Current User ID not found for Group Chat');
          return;
        }
        targetReceiverId = currentUserId;
      }
    } else {
      if (currentRecipientId == null || currentRecipientId!.isEmpty) {
        debugPrint('❌ Cannot send: No recipient ID');
        return;
      }
      targetReceiverId = currentRecipientId;
    }

    if (currentSubscriptionId == null || currentSubscriptionId!.isEmpty) {
      debugPrint('❌ Cannot send: No subscription ID');
      return;
    }
    String convId = currentConversationId ?? "";

    // Handle Messages
    if (selectedFiles.isNotEmpty) {
      // Send multiple files as separate messages
      // First file gets the caption (text)
      for (int i = 0; i < selectedFiles.length; i++) {
        File file = selectedFiles[i];
        String caption = (i == 0) ? messageText : " ";
        // Note: Using " " (space) because backend might require text field.

        // Optimistic Update
        final messageType = (selectedFileType.value ?? MessageType.file);

        final newMessage = MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + "_$i",
          senderId: 'me',
          content: caption.trim(),
          timestamp: _formatTime(DateTime.now()),
          type: messageType,
          isDelivered: false,
          isRead: false,
          fileName: file.path.split('/').last,
          attachmentUrl: file.path,
        );

        messages.insert(0, newMessage);

        // Send API
        _sendFileMessage(
          targetReceiverId: targetReceiverId!,
          convId: convId,
          text: caption,
          file: file,
          fileKey: (selectedFileType.value == MessageType.voice)
              ? 'audioUrl'
              : 'imageUrl',
        );
      }

      // Clear Input after queuing all
      messageController.clear();
      message.value = '';
      clearAttachment();
    } else {
      // Text Only
      // Optimistic
      final newMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me',
        content: messageText,
        timestamp: _formatTime(DateTime.now()),
        type: MessageType.text,
        isDelivered: false,
        isRead: false,
      );

      messages.insert(0, newMessage);
      messageController.clear();
      message.value = '';

      // Socket Send
      SocketApi.sendMessage(
        text: messageText,
        receiverId: targetReceiverId!,
        currentSubId: currentSubscriptionId!,
        conversationId: convId,
        chatType: chatType,
      );
    }
  }

  Future<void> _sendFileMessage({
    required String targetReceiverId,
    required String convId,
    required String text,
    required File file,
    required String fileKey,
  }) async {
    try {
      Map<String, dynamic> dataMap = {
        "receiverId": targetReceiverId,
        "currentSubId": currentSubscriptionId,
        "chat": chatType,
        "text": text.isEmpty ? " " : text,
      };

      if (convId.isNotEmpty) {
        dataMap["conversationId"] = convId;
      }

      List<MultipartBody> multipartList = [MultipartBody(fileKey, file)];

      Map<String, String> body = {'data': jsonEncode(dataMap)};

      debugPrint('📤 Sending File Message...');
      Response response = await ApiClient.postMultipartData(
        ApiUrl.sendMessage,
        body,
        multipartBody: multipartList,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ File Message Sent Successfully');
        // Start conversation if needed
        _checkAndUpdateConversationId(response.body);
      } else {
        debugPrint('❌ Failed to send file message: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error sending file message: $e');
    }
  }

  void _checkAndUpdateConversationId(dynamic resData) {
    if (resData is String) resData = jsonDecode(resData);
    String? newId;
    if (resData is Map) {
      if (resData['data'] is Map) {
        if (resData['data']['data'] is Map)
          newId = resData['data']['data']['conversationId'];
        if (newId == null) newId = resData['data']['conversationId'];
      }
      if (newId == null) newId = resData['conversationId'];
    }

    if (newId != null && newId.isNotEmpty) {
      if (currentConversationId == null || currentConversationId!.isEmpty) {
        currentConversationId = newId;
        debugPrint(
          '✅ New Conversation Created! ID updated: $currentConversationId',
        );
      }
    }
  }

  // ==================== Attachment Logic ====================

  void showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentOption(
                  icon: Icons.image,
                  color: Colors.purple,
                  label: "Gallery",
                  onTap: () {
                    Get.back();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  color: Colors.blue,
                  label: "Camera",
                  onTap: () {
                    Get.back();
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.videocam,
                  color: Colors.red,
                  label: "Video",
                  onTap: () {
                    Get.back();
                    _pickVideo();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  color: Colors.orange,
                  label: "File",
                  onTap: () {
                    Get.back();
                    _pickDocument();
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          CustomText(text: label, fontSize: 12, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedFiles.assignAll(images.map((e) => File(e.path)));
        selectedFileType.value = MessageType.image;
      }
    } else {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        selectedFiles.assignAll([File(image.path)]);
        selectedFileType.value = MessageType.image;
      }
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      selectedFiles.assignAll([File(video.path)]);
      selectedFileType.value = MessageType.file;
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      selectedFiles.assignAll([File(result.files.single.path!)]);
      selectedFileType.value = MessageType.file;
    }
  }

  void clearAttachment() {
    selectedFiles.clear();
    selectedFileType.value = null;
  }

  // ==================== Voice Recording ====================

  Future<void> startVoiceRecording() async {
    if (await Permission.microphone.request().isGranted) {
      if (isRecording.value) {
        await stopVoiceRecording();
      } else {
        try {
          final Directory appDir = await getApplicationDocumentsDirectory();
          final String filePath =
              '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: filePath,
          );

          isRecording.value = true;
          debugPrint('🎙️ Recording started: $filePath');
        } catch (e) {
          debugPrint('❌ Error starting recording: $e');
        }
      }
    } else {
      Get.snackbar('Permission Denied', 'Microphone permission is required');
    }
  }

  Future<void> stopVoiceRecording() async {
    if (!isRecording.value) return;

    try {
      final String? path = await _audioRecorder.stop();
      isRecording.value = false;

      if (path != null) {
        debugPrint('mic Recording stopped, file saved at: $path');
        selectedFiles.assignAll([File(path)]);
        selectedFileType.value = MessageType.voice;

        debugPrint('🎤 Audio ready to send. Type: ${selectedFileType.value}');
      }
    } catch (e) {
      debugPrint('❌ Error stopping recording: $e');
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final isToday =
        time.year == now.year && time.month == now.month && time.day == now.day;

    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    if (isToday) {
      return timeStr;
    } else {
      // Show date for older messages: "12 Jan, 10:30 PM"
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${time.day} ${months[time.month - 1]}, $timeStr';
    }
  }

  // ==================== Delete Message ====================
  Future<void> deleteMessage(String messageId) async {
    if (messageId.isEmpty) return;

    try {
      debugPrint("🗑️ Deleting message: $messageId");
      Response response = await ApiClient.deleteData(
        ApiUrl.deleteMessage(messageId),
      );

      if (response.statusCode == 200) {
        // Remove locally
        messages.removeWhere((msg) => msg.id == messageId);

        Get.snackbar(
          "Success",
          "Message deleted successfully",
          backgroundColor: const Color(0xFF2DD4BF),
          colorText: AppColors.primary,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        debugPrint(
          "❌ Failed to delete message: ${response.statusCode} - ${response.statusText}",
        );
        Get.snackbar(
          "Error",
          "Failed to delete message",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint("❌ Delete Message Error: $e");
      Get.snackbar(
        "Error",
        "Error deleting message",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== Add Member ====================
  Future<void> addMemberToGroup() async {
    if (chatType != 'groupchat') return;

    if (currentConversationId == null || currentConversationId!.isEmpty) {
      Get.snackbar(
        "Notice",
        "Please send a message to create the conversation first.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Show quick loading to indicate fetching
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Fetch fresh details to get members
      var response = await ApiClient.getData(
        ApiUrl.getSingleConversationDetails(currentConversationId!),
      );

      Get.back(); // Close loading

      if (response.statusCode == 200) {
        var data = response.body['data'];
        List<String> existingIds = [];
        if (data != null && data['participants'] != null) {
          for (var p in data['participants']) {
            // Logic mirrors RecipientController
            var user = p['userId'] ?? p;
            if (user is Map && user['_id'] != null) {
              existingIds.add(user['_id'].toString());
            } else if (user is String) {
              existingIds.add(user);
            }
          }
        }

        Get.to(
          () => AddMemberScreen(),
          arguments: {
            'conversationId': currentConversationId,
            'existingMemberIds': existingIds,
          },
        );
      } else {
        // Fallback navigate
        Get.to(
          () => AddMemberScreen(),
          arguments: {
            'conversationId': currentConversationId,
            'existingMemberIds': <String>[],
          },
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Close loading if error
      debugPrint("Error fetching group details: $e");
      // Fallback navigate
      Get.to(
        () => AddMemberScreen(),
        arguments: {
          'conversationId': currentConversationId,
          'existingMemberIds': <String>[],
        },
      );
    }
  }

  // ==================== Audio Playback ====================
  Future<void> playAudio(String? url) async {
    if (url == null || url.isEmpty) return;

    try {
      // Construct full URL if needed (similar to image handling)
      String fullUrl = url;
      bool isLocal = !url.startsWith('http');

      if (!isLocal) {
        fullUrl = ApiUrl.getImageUrl(
          url,
        ); // Should work for audio path too if relative
      }

      if (currentlyPlayingUrl.value == url) {
        // Toggle Pause/Play
        if (isAudioPlaying.value) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.play();
        }
      } else {
        // New Audio
        await _audioPlayer.stop();
        currentlyPlayingUrl.value = url;

        if (isLocal) {
          await _audioPlayer.setFilePath(fullUrl);
        } else {
          await _audioPlayer.setUrl(fullUrl);
        }

        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("❌ Error playing audio: $e");
      Get.snackbar(
        "Error",
        "Could not play audio",
        snackPosition: SnackPosition.BOTTOM,
      );
      currentlyPlayingUrl.value = '';
      isAudioPlaying.value = false;
    }
  }
}
