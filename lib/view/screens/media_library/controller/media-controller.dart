// ==================== CONTROLLER ====================
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
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
    fetchPhotos();
  }

  // ==================== Switch Tab ====================
  void switchTab(int index) {
    currentTab.value = index;
    
    if (index == 0 && photos.isEmpty) {
      fetchPhotos();
    } else if (index == 1 && videos.isEmpty) {
      fetchVideos();
    } else if (index == 2 && docs.isEmpty) {
      fetchDocs();
    }
  }

  // ==================== Fetch Photos ====================
  Future<void> fetchPhotos() async {
    isLoadingPhotos.value = true;

    try {
      // TODO: Replace with your actual API call
      // final response = await ApiClient.getData(ApiUrl.getChatMedia(chatId: chatId, type: 'photo'));
      // photos.value = (response.body['data'] as List).map((e) => MediaItem.fromJson(e)).toList();

      await Future.delayed(const Duration(seconds: 1));

      // Dummy photos
      photos.value = [
        MediaItem(id: '1', url: 'https://picsum.photos/300/200?random=1', type: 'photo', uploadedAt: DateTime.now()),
        MediaItem(id: '2', url: 'https://picsum.photos/300/200?random=2', type: 'photo', uploadedAt: DateTime.now()),
        MediaItem(id: '3', url: 'https://picsum.photos/300/200?random=3', type: 'photo', uploadedAt: DateTime.now()),
        MediaItem(id: '4', url: 'https://picsum.photos/300/200?random=4', type: 'photo', uploadedAt: DateTime.now()),
        MediaItem(id: '5', url: 'https://picsum.photos/300/200?random=5', type: 'photo', uploadedAt: DateTime.now()),
        MediaItem(id: '6', url: 'https://picsum.photos/300/200?random=6', type: 'photo', uploadedAt: DateTime.now()),
        MediaItem(id: '7', url: 'https://picsum.photos/300/200?random=7', type: 'photo', uploadedAt: DateTime.now()),
        MediaItem(id: '8', url: 'https://picsum.photos/300/200?random=8', type: 'photo', uploadedAt: DateTime.now()),
        MediaItem(id: '9', url: 'https://picsum.photos/300/200?random=9', type: 'photo', uploadedAt: DateTime.now()),
        MediaItem(id: '10', url: 'https://picsum.photos/300/200?random=10', type: 'photo', uploadedAt: DateTime.now()),
        MediaItem(id: '11', url: 'https://picsum.photos/300/200?random=11', type: 'photo', uploadedAt: DateTime.now()),
        MediaItem(id: '12', url: 'https://picsum.photos/300/200?random=12', type: 'photo', uploadedAt: DateTime.now()),
      ];

      isLoadingPhotos.value = false;
    } catch (e) {
      isLoadingPhotos.value = false;
      debugPrint('❌ Fetch Photos Error: $e');
    }
  }

  // ==================== Fetch Videos ====================
  Future<void> fetchVideos() async {
    isLoadingVideos.value = true;

    try {
      // TODO: Replace with your actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Dummy videos
      videos.value = [
        MediaItem(
          id: 'v1',
          url: 'video_url_1.mp4',
          type: 'video',
          thumbnail: 'https://picsum.photos/300/200?random=20',
          uploadedAt: DateTime.now(),
        ),
        MediaItem(
          id: 'v2',
          url: 'video_url_2.mp4',
          type: 'video',
          thumbnail: 'https://picsum.photos/300/200?random=21',
          uploadedAt: DateTime.now(),
        ),
        MediaItem(
          id: 'v3',
          url: 'video_url_3.mp4',
          type: 'video',
          thumbnail: 'https://picsum.photos/300/200?random=22',
          uploadedAt: DateTime.now(),
        ),
      ];

      isLoadingVideos.value = false;
    } catch (e) {
      isLoadingVideos.value = false;
      debugPrint('❌ Fetch Videos Error: $e');
    }
  }

  // ==================== Fetch Docs ====================
  Future<void> fetchDocs() async {
    isLoadingDocs.value = true;

    try {
      // TODO: Replace with your actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Dummy documents
      docs.value = [
        MediaItem(
          id: 'd1',
          url: 'https://example.com/doc1.pdf',
          type: 'doc',
          fileName: 'Project_Proposal.pdf',
          fileSize: '2.5 MB',
          uploadedAt: DateTime.now(),
        ),
        MediaItem(
          id: 'd2',
          url: 'https://example.com/doc2.docx',
          type: 'doc',
          fileName: 'Meeting_Notes.docx',
          fileSize: '1.2 MB',
          uploadedAt: DateTime.now(),
        ),
        MediaItem(
          id: 'd3',
          url: 'https://example.com/doc3.xlsx',
          type: 'doc',
          fileName: 'Budget_2024.xlsx',
          fileSize: '800 KB',
          uploadedAt: DateTime.now(),
        ),
      ];

      isLoadingDocs.value = false;
    } catch (e) {
      isLoadingDocs.value = false;
      debugPrint('❌ Fetch Docs Error: $e');
    }
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
        colorText: AppColors.white
      );
      debugPrint('❌ Download Error: $e');
    }
  }
}

class Colors {
}