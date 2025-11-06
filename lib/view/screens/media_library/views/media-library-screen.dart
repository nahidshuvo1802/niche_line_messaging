import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:niche_line_messaging/utils/app_colors/app_colors.dart';
import 'package:niche_line_messaging/view/screens/media_library/controller/media-controller.dart' hide Colors;
import 'package:niche_line_messaging/view/screens/media_library/model/media-model.dart';



// ==================== UI SCREEN ====================
class MediaGalleryScreen extends StatelessWidget {
  const MediaGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MediaGalleryController());

    return Scaffold(
      backgroundColor: const Color(0xFF0E1527),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1527),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2DD4BF)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Media Gallery',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10.h),

          // ==================== Tab Buttons ====================
          Obx(() => Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    _buildTabButton(
                      title: 'Photos',
                      isActive: controller.currentTab.value == 0,
                      onTap: () => controller.switchTab(0),
                    ),
                    SizedBox(width: 12.w),
                    _buildTabButton(
                      title: 'Videos',
                      isActive: controller.currentTab.value == 1,
                      onTap: () => controller.switchTab(1),
                    ),
                    SizedBox(width: 12.w),
                    _buildTabButton(
                      title: 'Docs',
                      isActive: controller.currentTab.value == 2,
                      onTap: () => controller.switchTab(2),
                    ),
                  ],
                ),
              )),

          SizedBox(height: 20.h),

          // ==================== Content Area ====================
          Expanded(
            child: Obx(() {
              // Photos Tab
              if (controller.currentTab.value == 0) {
                if (controller.isLoadingPhotos.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                  );
                }
                return _buildPhotoGrid(controller.photos);
              }

              // Videos Tab
              if (controller.currentTab.value == 1) {
                if (controller.isLoadingVideos.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                  );
                }
                return _buildVideoGrid(controller.videos);
              }

              // Docs Tab
              if (controller.isLoadingDocs.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                );
              }
              return _buildDocsList(controller.docs, controller);
            }),
          ),
        ],
      ),
    );
  }

  // ==================== Tab Button ====================
  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2DD4BF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isActive ? const Color(0xFF2DD4BF) : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF0E1527) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Photo Grid ====================
  Widget _buildPhotoGrid(List<MediaItem> photos) {
    if (photos.isEmpty) {
      return Center(
        child: Text(
          'No photos available',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return GestureDetector(
          onTap: () {
            // TODO: Open full screen image viewer
            debugPrint('Photo clicked: ${photo.id}');
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              photo.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, color: Colors.white54),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2DD4BF),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ==================== Video Grid ====================
  Widget _buildVideoGrid(List<MediaItem> videos) {
    if (videos.isEmpty) {
      return Center(
        child: Text(
          'No videos available',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return GestureDetector(
          onTap: () {
            // TODO: Open video player
            debugPrint('Video clicked: ${video.id}');
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  video.thumbnail ?? 'https://picsum.photos/300/200',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image, color: Colors.white54),
                    );
                  },
                ),
                // Play icon overlay
                Center(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== Documents List ====================
  Widget _buildDocsList(List<MediaItem> docs, MediaGalleryController controller) {
    if (docs.isEmpty) {
      return Center(
        child: Text(
          'No documents available',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final extension = doc.fileName?.split('.').last.toUpperCase() ?? 'FILE';

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              // File icon
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DD4BF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  _getFileIcon(extension),
                  color: const Color(0xFF2DD4BF),
                  size: 28.sp,
                ),
              ),

              SizedBox(width: 16.w),

              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.fileName ?? 'Unknown File',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      doc.fileSize ?? 'Unknown size',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Download button
              IconButton(
                onPressed: () => controller.downloadDocument(doc),
                icon: const Icon(
                  Icons.download,
                  color: Color(0xFF2DD4BF),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== Get File Icon ====================
  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOC':
      case 'DOCX':
        return Icons.description;
      case 'XLS':
      case 'XLSX':
        return Icons.table_chart;
      case 'TXT':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}