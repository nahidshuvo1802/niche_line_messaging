
// ==================== CONTROLLER ====================
// chat_info_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/view/components/custom_text_field/custom_text_field.dart';
import 'package:niche_line_messaging/view/screens/home/model/recipient_profile_mode.dart';
import 'package:niche_line_messaging/view/screens/media_library/views/media-library-screen.dart';

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
    Get.to(()=>  MediaGalleryScreen());
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
  debugPrint('🔒 Encryption Info clicked');
  
  final recoveryKeyController = TextEditingController();
  final RxBool obscureText = true.obs;
  
  // Show restore messages dialog
  Get.dialog(
    Dialog(
      backgroundColor: const Color(0xFF1A1F3A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Restore Messages',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // Description
            Text(
              'Enter your recovery key to decrypt your messages and restore access.',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 24.h),
            
            // Recovery Key Label
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recovery Key',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // Recovery Key Input
            Obx(() => CustomTextField(
              textEditingController: recoveryKeyController,
              isPassword: obscureText.value,
              hintText: 'Enter your recovery key',
              suffixIcon: IconButton(
                onPressed: () => obscureText.value = !obscureText.value,
                icon: Icon(
                  obscureText.value ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.4),
                  size: 20.sp,
                ),
              ),
            )),
            
            SizedBox(height: 24.h),
            
            // Decrypt Messages Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  if (recoveryKeyController.text.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please enter your recovery key',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  
                  // TODO: API call to decrypt messages
                  Get.back();
                  
                  Get.snackbar(
                    'Success',
                    'Messages decrypted successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  
                  debugPrint('✅ Messages Decrypted');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5568),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Decrypt Messages',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Warning Note
            Text(
              'NichLine never stores your passphrase.',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.5),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  ).then((_) {
    recoveryKeyController.dispose();
  });
}
  // ==================== Export Chat ====================
  // TODO: Backend API দিয়ে chat export করবে
  // ==================== Export Chat ====================
  // TODO: Backend API দিয়ে chat export করবে
  Future<void> exportChat() async {
    debugPrint('💾 Export Chat clicked');
    
    final passphraseController = TextEditingController();
    final confirmPassphraseController = TextEditingController();
    final RxBool obscureText1 = true.obs;
    final RxBool obscureText2 = true.obs;
    
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
              // Title
              Text(
                'Enable Secure Backup?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: 12.h),
              
              // Description
              Text(
                'Protect your messages and encryption keys with a recovery passphrase. Only you can decrypt your data.',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 24.h),
              
              // Enter Recovery Key Label
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
              
              // Recovery Key Input
              CustomTextField(
                textEditingController: passphraseController,
                isPassword: true,
                  suffixIcon: IconButton(
                    onPressed: () => obscureText1.value = !obscureText1.value,
                    icon: Icon(
                      obscureText1.value ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.4),
                      size: 20.sp,
                    ),
                  ),
                ),
              
              SizedBox(height: 16.h),
              
              // Confirm Recovery Key Label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Confirm recovery key',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              
              SizedBox(height: 8.h),
               CustomTextField(
                textEditingController: confirmPassphraseController,
                isPassword: true,
                  suffixIcon: IconButton(
                    onPressed: () => obscureText1.value = !obscureText1.value,
                    icon: Icon(
                      obscureText1.value ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.4),
                      size: 20.sp,
                    ),
                  ),
                ),
              // Confirm Recovery Key Input
              /* Obx(() => TextField(
                controller: confirmPassphraseController,
                obscureText: obscureText2.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Confirm your passphrase',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14.sp,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => obscureText2.value = !obscureText2.value,
                    icon: Icon(
                      obscureText2.value ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.4),
                      size: 20.sp,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: const Color(0xFF2DD4BF),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              )), */
              
              SizedBox(height: 24.h),
              
              // Encrypt & Backup Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Validate passwords match
                    if (passphraseController.text.isEmpty || 
                        confirmPassphraseController.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please enter and confirm your passphrase',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    
                    if (passphraseController.text != confirmPassphraseController.text) {
                      Get.snackbar(
                        'Error',
                        'Passphrases do not match',
                        snackPosition: SnackPosition.BOTTOM,
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
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Encrypt & Backup',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 12.h),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: () => Get.back(result: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2DD4BF),
                    side: BorderSide(
                      color: const Color(0xFF2DD4BF).withOpacity(0.5),
                      width: 1.5,
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
              
              SizedBox(height: 16.h),
              
              // Warning Note
              Text(
                'NichLine cannot recover your messages without this passphrase.',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.5),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
    
    // If user confirmed
    if (result == true) {
      try {
        // TODO: Replace with actual API call
        // Example:
        // await ApiClient.postData(ApiUrl.exportChat, jsonEncode({
        //   'chatId': chatId,
        //   'passphrase': passphraseController.text,
        // }));
        
        // Simulate export process
        await Future.delayed(const Duration(seconds: 2));
        
        Get.snackbar(
          'Success',
          'Chat exported and encrypted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        debugPrint('✅ Chat Exported with encryption: $chatId');
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
    
    // Cleanup
    passphraseController.dispose();
    confirmPassphraseController.dispose();
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
