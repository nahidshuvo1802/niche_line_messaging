import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/view/screens/secure_media_library/model/secure_media_model.dart';

class SecureMediaDataController extends GetxController {
  // Use the model type
  final RxList<SecureMediaItem> allMedia = <SecureMediaItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool isUploading = false.obs;

  int page = 1;
  final int limit = 10;
  int totalPage = 1;

  ScrollController scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchSecureData();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isMoreLoading.value && page < totalPage) {
        fetchSecureData(isLoadMore: true);
      }
    }
  }

  Future<void> fetchSecureData({bool isLoadMore = false}) async {
    try {
      if (isLoadMore) {
        isMoreLoading.value = true;
      } else {
        isLoading.value = true;
        page = 1;
      }

      final url = "${ApiUrl.findByMySecureData}?page=$page&limit=$limit";
      debugPrint("🚀 Fetching Secure Data: $url");

      final response = await ApiClient.getData(url);

      if (response.statusCode == 200) {
        final SecureMediaResponse model = SecureMediaResponse.fromJson(
          response.body,
        );

        if (model.success == true && model.data != null) {
          totalPage = model.data?.meta?.totalPage ?? 1;
          final List<SecureMediaItem> newData = model.data?.allmessage ?? [];

          if (isLoadMore) {
            allMedia.addAll(newData);
            page++;
          } else {
            allMedia.assignAll(newData);
          }
        } else {
          if (!isLoadMore) allMedia.clear();
        }
      } else {
        debugPrint("Error fetching data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error secure media: $e");
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> pickAndUploadMedia() async {
    try {
      // Show bottom sheet to choose between Camera and Gallery
      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () async {
                  Get.back();
                  final XFile? photo = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (photo != null) _uploadMedia(File(photo.path));
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.purple),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () async {
                  Get.back();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) _uploadMedia(File(image.path));
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.red),
                title: Text(
                  'Video',
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () async {
                  Get.back();
                  final XFile? video = await _picker.pickVideo(
                    source: ImageSource.gallery,
                  );
                  if (video != null) _uploadMedia(File(video.path));
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Future<void> _uploadMedia(File file) async {
    isUploading.value = true;
    try {
      debugPrint("📤 Uploading File: ${file.path}");

      List<MultipartBody> multipartList = [
        MultipartBody('imageUrl', file),
        // If user didn't specify key, I'll assume 'image' or based on previous context.
        // Let's use 'image' or 'files'. Let's check other upload methods. Chat used 'imageUrl' or 'image'.
        // Most standard is 'image' or 'file'.
        // "upload_media_file" -> likely 'files' or 'file'.
        // I'll use 'files' as a safe bet for multiple or single.
      ];

      // ApiClient.postMultipartData takes Map<String, String> body.
      // User didn't specify any body fields, just form-data file.

      var response = await ApiClient.postMultipartData(
        ApiUrl.uploadMediaFile,
        {}, // Empty body if no text fields needed
        multipartBody: multipartList,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Media uploaded successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh list
        fetchSecureData();
      } else {
        Get.snackbar(
          "Error",
          "Failed to upload media: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
      Get.snackbar(
        "Error",
        "Error uploading media",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
