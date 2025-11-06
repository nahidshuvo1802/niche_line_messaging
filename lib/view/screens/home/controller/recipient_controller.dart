
// ==================== CONTROLLER ====================
// chat_info_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/screens/home/model/recipient_profile_mode.dart';

class ChatInfoController extends GetxController {
  // ==================== Observable State ====================
  final Rx<RecipientProfileModel?> chatInfo = Rx<RecipientProfileModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isMuteToggling = false.obs;

  // ==================== Chat ID ====================
  String chatId = '';

  // ==================== Initialize with Chat ID ====================
  @override
  void onInit() {
    super.onInit();
    
    debugPrint('🔍 ChatInfoController onInit called');
    
    // Get chat ID from arguments
    chatId = Get.arguments?['chatId'] ?? '';
    debugPrint('🔍 Chat ID from arguments: $chatId');
    
    // Always fetch chat info even without chatId for testing
    fetchChatInfo();
  }

  // ==================== Fetch Chat Info ====================
  // TODO: Backend API থেকে chat info fetch করবে
  Future<void> fetchChatInfo() async {
    debugPrint('🔍 fetchChatInfo called');
    isLoading.value = true;
    debugPrint('🔍 isLoading set to true');

    try {
      // TODO: Replace with your actual API call
      // Example:
      // final response = await ApiClient.getData(ApiUrl.getChatInfo(chatId: chatId));
      // chatInfo.value = RecipientProfileModel.fromJson(response.body['data']);

      // Simulate API call
      debugPrint('🔍 Starting delay...');
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('🔍 Delay finished');

      // ==================== DUMMY DATA ====================
      // Temporary mock data - এটা দেখার জন্য
      chatInfo.value = RecipientProfileModel(
        userId: '67890abcdef',
        name: 'Sophia Chen',
        profileImage: '', // Empty photo - initials দেখাবে
        bio: 'UI/UX Designer at TechCorp. Available for collaboration.',
        // isMuted: false, // Add this if your model supports it
        // isEncrypted: true, // Add this if your model supports it
      );

      debugPrint('🔍 chatInfo.value set: ${chatInfo.value?.name}');
      
      isLoading.value = false;
      debugPrint('✅ Chat Info Fetched: ${chatInfo.value?.name}');
      debugPrint('🔍 isLoading set to false');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to load chat info',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('❌ Fetch Chat Info Error: $e');
    }
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
    // TODO: Navigate to media gallery screen
    // Get.toNamed(AppRoutes.mediaGallery, arguments: {'chatId': chatId});
    debugPrint('📷 View Media clicked for chat: $chatId');
    Get.snackbar(
      'Coming Soon',
      'Media gallery feature',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // ==================== View Encryption Info ====================
  void viewEncryptionInfo() {
    // TODO: Navigate to encryption details screen
    // Get.toNamed(AppRoutes.encryptionInfo, arguments: {'chatId': chatId});
    debugPrint('🔒 Encryption Info clicked');
    Get.snackbar(
      'End-to-End Encrypted',
      'Your messages are end-to-end encrypted',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // ==================== Export Chat ====================
  // TODO: Backend API দিয়ে chat export করবে
  Future<void> exportChat() async {
    try {
      // Show confirmation dialog
      bool? confirm = await Get.dialog<bool>(
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
            'Export Chat',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Save an encrypted backup of this conversation?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(
                'Export',
                style: TextStyle(color: Color(0xFF2DD4BF)),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // TODO: Replace with your actual API call
      // Example:
      // await ApiClient.postData(ApiUrl.exportChat, jsonEncode({'chatId': chatId}));

      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Success',
        'Chat exported successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      debugPrint('✅ Chat Exported: $chatId');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export chat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('❌ Export Chat Error: $e');
    }
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
                title: const Text('Block User',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Get.back(result: 'block'),
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.red),
                title: const Text('Report Abuse',
                    style: TextStyle(color: Colors.white)),
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
