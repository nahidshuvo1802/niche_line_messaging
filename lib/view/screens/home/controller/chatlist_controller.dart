// ==================== Controller ====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/view/screens/home/model/all_user_chat_list_model.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/chat_screen_one.dart';

import 'package:niche_line_messaging/view/screens/home/model/conversation_model.dart';
import 'package:niche_line_messaging/service/socket_service.dart';

class ChatListController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isSearching = false.obs;
  final RxList<AllConversations> conversations = <AllConversations>[].obs;
  final RxList<AllConversations> filteredConversations =
      <AllConversations>[].obs;
  final TextEditingController searchController = TextEditingController();

  // Pagination for Chats
  final RxBool isMoreChatLoading = false.obs;
  int chatPage = 1;
  int chatTotalPage = 1;
  final ScrollController chatScrollController = ScrollController();

  // Pagination & Users (Active/New Chat)
  final RxList<AllUser> allUsers = <AllUser>[].obs;
  final RxBool isUsersLoading = false.obs;
  final RxBool isMoreUsersLoading = false.obs;
  int currentPage = 1;
  int totalPage = 1;
  final ScrollController userScrollController = ScrollController();

  RxString myProfileImageUrl = ''.obs;
  RxString myUserId = ''.obs; // Current user's ID to filter from lists

  @override
  void onInit() {
    super.onInit();
    _initSocket(); // Connect socket when HomeScreen loads
    fetchConversations();
    fetchAllUsers();
    fetchMyProfile();
    userScrollController.addListener(_scrollListener);
    chatScrollController.addListener(_chatScrollListener);
  }

  Future<void> _initSocket() async {
    debugPrint('🏠 HomeScreen loaded - Initializing socket...');
    if (!SocketApi.isConnected()) {
      await SocketApi.init();
    } else {
      debugPrint('✅ Socket already connected');
    }
  }

  Future<void> fetchMyProfile() async {
    try {
      var response = await ApiClient.getData(ApiUrl.getMyProfile);
      if (response.statusCode == 200) {
        var data = response.body['data'];
        if (data != null) {
          if (data['photo'] != null) {
            myProfileImageUrl.value = data['photo'];
          }
          // Store current user's ID
          if (data['_id'] != null) {
            myUserId.value = data['_id'];
          } else if (data['id'] != null) {
            myUserId.value = data['id'];
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    userScrollController.dispose();
    chatScrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (userScrollController.position.pixels ==
        userScrollController.position.maxScrollExtent) {
      if (currentPage < totalPage && !isMoreUsersLoading.value) {
        fetchAllUsers(isLoadMore: true);
      }
    }
  }

  void _chatScrollListener() {
    if (chatScrollController.position.pixels >=
        chatScrollController.position.maxScrollExtent - 50) {
      if (chatPage < chatTotalPage && !isMoreChatLoading.value) {
        fetchConversations(isLoadMore: true);
      }
    }
  }

  RxString selectedFilter = 'all'.obs; // all, singlechat, groupchat

  void changeFilter(String filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    fetchConversations(isLoadMore: false);
  }

  Future<void> fetchConversations({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isMoreChatLoading.value = true;
    } else {
      isLoading.value = true;
      chatPage = 1;
    }

    try {
      String? searchTerm = selectedFilter.value == 'all'
          ? null
          : selectedFilter.value;

      var response = await ApiClient.getData(
        ApiUrl.getConversationList(
          page: isLoadMore ? chatPage + 1 : 1,
          searchTerm: searchTerm,
        ),
      );

      if (response.statusCode == 200) {
        var model = ConversationModel.fromJson(response.body);
        if (model.success == true && model.data != null) {
          var newConversations = model.data?.allConversations ?? [];
          var meta = model.data?.meta;

          if (isLoadMore) {
            conversations.addAll(newConversations);
            chatPage++;

            // Update filtered list as well
            if (searchController.text.isEmpty) {
              filteredConversations.addAll(newConversations);
            } else {
              searchChats(searchController.text);
            }
          } else {
            conversations.value = newConversations;
            filteredConversations.value = newConversations;
            chatTotalPage = meta?.totalPage ?? 1;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching conversations: $e");
    } finally {
      isLoading.value = false;
      isMoreChatLoading.value = false;
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      filteredConversations.value = conversations;
    }
  }

  void searchChats(String query) {
    if (query.isEmpty) {
      filteredConversations.value = conversations;
    } else {
      filteredConversations.value = conversations.where((chat) {
        String name = chat.chat == 'groupchat'
            ? (chat.groupname ?? "Group")
            : (chat.participants?.isNotEmpty == true
                  ? chat.participants!.first.name ?? "Unknown"
                  : "Unknown");
        return name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void openChat(AllConversations chat) {
    String name = chat.chat == 'groupchat'
        ? (chat.groupname ?? "Group Chat")
        : (chat.participants?.isNotEmpty == true
              ? chat.participants!.first.name ?? "Unknown"
              : "Unknown");

    // Determine Avatar
    String avatar = "";
    if (chat.chat == 'singlechat' &&
        chat.participants != null &&
        chat.participants!.isNotEmpty) {
      avatar = chat.participants!.first.photo ?? "";
    }

    debugPrint('✅ Opening chat: $name');
    Get.to(
      ChatDetailScreen(
        recipientId: chat.participants?.isNotEmpty == true
            ? chat.participants!.first.sId ?? ""
            : "",
        recipientName: name,
        recipientAvatar: avatar.isNotEmpty
            ? avatar
            : 'https://i.pravatar.cc/150?u=${name}',
        conversationId: chat.sId,
        chatType: chat.chat ?? 'singlechat',
      ),
    )?.then((_) => fetchConversations());
  }

  Future<void> refreshChats() async {
    await fetchConversations();
    await fetchAllUsers();
  }

  Future<void> fetchAllUsers({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isMoreUsersLoading.value = true;
    } else {
      isUsersLoading.value = true;
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
            allUsers.addAll(newUsers);
            currentPage++;
          } else {
            allUsers.value = newUsers;
            totalPage = meta?.totalPage ?? 1;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      isUsersLoading.value = false;
      isMoreUsersLoading.value = false;
    }
  }

  void openChatWithUser(AllUser user) {
    if (user.sId == null) return;

    debugPrint('🔎 Finding existing chat for user: ${user.name}');

    AllConversations? existingChat;
    for (var chat in conversations) {
      if (chat.chat == 'singlechat' &&
          chat.participants != null &&
          chat.participants!.any((p) => p.sId == user.sId)) {
        existingChat = chat;
        break;
      }
    }

    if (existingChat != null) {
      debugPrint('✅ Found existing chat');
      openChat(existingChat);
    } else {
      debugPrint('🆕 No existing chat, opening new');
      Get.to(
        () => ChatDetailScreen(
          recipientId: user.sId!,
          recipientName: user.name ?? "Unknown",
          recipientAvatar: user.photo ?? "",
          conversationId: "", // Empty ID for new chat
        ),
      )?.then((_) => fetchConversations());
    }
  }
}
