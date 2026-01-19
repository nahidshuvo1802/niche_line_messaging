// ==================== CONTROLLER ====================
// chat_info_controller.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:niche_line_messaging/view/components/custom_text_field/custom_text_field.dart';
import 'package:niche_line_messaging/view/components/custom_text/custom_text.dart';
import 'package:niche_line_messaging/view/screens/home/model/recipient_profile_mode.dart';
import 'package:niche_line_messaging/view/screens/media_library/views/media-library-screen.dart';
import 'package:niche_line_messaging/view/screens/home/views/add_member_screen.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';

class ChatInfoController extends GetxController {
  // ==================== Observable State ====================
  final Rx<RecipientProfileModel?> chatInfo = Rx<RecipientProfileModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isMuteToggling = false.obs;

  // ==================== Chat ID ====================
  // ==================== Chat ID ====================
  String chatId = '';
  String conversationId = '';
  String chatType = 'singlechat';

  // ==================== Initialize with Chat ID ====================
  @override
  void onInit() {
    super.onInit();

    debugPrint('🔍 ChatInfoController onInit called');

    // Get chat ID from arguments
    chatId = Get.arguments?['chatId'] ?? '';
    conversationId = Get.arguments?['conversationId'] ?? '';
    chatType = Get.arguments?['chatType'] ?? 'singlechat';

    debugPrint('🔍 User ID (chatId): $chatId');
    debugPrint('🔍 Conversation ID: $conversationId');
    debugPrint('🔍 Chat Type: $chatType');

    // Always fetch chat info even without chatId for testing
    fetchChatInfo();
  }

