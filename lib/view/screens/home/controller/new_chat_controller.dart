// ==================== New Chat Controller ====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/screens/home/model/recipient_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/new_chat_screen.dart';

class NewChatController extends GetxController {
  // ==================== Reactive Variables ====================
  final RxBool isLoading = true.obs;
  final RxList<RecipientModel> recipients = <RecipientModel>[].obs;
  final RxList<RecipientModel> filteredRecipients = <RecipientModel>[].obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchRecipients();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ==================== Fetch Recipients from API ====================
  Future<void> fetchRecipients() async {
    isLoading.value = true;

    try {
      // TODO: Replace with actual API call
      // Example:
      // final response = await ApiClient.getData(ApiUrl.getContacts);
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = response.body['data'];
      //   recipients.value = data.map((e) => RecipientModel.fromJson(e)).toList();
      //   filteredRecipients.value = recipients;
      // }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - Replace with actual API response
      recipients.value = [
        RecipientModel(
          id: '1',
          name: 'Sarah Johnson',
          status: 'Hey there, I\'m using NichLine',
          avatar: 'https://i.pravatar.cc/150?img=1',
          isOnline: false,
        ),
        RecipientModel(
          id: '2',
          name: 'Mike Chen',
          status: 'Available',
          avatar: 'https://i.pravatar.cc/150?img=2',
          isOnline: true,
        ),
        RecipientModel(
          id: '3',
          name: 'Emma Davis',
          status: 'Busy',
          avatar: 'https://i.pravatar.cc/150?img=3',
          isOnline: false,
        ),
        RecipientModel(
          id: '4',
          name: 'Alex Thompson',
          status: 'Hey there, I\'m using NichLine',
          avatar: 'https://i.pravatar.cc/150?img=4',
          isOnline: false,
        ),
        RecipientModel(
          id: '5',
          name: 'Lisa Wang',
          status: 'Online',
          avatar: 'https://i.pravatar.cc/150?img=5',
          isOnline: true,
        ),
        RecipientModel(
          id: '6',
          name: 'David Park',
          status: 'Away',
          avatar: 'https://i.pravatar.cc/150?img=6',
          isOnline: false,
        ),
        RecipientModel(
          id: '7',
          name: 'Sophie Martinez',
          status: 'At work',
          avatar: 'https://i.pravatar.cc/150?img=7',
          isOnline: true,
        ),
        RecipientModel(
          id: '8',
          name: 'James Wilson',
          status: 'Sleeping',
          avatar: 'https://i.pravatar.cc/150?img=8',
          isOnline: false,
        ),
      ];

      filteredRecipients.value = recipients;
      isLoading.value = false;

      debugPrint('✅ Recipients loaded: ${recipients.length}');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to load contacts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('❌ Fetch Recipients Error: $e');
    }
  }

  // ==================== Search Recipients ====================
  void searchRecipients(String query) {
    if (query.isEmpty) {
      filteredRecipients.value = recipients;
    } else {
      filteredRecipients.value = recipients
          .where((recipient) =>
              recipient.name.toLowerCase().contains(query.toLowerCase()) ||
              recipient.status.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // ==================== Start Chat ====================
  void startChat(RecipientModel recipient) {
    // TODO: Navigate to chat detail screen with this recipient
    // Get.to(() => ChatDetailScreen(recipient: recipient));

    debugPrint('✅ Starting chat with: ${recipient.name}');

    Get.back(); // Close new chat screen
    
    Get.snackbar(
      'Chat Started',
      'Opening conversation with ${recipient.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2DD4BF),
      colorText: AppColors.primary,
      duration: const Duration(seconds: 2),
    );
  }

  // ==================== Refresh Recipients ====================
  Future<void> refreshRecipients() async {
    await fetchRecipients();
  }
}