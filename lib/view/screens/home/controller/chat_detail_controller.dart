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
  final Rx<File?> selectedFile = Rx<File?>(null);
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
    if (messageText.isEmpty && selectedFile.value == null) return;

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

    // Optimistic Update
    final messageType = selectedFile.value != null
        ? (selectedFileType.value ?? MessageType.file)
        : MessageType.text;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      content: messageText,
      timestamp: _formatTime(DateTime.now()),
      type: messageType,
      isDelivered: false,
      isRead: false,
      fileName: selectedFile.value?.path.split('/').last,
      attachmentUrl: selectedFile.value?.path,
    );

    messages.insert(0, newMessage);

    // Clear Input
    messageController.clear();
    message.value = '';
    File? fileToSend = selectedFile.value;
    clearAttachment(); // Clear immediately for UI

    // Send Logic
    if (fileToSend != null) {
      // Multipart Send (New Chat or Existing with Image)
      try {
        Map<String, dynamic> dataMap = {
          "receiverId": targetReceiverId,
          "currentSubId": currentSubscriptionId,
          "chat": chatType,
          "text": messageText.isEmpty
              ? " "
              : messageText, // Ensure text is not empty for some APIs
        };

        // Determine correct key for the file based on type
        String fileKey =
            'imageUrl'; // Default for images and generic files as per current setup
        if (selectedFileType.value == MessageType.voice) {
          fileKey = 'audioUrl';
        }

        List<MultipartBody> multipartList = [
          MultipartBody(fileKey, fileToSend),
        ];

        if (convId.isNotEmpty) {
          dataMap["conversationId"] = convId;
        }

        // The body has 'data' key which is JSON string
        // The body has 'data' key which is JSON string
        Map<String, String> body = {'data': jsonEncode(dataMap)};

        // Note: We DO NOT add conversationId/receiverId/chat to top-level body
        // because the user provided Postman example shows ONLY 'data' (json string) and 'imageUrl'.
        // Adding them might confuse the ID creation logic on backend.

        debugPrint('📤 Sending Multipart Message...');
        debugPrint('   Data Payload: $body');

        Response response = await ApiClient.postMultipartData(
          ApiUrl.sendMessage,
          body,
          multipartBody: multipartList,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('✅ Multipart Message Sent Successfully');
          try {
            var resData = response.body;
            debugPrint('📥 Response Data: $resData');

            if (resData is String) {
              resData = jsonDecode(resData);
            }

            // Robust Extraction of conversationId from Response
            String? newId;
            if (resData is Map) {
              // Path 1: data -> data -> conversationId (Matches user's JSON)
              if (resData['data'] is Map) {
                if (resData['data']['data'] is Map) {
                  newId = resData['data']['data']['conversationId'];
                }
                // Path 2: data -> conversationId
                if (newId == null &&
                    resData['data']['conversationId'] != null) {
                  newId = resData['data']['conversationId'];
                }
              }
              // Path 3: data (root) -> conversationId
              if (newId == null && resData['conversationId'] != null) {
                newId = resData['conversationId'];
              }
            }

            if (newId != null && newId.isNotEmpty) {
              // Update current conversation ID if it was null or empty
              // This ensures subsequent messages use this ID
              if (currentConversationId == null ||
                  currentConversationId!.isEmpty) {
                currentConversationId = newId;

                debugPrint(
                  '✅ New Conversation Created! ID updated: $currentConversationId',
                );
              }
            } else {
              debugPrint('⚠️ conversationId not found in response');
            }
          } catch (e) {
            debugPrint(
              '⚠️ Could not extract conversation ID from API response: $e',
            );
          }
        } else {
          debugPrint(
            '❌ Failed to send multipart message: ${response.statusCode} - ${response.statusText}',
          );
        }
      } catch (e) {
        debugPrint('❌ Error sending multipart message: $e');
      }
    } else {
      // Socket Send (Text Only)
      // Logic remains same as established - first text message via socket should also trigger ID creation events if backend supports it
      SocketApi.sendMessage(
        text: messageText,
        receiverId: targetReceiverId!,
        currentSubId: currentSubscriptionId!,
        conversationId: convId,
        chatType: chatType,
      );
    }
  }

  // ==================== Attachment Logic ====================

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
            _buildAttachmentOption(Icons.camera_alt, 'Camera', () {
              Get.back();
              _pickImage(ImageSource.camera);
            }),
            _buildAttachmentOption(Icons.image, 'Gallery', () {
              Get.back();
              _pickImage(ImageSource.gallery);
            }),
            _buildAttachmentOption(Icons.videocam, 'Video', () {
              Get.back();
              _pickVideo();
            }),
            _buildAttachmentOption(Icons.insert_drive_file, 'Document', () {
              Get.back();
              _pickDocument();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
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

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedFile.value = File(image.path);
      selectedFileType.value = MessageType.image;
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      selectedFile.value = File(video.path);
      selectedFileType.value = MessageType.file;
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      selectedFile.value = File(result.files.single.path!);
      selectedFileType.value = MessageType.file;
    }
  }

  void clearAttachment() {
    selectedFile.value = null;
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
        selectedFile.value = File(path);
        // Check if it's considered a voice message
        selectedFileType.value = MessageType.voice;

        // Optionally auto-send or show preview.
        // Auto-send as per user request ("cchobi jemne jay omnei jabe" - usually means instant for voice notes)
        // However, if they want it EXACTLY like images (preview first), I should assume manual send.
        // BUT, standard voice note UX is "release to send" or "stop and send".
        // The UI shows a send button when hasFile is true.
        // User said "audio recording *o* pathabo... cchobi jemne jay omnei jabe"
        // It implies the mechanism of *sending data* should be same (multipart), not necessarily the UX flow.
        // But to be safe and responsive, let's stick to manual send for now as the UI supports it.
        // If I auto-send, the UI might flicker or user might not have chance to review.
        // Let's NOT auto-send, but standard UX usually does.
        // I will stick to what the code does: set selectedFile.
        // Wait, the user said "omnei jabe" - implies consistent behavior.
        // Images have a preview step. So audio should too.
        // Existing code sets selectedFile, showing preview (if UI supports audio preview).
        // Let's verify UI audio preview support.

        // Actually, looking at UI _buildMessageInput:
        /*
          child: (controller.selectedFileType.value != MessageType.file || ... ) 
                  ? Icon(Icons.insert_drive_file...)
        */
        // It shows a generic file icon if not image.
        // So for audio, it will show generic file icon.
        // This is "like images" in terms of "Preview -> Send".
        // So I will NOT add auto-send here. The user just wanted the *functionality* to work.
        // My previous edit fixed the upload Key. That should be enough.
        // I will just add a debug print here.
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
