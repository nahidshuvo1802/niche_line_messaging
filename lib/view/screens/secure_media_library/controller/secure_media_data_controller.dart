import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/service/api_client.dart';
import 'package:niche_line_messaging/service/api_url.dart';

class SecureMediaDataController extends GetxController {
  final RxList<dynamic> allMedia = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isMoreLoading = false.obs;
  int page = 1;
  final int limit = 15;
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchSecureData();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isMoreLoading.value) {
        fetchSecureData(isLoadMore: true);
      }
    }
  }

  Future<void> fetchSecureData({bool isLoadMore = false}) async {
    try {
      if (isLoadMore) {
        isMoreLoading.value = true;
        page++;
      } else {
        isLoading.value = true;
        page = 1;
      }

      final url = "${ApiUrl.findByMySecureData}?page=$page&limit=$limit";
      // Assuming the API supports ?page=&limit= based on USER_REQUEST "pagination handle koiro valo kore"
      // If the API strictly takes no params, I will remove them, but standard practice for pagination implies params.
      // User said "eikhne kono filtering use koirona just all the data show korba" - this likely refers to not filtering by type on client side if possible, or maybe server.
      // But pagination is requested.

      final response = await ApiClient.getData(url);

      if (response.statusCode == 200) {
        final body = response.body;
        if (body['success'] == true && body['data'] != null) {
          final List newData = body['data'];
          // Assuming standard pagination response, adjust if 'data' is nested in 'result' etc.
          // If it's just a list directly under data.

          if (isLoadMore) {
            allMedia.addAll(newData);
          } else {
            allMedia.assignAll(newData);
          }
        } else {
          if (!isLoadMore) allMedia.clear();
        }
      } else {
        // Handle error
        debugPrint("Error fetching data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error secure media: $e");
    } finally {
      if (isLoadMore) {
        isMoreLoading.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
