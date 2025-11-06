// ==================== Controller ====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_model.dart';
import 'package:niche_line_messaging/view/screens/home/views/chat_screen_one.dart';

class ChatListController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isSearching = false.obs;
  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxList<ChatModel> filteredChats = <ChatModel>[].obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchChats() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));

    chats.value = [
      ChatModel(
        id: '1',
        name: 'Alex Johnson',
        lastMessage:
            'Hey! Are we still meeting for coffee tomorrow? I found this great new place downtown...',
        timestamp: '2:34 PM',
        avatar: 'https://i.pravatar.cc/150?img=1',
        unreadCount: 3,
        isOnline: true,
      ),
      ChatModel(
        id: '2',
        name: 'Design Team',
        lastMessage:
            'Mike: The new mockups look fantastic! Can we schedule a review?',
        timestamp: 'Yesterday',
        avatar: '',
        unreadCount: 7,
        isGroup: true,
      ),
      ChatModel(
        id: '3',
        name: 'Emma Wilson',
        lastMessage: 'Looking forward to our collaboration!',
        timestamp: 'Sunday',
        avatar: 'https://i.pravatar.cc/150?img=64',
        isOnline: true,
      ),
        ChatModel(
        id: '4',
        name: 'MH Rakib',
        lastMessage: 'Looking for ja Iccha tai!',
        timestamp: 'Friday',
        avatar: 'https://i.pravatar.cc/150?img=56',
        isOnline: true,
      ),
        ChatModel(
        id: '5',
        name: 'AR Raihan',
        lastMessage: 'Looking for Vacation!',
        timestamp: 'Friday',
        avatar: 'https://i.pravatar.cc/150?img=44',
        isOnline: true,
      ),
        ChatModel(
        id: '6',
        name: 'Hasan Saon',
        lastMessage: 'Looking for Clients!',
        timestamp: 'Sunday',
        avatar: 'https://i.pravatar.cc/150?img=14',
        isOnline: true,
      ),
        ChatModel(
        id: '7',
        name: 'Nahid Khan Shuvo',
        lastMessage: 'We are depressed Developers!',
        timestamp: 'Wednesday',
        avatar: 'https://i.pravatar.cc/150?img=6',
        isOnline: true,
      ),
        ChatModel(
        id: '8',
        name: 'Sohel Rana',
        lastMessage: 'Maldare Taratari koren!',
        timestamp: 'Thrusday',
        avatar: 'https://i.pravatar.cc/150?img=40',
        isOnline: true,
      ),
        ChatModel(
        id: '9',
        name: 'Raju Ahmed',
        lastMessage: 'Looking forward to our API!',
        timestamp: 'Tuesday',
        avatar: 'https://i.pravatar.cc/150?img=48',
        isOnline: true,
      ),
        ChatModel(
        id: '10',
        name: 'Sadikul Hasan Uthso',
        lastMessage: 'Looking forward to our Team for Design!',
        timestamp: 'Saturday',
        avatar: 'https://i.pravatar.cc/150?img=46',
        isOnline: true,
      ),
          ChatModel(
        id: '11',
        name: 'Aman patwary',
        lastMessage: 'Looking for Dashboard!',
        timestamp: 'Sunday',
        avatar: 'https://i.pravatar.cc/150?img=26',
        isOnline: true,
      ),
          ChatModel(
        id: '11',
        name: 'Mehedi Leader Vai',
        lastMessage: 'Looking for Delivery!',
        timestamp: 'Friday',
        avatar: 'https://i.pravatar.cc/150?img=53',
        isOnline: false,
      ),
       ChatModel(
        id: '12',
        name: 'Moshiur Rahman Mahdi',
        lastMessage: 'Looking for New Project!',
        timestamp: 'Monday',
        avatar: 'https://i.pravatar.cc/150?img=23',
        isOnline: false,
      ),
    ];

    filteredChats.value = chats;
    isLoading.value = false;
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      filteredChats.value = chats;
    }
  }

  void searchChats(String query) {
    if (query.isEmpty) {
      filteredChats.value = chats;
    } else {
      filteredChats.value = chats
          .where((chat) =>
              chat.name.toLowerCase().contains(query.toLowerCase()) ||
              chat.lastMessage.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void openChat(ChatModel chat) {
    debugPrint('✅ Opening chat: ${chat.name}');
    Get.snackbar(
      'Chat Opened',
      'Opening conversation with ${chat.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2DD4BF),
      colorText: AppColors.primary,
      duration: const Duration(seconds: 2),
    );
    Get.to(ChatDetailScreen(recipientId: '2', recipientName: "Emma Wilson", recipientAvatar:'https://i.pravatar.cc/150?img=53' ));
  }

  Future<void> refreshChats() async => fetchChats();
}