// ==================== Create Group Controller ====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/screens/home/views/new_chat_screen.dart';
import 'package:niche_line_messaging/view/screens/media_library/controller/media-controller.dart';

class CreateGroupController extends GetxController {
  final RxList<RecipientModel> allRecipients = <RecipientModel>[].obs;
  final RxList<RecipientModel> filteredRecipients = <RecipientModel>[].obs;
  final RxList<RecipientModel> selectedMembers = <RecipientModel>[].obs;
  final RxBool isLoading = false.obs;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadRecipients();
  }

  void loadRecipients() {
    isLoading.value = true;

    // Demo data - Replace with API call
    Future.delayed(const Duration(seconds: 1), () {
      allRecipients.value = [
        RecipientModel(
          id: '1',
          name: 'Sarah Johnson',
          status: 'Hey there, I\'m using NichLine',
          avatar: '',
          isOnline: true,
        ),
        RecipientModel(
          id: '2',
          name: 'Mike Chen',
          status: 'Available',
          avatar: '',
          isOnline: true,
        ),
        RecipientModel(
          id: '3',
          name: 'Emma Davis',
          status: 'Busy',
          avatar: '',
          isOnline: false,
        ),
        RecipientModel(
          id: '4',
          name: 'Alex Thompson',
          status: 'Hey there, I\'m using NichLine',
          avatar: '',
          isOnline: true,
        ),
        RecipientModel(
          id: '5',
          name: 'Lisa Wang',
          status: 'Online',
          avatar: '',
          isOnline: true,
        ),
        RecipientModel(
          id: '6',
          name: 'David Park',
          status: 'Away',
          avatar: '',
          isOnline: false,
        ),
        RecipientModel(
          id: '7',
          name: 'Sophie Martinez',
          status: 'At work',
          avatar: '',
          isOnline: false,
        ),
        RecipientModel(
          id: '8',
          name: 'James Wilson',
          status: 'Sleeping',
          avatar: '',
          isOnline: false,
        ),
      ];

      filteredRecipients.value = allRecipients;
      isLoading.value = false;
    });
  }

  void searchRecipients(String query) {
    if (query.isEmpty) {
      filteredRecipients.value = allRecipients;
    } else {
      filteredRecipients.value = allRecipients
          .where((recipient) =>
              recipient.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void toggleMember(RecipientModel recipient) {
    if (selectedMembers.contains(recipient)) {
      selectedMembers.remove(recipient);
    } else {
      selectedMembers.add(recipient);
    }
  }

  bool isMemberSelected(RecipientModel recipient) {
    return selectedMembers.contains(recipient);
  }

  void createGroup() {
    if (groupNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a group name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return;
    }

    if (selectedMembers.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one member',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return;
    }

    // TODO: API call to create group
    Get.snackbar(
      'Success',
      'Group "${groupNameController}" created with ${selectedMembers.length} members',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.green,
      colorText:AppColors.white ,
      duration: const Duration(seconds: 2),
    );

    // Navigate back
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    groupNameController.dispose();
    super.onClose();
  }
}
