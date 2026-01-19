import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/view/screens/home/model/all_user_chat_list_model.dart';

import 'package:niche_line_messaging/helper/shared_prefe/shared_prefe.dart';
import 'package:niche_line_messaging/utils/app_const/app_const.dart';

class AddMemberController extends GetxController {
  final RxList<AllUser> allRecipients = <AllUser>[].obs;
  final RxList<AllUser> filteredRecipients = <AllUser>[].obs;
  final RxList<AllUser> selectedMembers = <AllUser>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isAdding = false.obs;
  final RxBool isMoreLoading = false.obs;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;

  String conversationId = '';
  List<String> existingMemberIds = [];
  String currentUserId = '';

  @override
  void onInit() {
    super.onInit();

    // Retrieve arguments
    conversationId = Get.arguments?['conversationId'] ?? '';
    existingMemberIds = List<String>.from(
      Get.arguments?['existingMemberIds'] ?? [],
    );

    _initData();
    scrollController.addListener(_scrollListener);
  }

  Future<void> _initData() async {
    currentUserId = await SharePrefsHelper.getString(AppConstants.userId);
    fetchRecipients();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (currentPage < totalPage && !isMoreLoading.value) {
        fetchRecipients(isLoadMore: true);
      }
    }
  }

  Future<void> fetchRecipients({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isMoreLoading.value = true;
    } else {
      isLoading.value = true;
      currentPage = 1;
    }

    try {
      var response = await ApiClient.getData(
        ApiUrl.getAllUsersChatList(
          page: isLoadMore ? currentPage + 1 : 1,
          limit: 20,
        ),
      );

      if (response.statusCode == 200) {
        var model = AllUserChatListModel.fromJson(response.body);
        if (model.success == true && model.data != null) {
          var newUsers = model.data?.allUsers ?? [];
          var meta = model.data?.meta;

          // Filter out existing members AND current user
          newUsers = newUsers
              .where(
                (user) =>
                    !existingMemberIds.contains(user.sId) &&
                    user.sId != currentUserId,
              )
              .toList();

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

  Future<void> addMembers() async {
    if (selectedMembers.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one member',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isAdding.value = true;

    // Show loading
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

    try {
      // Loop through each selected member and add them individually
      bool allSuccess = true;
      String errorMessage = "";

      for (var member in selectedMembers) {
        if (member.sId == null) continue;

        Map<String, dynamic> body = {
          "conversationId": conversationId,
          "userId": member.sId,
        };

        debugPrint('🚀 Adding Member: $body');

        var response = await ApiClient.postData(ApiUrl.addMembersToGroup, body);

        if (response.statusCode != 200 && response.statusCode != 201) {
          allSuccess = false;
          errorMessage = response.statusText ?? "Unknown error";
          // Break or continue? Let's continue to try adding others, or break?
          // Usually better to fail fast or try all. Let's try all.
        }
      }

      Get.back(); // Close loading

      if (allSuccess) {
        Get.back(); // Close Screen
        Get.snackbar(
          'Success',
          'Members added successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Some members could not be added. $errorMessage',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading
      debugPrint('Add Members Error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isAdding.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
