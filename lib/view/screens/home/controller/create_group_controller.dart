import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/service/subscription_service.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/screens/home/model/all_user_chat_list_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/chat_screen_one.dart';
import 'package:niche_line_messaging/view/screens/home/controller/chatlist_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:niche_line_messaging/view/screens/home/model/conversation_model.dart';

class CreateGroupController extends GetxController {
  // ==================== Reactive Variables ====================
  // Using AllUser from the chat list model for consistency with API
  final RxList<AllUser> allRecipients = <AllUser>[].obs;
  final RxList<AllUser> filteredRecipients = <AllUser>[].obs;
  final RxList<AllUser> selectedMembers = <AllUser>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isCreating = false.obs;
  final RxBool isMoreLoading = false.obs;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int currentPage = 1;

  int totalPage = 1;
  RxString myUserId = ''.obs; // Current user's ID to filter from list

  @override
  void onInit() {
    super.onInit();
    _initData();
    scrollController.addListener(_scrollListener);
  }

  Future<void> _initData() async {
    await fetchMyUserId();
    fetchRecipients();
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

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (currentPage < totalPage && !isMoreLoading.value) {
        fetchRecipients(isLoadMore: true);
      }
    }
  }

  // ==================== Fetch Users ====================
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

          // Filter out current user
          if (myUserId.value.isNotEmpty) {
            newUsers = newUsers
                .where((user) => user.sId != myUserId.value)
                .toList();
          }

          if (isLoadMore) {
            allRecipients.addAll(newUsers);
            currentPage++;
          } else {
            allRecipients.value = newUsers;
            filteredRecipients.value = newUsers;
            totalPage = meta?.totalPage ?? 1;
          }

          if (searchController.text.isNotEmpty) {
            searchRecipients(searchController.text);
          } else if (isLoadMore) {
            filteredRecipients.value = allRecipients;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void searchRecipients(String query) {
    if (query.isEmpty) {
      filteredRecipients.value = allRecipients;
    } else {
      filteredRecipients.value = allRecipients
          .where(
            (user) =>
                (user.name ?? "").toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  // ==================== Selection Logic ====================
  void toggleMember(AllUser user) {
    if (selectedMembers.contains(user)) {
      selectedMembers.remove(user);
    } else {
      selectedMembers.add(user);
    }
  }

  bool isMemberSelected(AllUser user) {
    return selectedMembers.contains(user);
  }

  // ==================== Create Group API ====================
  /// Endpoint: /api/v1/conversation/create_group (POST)
  /// Body: { "groupname": "...", "participants": ["id1", "id2"], "currentSubId": "...", "chat": "groupchat" }
  Future<void> createGroup() async {
    String groupName = groupNameController.text.trim();

    if (groupName.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a group name',
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedMembers.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one member',
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show Apple-style loading dialog
    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
          ),
          child: CupertinoActivityIndicator(radius: 20, color: Colors.white),
        ),
      ),
      barrierDismissible: false,
    );

    isCreating.value = true;

    try {
      // 1. Get Subscription ID
      String? currentSubId = await SubscriptionService.getSubscriptionId();
      if (currentSubId == null || currentSubId.isEmpty) {
        currentSubId =
            await SubscriptionService.fetchAndSaveActiveSubscription();
      }

      if (currentSubId == null) {
        Get.back(); // Close loading
        Get.snackbar(
          'Error',
          'Could not retrieve active subscription ID',
          backgroundColor: AppColors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 2. Prepare Payload
      // Add current user to participants ensuring unique list
      List<String?> allParticipants = selectedMembers
          .map((e) => e.sId)
          .toList();
      if (myUserId.value.isNotEmpty &&
          !allParticipants.contains(myUserId.value)) {
        allParticipants.add(myUserId.value);
      }

      Map<String, dynamic> body = {
        "groupname": groupName,
        "participants": allParticipants,
        "currentSubId": currentSubId,
        "chat": "groupchat",
      };

      // 3. Call API
      debugPrint('🚀 Creating Group: $body');
      var response = await ApiClient.postData(ApiUrl.createGroup, body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Group Created. Fetching conversation list...');

        // 4. Fetch Conversation List to get the ID
        try {
          var listResponse = await ApiClient.getData(
            ApiUrl.getConversationList(page: 1, limit: 10),
          );

          if (listResponse.statusCode == 200) {
            var model = ConversationModel.fromJson(listResponse.body);
            if (model.data?.allConversations != null) {
              // Find the newly created group by name and type
              var conversations = model.data!.allConversations!;
              AllConversations? createdGroup;

              try {
                // Try to find exact match first
                createdGroup = conversations.firstWhere(
                  (c) => c.groupname == groupName && c.chat == 'groupchat',
                );
              } catch (_) {
                // If not found by name, assume it's the first one (most recent)
                if (conversations.isNotEmpty) {
                  createdGroup = conversations.first;
                }
              }

              if (createdGroup != null && createdGroup.sId != null) {
                Get.back(); // Close loading dialog
                Get.back(); // Close CreateGroupScreen

                Get.snackbar(
                  'Success',
                  'Group "$groupName" created!',
                  backgroundColor: AppColors.green,
                  colorText: Colors.white,
                );

                // Navigate to Chat
                Get.to(
                  () => ChatDetailScreen(
                    recipientId: createdGroup!.sId!, // Using conv ID
                    recipientName: createdGroup!.groupname ?? groupName,
                    recipientAvatar: "",
                    conversationId: createdGroup!.sId!,
                    chatType: 'groupchat',
                  ),
                )?.then((_) {
                  if (Get.isRegistered<ChatListController>()) {
                    Get.find<ChatListController>().fetchConversations();
                  }
                });
                return;
              }
            }
          }
        } catch (e) {
          debugPrint("❌ Error fetching new group info: $e");
        }

        // Fallback: If fetching failed but creation succeeded
        Get.back(); // Close loading
        Get.back(); // Close CreateGroupScreen
        Get.snackbar(
          'Success',
          'Group "$groupName" created!',
          backgroundColor: AppColors.green,
          colorText: Colors.white,
        );
      } else {
        Get.back(); // Close loading
        Get.snackbar(
          'Error',
          'Failed to create group: ${response.statusText}',
          backgroundColor: AppColors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading
      debugPrint('Create Group Error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreating.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    groupNameController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
