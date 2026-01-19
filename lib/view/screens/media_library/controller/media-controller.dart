// ==================== CONTROLLER ====================
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/view/screens/home/model/chat_message_model.dart';
import 'package:niche_line_messaging/view/screens/media_library/model/media-model.dart';

class MediaGalleryController extends GetxController {
  // Current tab index (0 = Photos, 1 = Videos, 2 = Docs)
  final RxInt currentTab = 0.obs;

  // Loading states
  final RxBool isLoadingPhotos = true.obs;
  final RxBool isLoadingVideos = false.obs;
  final RxBool isLoadingDocs = false.obs;

  // Media lists
  final RxList<MediaItem> photos = <MediaItem>[].obs;
  final RxList<MediaItem> videos = <MediaItem>[].obs;
  final RxList<MediaItem> docs = <MediaItem>[].obs;

  // Chat ID from navigation
  String chatId = '';

  @override
  void onInit() {
    super.onInit();
    chatId = Get.arguments?['chatId'] ?? '';
    fetchAllMedia();
  }

  // ==================== Fetch All Media ====================
  Future<void> fetchAllMedia() async {
    if (chatId.isEmpty) return;

    isLoadingPhotos.value = true;
    isLoadingVideos.value = true;
    isLoadingDocs.value = true;

    try {
      debugPrint("🚀 Fetching media for chat: $chatId");
      final response = await ApiClient.getData(
        ApiUrl.getMessagesByConversation(chatId),
      );

      if (response.statusCode == 200) {
        final apiResponse = MessageResponse.fromJson(response.body);

        if (apiResponse.success == true &&
            apiResponse.data?.allmessage != null) {
          final allMessages = apiResponse.data!.allmessage!;

          final List<MediaItem> allPhotos = [];
          final List<MediaItem> allVideos = [];
          final List<MediaItem> allDocs = [];

          for (var msg in allMessages) {
            // Check for Attachments in imageUrl list
            if (msg.imageUrl != null && msg.imageUrl!.isNotEmpty) {
              for (var urlDynamic in msg.imageUrl!) {
                String url = urlDynamic.toString();
                // Handle potential query parameters
                String cleanUrl = url.split('?').first;
                String ext = cleanUrl.split('.').last.toLowerCase();
                String fullUrl = ApiUrl.getImageUrl(url);

                if (_isPhoto(ext)) {
                  allPhotos.add(
                    MediaItem(
                      id:
                          msg.sId ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      url: fullUrl,
                      type: 'photo',
                      uploadedAt: _parseDate(msg.createdAt),
                    ),
                  );
                } else if (_isVideo(ext)) {
                  allVideos.add(
                    MediaItem(
                      id:
                          msg.sId ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      url: fullUrl,
                      type: 'video',
                      thumbnail: null, // Could generate or use placeholder
                      uploadedAt: _parseDate(msg.createdAt),
                    ),
                  );
                } else if (_isDoc(ext)) {
                  allDocs.add(
                    MediaItem(
                      id:
                          msg.sId ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      url: fullUrl,
                      type: 'doc',
                      fileName: url
                          .split('/')
                          .last, // Simple file name extraction
                      fileSize: 'Unknown', // API doesn't seem to give size
                      uploadedAt: _parseDate(msg.createdAt),
                    ),
                  );
                }
              }
            }
          }

          photos.value = allPhotos;
          videos.value = allVideos;
          docs.value = allDocs;
        }
      } else {
        debugPrint("❌ Failed to fetch messages: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('❌ Fetch All Media Error: $e');
    } finally {
      isLoadingPhotos.value = false;
      isLoadingVideos.value = false;
      isLoadingDocs.value = false;
    }
  }

  bool _isPhoto(String ext) {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  bool _isVideo(String ext) {
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', 'wmv'].contains(ext);
  }

  bool _isDoc(String ext) {
    return [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
    ].contains(ext);
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  // ==================== Switch Tab ====================
  void switchTab(int index) {
    currentTab.value = index;
    // We fetch all at init, so no need to fetch individually here usually.
    // Unless we want to refresh? For now, keep it simple.
  }

  // ==================== Download Document ====================
  Future<void> downloadDocument(MediaItem doc) async {
    try {
      Get.snackbar(
        'Downloading',
        '${doc.fileName} is being downloaded...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2DD4BF),
        colorText: AppColors.white,
      );

      // TODO: Implement actual download logic
      // await FlutterDownloader.enqueue(
      //   url: doc.url,
      //   savedDir: '/storage/emulated/0/Download',
      //   fileName: doc.fileName,
      // );

      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Success',
        '${doc.fileName} downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.green,
        colorText: AppColors.white,
      );

      debugPrint('✅ Downloaded: ${doc.fileName}');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download file',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      debugPrint('❌ Download Error: $e');
    }
  }
}

class Colors {}