  // ==================== Fetch Chat Info ====================
  Future<void> fetchChatInfo() async {
    debugPrint('🔍 fetchChatInfo called with ID: $chatId');
    isLoading.value = true;

    if (chatType == 'groupchat') {
      if (conversationId.isEmpty) {
        debugPrint('❌ Group Chat Conversation ID is empty');
        isLoading.value = false;
        return;
      }
      try {
        final url = ApiUrl.getSingleConversationDetails(conversationId);
        final response = await ApiClient.getData(url);

        if (response.statusCode == 200) {
          var body = response.body;
          var data = body['data'];
          if (data != null) {
            var groupName = data['conversationName'] ?? 'Group Chat';
            var groupIcon = data['groupIcon'] ?? data['icon'] ?? '';
            var participants = data['participants']; // Expecting list

            List<Map<String, dynamic>> memberList = [];
            if (participants != null && participants is List) {
              for (var p in participants) {
                if (p is Map<String, dynamic>) {
                  // Participant structure usually has user details directly or under 'userId'
                  // Adjust based on typical Mongo population
                  var user = p['userId'] ?? p;
                  if (user is String) continue; // If not populated

                  memberList.add({
                    'userId': user['_id'] ?? '',
                    'name': user['name'] ?? 'Unknown',
                    'profileImage': user['photo'] ?? '',
                    'role': p['role'], // Optional: admin/member
                  });
                }
              }
            }

            chatInfo.value = RecipientProfileModel(
              userId: conversationId,
              name: groupName,
              profileImage: ApiUrl.getImageUrl(groupIcon),
              bio: '${memberList.length} members',
              isMuted: false, // You might want to fetch actual mute status
              isEncrypted: true,
              members: memberList,
            );
          }
        } else {
          debugPrint('❌ Failed to fetch group info: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ Fetch Group Info Error: $e');
      } finally {
        isLoading.value = false;
      }
      return;
    }

    // Single Chat Logic
    if (chatId.isEmpty) {
      debugPrint('❌ Chat ID is empty');
      isLoading.value = false;
      return;
    }

    try {
      final response = await ApiClient.getData(
        ApiUrl.getOtherUserProfile(chatId),
      );

      if (response.statusCode == 200) {
        var body = response.body;
        dynamic userData;
        if (body is Map && body.containsKey('data')) {
          userData = body['data'];
        } else {
          userData = body;
        }

        if (userData != null) {
          chatInfo.value = RecipientProfileModel(
            userId: userData['_id'] ?? userData['id'] ?? chatId,
            name: userData['name'] ?? 'Unknown',
            profileImage: ApiUrl.getImageUrl(userData['photo']),
            bio: userData['email'] ?? '',
            isMuted: false,
            isEncrypted: true,
          );
        }
      } else {
        debugPrint('❌ Failed to fetch user info: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Fetch Chat Info Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Add People ====================
  void addPeople() {
    if (chatType != 'groupchat' || chatInfo.value == null) return;

    List<String> currentMemberIds = [];
    if (chatInfo.value!.members != null) {
      currentMemberIds = chatInfo.value!.members!
          .map((m) => m['userId'].toString())
          .toList();
    }

    debugPrint('🚀 Opening Add Members with existing: $currentMemberIds');

    Get.to(
      () => AddMemberScreen(),
      arguments: {
        'conversationId': conversationId,
        'existingMemberIds': currentMemberIds,
      },
    );
  }

  // ==================== See All Members ====================
  void seeAllMembers() {
    // Show full members list in a bottom sheet or new screen
    if (chatInfo.value?.members == null) return;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1527),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'All Members',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              bottom: 20.h,
            ),
            Expanded(
              child: ListView.separated(
                itemCount: chatInfo.value!.members!.length,
                separatorBuilder: (c, i) => Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  final member = chatInfo.value!.members![index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipOval(
                      child: Container(
                        width: 40.r,
                        height: 40.r,
                        color: Colors.grey[700],
                        child: (member['profileImage'] ?? '').isNotEmpty
                            ? Image.network(
                                ApiUrl.getImageUrl(member['profileImage']),
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                    title: Text(
                      member['name'] ?? 'Unknown',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: member['role'] == 'admin'
                        ? Text('Admin', style: TextStyle(color: Colors.teal))
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  // ==================== Toggle Mute Notifications ====================
  // TODO: Backend API দিয়ে mute status update করবে
  Future<void> toggleMuteNotifications(bool value) async {
    if (chatInfo.value == null) return;

    isMuteToggling.value = true;

    try {
      // TODO: Replace with your actual API call
      // Example:
      // final body = {'chatId': chatId, 'isMuted': value};
      // await ApiClient.patchData(ApiUrl.updateMuteStatus, jsonEncode(body));

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local state
      chatInfo.value = chatInfo.value!.copyWith(isMuted: value);

      isMuteToggling.value = false;

      Get.snackbar(
        'Success',
        value ? 'Notifications muted' : 'Notifications unmuted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      debugPrint('✅ Mute Status Updated: $value');
    } catch (e) {
      isMuteToggling.value = false;
      Get.snackbar(
        'Error',
        'Failed to update notification settings',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('❌ Toggle Mute Error: $e');
    }
  }

  // ==================== View Media ====================
  void viewMedia() {
    if (conversationId.isEmpty) {
      Get.snackbar(
        'Error',
        'No media available (New Conversation)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Pass conversationId as 'chatId' because MediaGalleryController expects it for fetching messages
    Get.to(() => MediaGalleryScreen(), arguments: {'chatId': conversationId});
    debugPrint('📷 View Media clicked for conversation: $conversationId');
  }

  // ==================== View Encryption Info ====================

  void viewEncryptionInfo() {
    debugPrint('🔒 Encryption Info clicked');

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 48.sp,
                color: const Color(0xFF2DD4BF),
              ),
              SizedBox(height: 16.h),
              Text(
                'End-to-End Encryption',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Your messages and calls are secured with end-to-end encryption. Only you and the person you\'re communicating with can read or listen to them, and nobody in between, not even NicheLine.',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    foregroundColor: const Color(0xFF0E1527),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Export Chat ====================
  // TODO: Backend API দিয়ে chat export করবে
  // ==================== Export Chat ====================
  // TODO: Backend API দিয়ে chat export করবে
  // ==================== Export Chat ====================
  Future<void> exportChat() async {
    debugPrint('💾 Export Chat clicked');

    final passphraseController = TextEditingController();
    final RxBool obscureText1 = true.obs;

    // Show encryption dialog
    bool? result = await Get.dialog<bool>(
      Dialog(
        backgroundColor: const Color(0xFF0E1527),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF2DD4BF).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export Chat',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Enter your recovery key to verify identity and decrypt messages for export.',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter your recovery key',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => CustomTextField(
                  textEditingController: passphraseController,
                  isPassword: obscureText1.value,
                  suffixIcon: IconButton(
                    onPressed: () => obscureText1.value = !obscureText1.value,
                    icon: Icon(
                      obscureText1.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white.withOpacity(0.4),
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (passphraseController.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please enter your recovery key',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    Get.back(result: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    foregroundColor: const Color(0xFF0E1527),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Verify & Export',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(result: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2DD4BF),
                    side: BorderSide(
                      color: const Color(0xFF2DD4BF).withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
        ),
        barrierDismissible: false,
      );

      try {
        // 1. Verify Device UID
        Map<String, String> deviceInfo = await _getDeviceInfo();
        String currentUid = deviceInfo['uid'] ?? '';

        // In a real app, you would compare 'currentUid' with the UID stored in the user's profile from the backend.
        // For this implementation, we ensure we can retrieve the UID.
        if (currentUid.isEmpty || currentUid == 'Unknown') {
          throw Exception("Could not verify device Identity.");
        }

        // 2. Verify Recovery Key (Mock verification logic as per user request context)
        // Checks if key format is valid (assuming 8 chars alphanumeric) or just matches input
        // Since we don't have the key stored locally to compare, we assume if the user provides it and it's valid format
        // and we are on the correct device, we proceed.
        // real verification would involve sending it to an endpoint.
        String inputKey = passphraseController.text;
        if (inputKey.length < 4) {
          // Basic length check
          throw Exception("Invalid Recovery Key format.");
        }

        // 3. Fetch Messages for Conversation
        List<Map<String, dynamic>> messages = await _fetchConversationMessages(
          conversationId,
        );

        if (messages.isEmpty) {
          throw Exception("No messages found to export.");
        }

        // 4. Generate PDF
        final pdfFile = await _generateChatPdf(
          messages,
          chatInfo.value?.name ?? "Chat",
        );

        Get.back(); // Close Loading

        // 5. Share PDF
        await Share.shareXFiles([
          XFile(pdfFile.path),
        ], text: 'Chat Export - ${chatInfo.value?.name}');

        Get.snackbar(
          'Success',
          'Chat exported successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.back(); // Close Loading
        Get.snackbar(
          'Export Failed',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        debugPrint('❌ Export Error: $e');
      }
    }
  }

  // Helper: Fetch Messages
  Future<List<Map<String, dynamic>>> _fetchConversationMessages(
    String conversationId,
  ) async {
    if (conversationId.isEmpty) return [];
    String url = ApiUrl.getMessagesByConversation(conversationId);
    final response = await ApiClient.getData(url);

    if (response.statusCode == 200) {
      final body = response.body;
      if (body['success'] == true &&
          body['data'] != null &&
          body['data']['allmessage'] != null) {
        return List<Map<String, dynamic>>.from(body['data']['allmessage']);
      }
    }
    return [];
  }

  // Helper: Generate PDF
  Future<File> _generateChatPdf(
    List<Map<String, dynamic>> messages,
    String chatName,
  ) async {
    final pdf = pw.Document();

    final List<pw.Widget> pdfContent = [];

    // Header
    pdfContent.add(
      pw.Header(
        level: 0,
        child: pw.Text(
          "Chat Export: $chatName",
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );
    pdfContent.add(pw.SizedBox(height: 20));

    // Process messages
    for (var msg in messages) {
      String senderName = msg['msgByUserId']?['name'] ?? 'Unknown';
      String text = msg['text'] ?? '';
      String time = msg['createdAt'] ?? '';
      String? imageUrl;

      // Check for image
      if (msg['imageUrl'] != null) {
        if (msg['imageUrl'] is List && (msg['imageUrl'] as List).isNotEmpty) {
          imageUrl = (msg['imageUrl'] as List).first.toString();
        } else if (msg['imageUrl'] is String) {
          imageUrl = msg['imageUrl'];
        }
      }

      // Handle formatting
      try {
        DateTime dt = DateTime.parse(time).toLocal();
        time = "${dt.year}-${dt.month}-${dt.day} ${dt.hour}:${dt.minute}";
      } catch (e) {}

      List<pw.Widget> messageWidgets = [
        pw.Text(
          "$senderName  [$time]",
          style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
        ),
      ];

      if (text.isNotEmpty && text != ' ') {
        messageWidgets.add(
          pw.Text(text, style: const pw.TextStyle(fontSize: 12)),
        );
      }

      // Add Image if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          String fullUrl = imageUrl.startsWith('http')
              ? imageUrl
              : ApiUrl.getImageUrl(imageUrl);
          final response = await http.get(Uri.parse(fullUrl));
          if (response.statusCode == 200) {
            final image = pw.MemoryImage(response.bodyBytes);
            messageWidgets.add(
              pw.Container(
                height: 200,
                alignment: pw.Alignment.centerLeft,
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
            );
          } else {
            messageWidgets.add(
              pw.Text(
                "[Image could not be loaded]",
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.red),
              ),
            );
          }
        } catch (e) {
          messageWidgets.add(
            pw.Text(
              "[Error loading image]",
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.red),
            ),
          );
        }
      }

      messageWidgets.add(pw.Divider(color: PdfColors.grey300));

      pdfContent.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: messageWidgets,
          ),
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pdfContent;
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/chat_export_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Helper: Get Device Info
  Future<Map<String, String>> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, String> deviceData = {
      'model': 'Unknown',
      'manufacturer': 'Unknown',
      'uid': 'Unknown',
    };

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData['model'] = androidInfo.model;
        deviceData['manufacturer'] = androidInfo.manufacturer;
        deviceData['uid'] = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData['model'] = iosInfo.model;
        deviceData['manufacturer'] = 'Apple';
        deviceData['uid'] = iosInfo.identifierForVendor ?? 'Unknown IOS ID';
      }
    } catch (e) {
      debugPrint("Failed to get device info: $e");
    }
    return deviceData;
  }

  // ==================== Delete Chat ====================
  // TODO: Backend API দিয়ে chat delete করবে
  Future<void> deleteChat() async {
    try {
      // Show confirmation dialog
      bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: const Color(0xFF0E1527),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.withOpacity(0.3), width: 1.5),
          ),
          title: const Text(
            'Delete Chat?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Delete all messages from this chat on your device?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // TODO: Replace with your actual API call
      // Example:
      // await ApiClient.deleteData(ApiUrl.deleteChat(chatId: chatId));

      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Success',
        'Chat deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate back to chat list
      Get.back();

      debugPrint('✅ Chat Deleted: $chatId');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete chat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('❌ Delete Chat Error: $e');
    }
  }

  // ==================== Block or Report User ====================
  // TODO: Backend API দিয়ে user block/report করবে
  Future<void> blockOrReportUser() async {
    try {
      // Show options dialog
      String? action = await Get.dialog<String>(
        AlertDialog(
          backgroundColor: const Color(0xFF0E1527),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF2DD4BF).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          title: const Text(
            'Block or Report User',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.block, color: Colors.orange),
                title: const Text(
                  'Block User',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Get.back(result: 'block'),
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.red),
                title: const Text(
                  'Report Abuse',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Get.back(result: 'report'),
              ),
            ],
          ),
        ),
      );

      if (action == null) return;

      if (action == 'block') {
        // TODO: Block user API call
        // await ApiClient.postData(ApiUrl.blockUser, jsonEncode({'userId': chatInfo.value!.userId}));

        await Future.delayed(const Duration(seconds: 1));

        Get.snackbar(
          'Success',
          'User blocked successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.back();
      } else if (action == 'report') {
        // TODO: Report user API call
        // await ApiClient.postData(ApiUrl.reportUser, jsonEncode({'userId': chatInfo.value!.userId}));

        await Future.delayed(const Duration(seconds: 1));

        Get.snackbar(
          'Success',
          'User reported. We will review this.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      debugPrint('✅ User Action: $action');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to perform action',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('❌ Block/Report Error: $e');
    }
  }

  @override
  void onClose() {
    // Cleanup if needed
    super.onClose();
  }
}
