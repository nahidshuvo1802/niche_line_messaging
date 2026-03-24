import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/screens/home/model/all_user_chat_list_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/chat_screen_one.dart';
import 'package:niche_line_messaging/view/screens/home/controller/chatlist_controller.dart';
import 'package:niche_line_messaging/core/app_navigation.dart';

class NewChatController extends GetxController {
  // ==================== Reactive Variables ====================
  final RxBool isLoading = true.obs;
  final RxBool isMoreLoading = false.obs;
  final RxList<AllUser> recipients = <AllUser>[].obs;
  final RxList<AllUser> filteredRecipients = <AllUser>[].obs;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  RxString myUserId = ''.obs; // Current user's ID to filter from list

  @override
  void onInit() {
    super.onInit();
    fetchMyUserId();
    fetchRecipients();
    scrollController.addListener(_scrollListener);
  }

  Future<void> fetchMyUserId() async {
    try {
      var response = await ApiClient.getData(ApiUrl.getMyProfile);
      if (response.statusCode == 200) {
        var data = response.body['data'];
        if (data != null) {
          if (data['_id'] != null) {
            myUserId.value = data['_id'];
          } else if (data['id'] != null) {
            myUserId.value = data['id'];
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user ID: $e");
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (currentPage < totalPage && !isMoreLoading.value) {
        fetchRecipients(isLoadMore: true);
      }
    }
  }

  // ==================== Fetch Recipients from API ====================
  Future<void> fetchRecipients({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isMoreLoading.value = true;
    } else {
      isLoading.value = true;
      currentPage = 1;
    }

    try {
      var response = await ApiClient.getData(
        ApiUrl.getAllUsersChatList(page: isLoadMore ? currentPage + 1 : 1),
      );

      if (response.statusCode == 200) {
        var model = AllUserChatListModel.fromJson(response.body);
        if (model.success == true && model.data != null) {
          var newUsers = model.data?.allUsers ?? [];
          var meta = model.data?.meta;

          // Filter out current user from the list
          if (myUserId.value.isNotEmpty) {
            newUsers = newUsers
                .where((user) => user.sId != myUserId.value)
                .toList();
          }

          if (isLoadMore) {
            recipients.addAll(newUsers);
            currentPage++;
          } else {
            recipients.value = newUsers;
            filteredRecipients.value = newUsers; // Init filtered list
            totalPage = meta?.totalPage ?? 1;
          }
          // Re-apply search filter if needed
          if (searchController.text.isNotEmpty) {
            searchRecipients(searchController.text);
          } else if (isLoadMore) {
            filteredRecipients.value = recipients;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching recipients: $e");
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  // ==================== Search Recipients ====================
  void searchRecipients(String query) {
    if (query.isEmpty) {
      filteredRecipients.value = recipients;
    } else {
      filteredRecipients.value = recipients
          .where(
            (recipient) => (recipient.name ?? "").toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    }
  }

  // ==================== Start Chat ====================
  void startChat(AllUser user) {
    debugPrint('✅ Starting chat with: ${user.name}');
    AppNav.back(); // Close new chat screen

    Get.to(
      () => ChatDetailScreen(
        recipientId: user.sId ?? "",
        recipientName: user.name ?? "Unknown",
        recipientAvatar:
            user.photo ??
            'https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      ),
    )?.then((_) {
      if (Get.isRegistered<ChatListController>()) {
        Get.find<ChatListController>().fetchConversations();
      }
    });

    Get.snackbar(
      'Chat Started',
      'Opening conversation with ${user.name}',
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
