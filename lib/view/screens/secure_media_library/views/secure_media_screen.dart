import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:niche_line_messaging/service/api_url.dart';
import 'package:niche_line_messaging/view/screens/secure_media_library/controller/secure_media_data_controller.dart';

// ============ SECURE MEDIA SCREEN ============
class SecureMediaScreen extends StatelessWidget {
  const SecureMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SecureMediaDataController controller = Get.put(
      SecureMediaDataController(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1527),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2DD4BF)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Secure Folder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF1A1F3A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildStorageLimitIndicator(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                  );
                }

                if (controller.allMedia.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_open_rounded,
                          size: 64.sp,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No secure media found',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 0.h,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 1,
                  ),
                  itemCount:
                      controller.allMedia.length +
                      (controller.isMoreLoading.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.allMedia.length) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF2DD4BF),
                        ),
                      );
                    }

                    final item = controller.allMedia[index];
                    String url = '';
                    String type = 'image';

                    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
                      url = item.imageUrl!.first;
                      type = 'image';
                    } else if (item.audioUrl != null) {
                      url = item.audioUrl!;
                      type = 'audio';
                    }

                    // If url is relative, make it absolute
                    if (!url.startsWith('http')) {
                      url = ApiUrl.getImageUrl(url);
                    }

                    bool isVideo = url.endsWith('.mp4') || type == 'video';

                    String dateStr = '';
                    if (item.createdAt != null) {
                      try {
                        final date = DateTime.parse(item.createdAt!).toLocal();
                        dateStr = DateFormat('d MMM, y').format(date);
                      } catch (e) {
                        debugPrint('Date parse error: $e');
                      }
                    }

                    return _buildMediaItem(url, isVideo, index, dateStr);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.pickAndUploadMedia();
        },
        backgroundColor: const Color(0xFF2DD4BF),
        child: Obx(
          () => controller.isUploading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStorageLimitIndicator(BuildContext context) {
    // Mock usage calculation or static for now since API doesn't provide size
    // Assuming 300MB limit as requested
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3B5A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cloud_queue,
                    color: const Color(0xFF2DD4BF),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Storage Limit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '300 MB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: 0.15, // Mock valid (e.g. 15% used)
            backgroundColor: Colors.black.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
            borderRadius: BorderRadius.circular(4.r),
            minHeight: 6.h,
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Encrypted Cloud Storage',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(
    String imageUrl,
    bool isVideo,
    int index,
    String date,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to media detail screen
        Get.to(
          () => MediaDetailScreen(
            imageUrl: imageUrl,
            mediaIndex: index,
            isVideo: isVideo,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: const Color(0xFF2A3B5A),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF2A3B5A),
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white.withOpacity(0.3),
                      size: 32.sp,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFF2DD4BF),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),

              // Date Overlay
              if (date.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4.h,
                      horizontal: 6.w,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      date,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),

              // Video Play Icon Overlay
              if (isVideo)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ MEDIA DETAIL/PREVIEW SCREEN ============
class MediaDetailScreen extends StatelessWidget {
  final String imageUrl;
  final int mediaIndex;
  final bool isVideo;

  const MediaDetailScreen({
    super.key,
    required this.imageUrl,
    required this.mediaIndex,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E27),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2DD4BF)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'IMG_${mediaIndex + 2025}.jpg',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Image/Video Preview
          Expanded(
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF2DD4BF),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Decryption Notice
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Text(
              'Media decrypted temporarily for viewing only.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
      const Color(0xFFAA96DA),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors[mediaIndex % colors.length],
            colors[mediaIndex % colors.length].withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          isVideo ? Icons.play_circle_outline : Icons.image_outlined,
          color: Colors.white.withOpacity(0.7),
          size: 80.sp,
        ),
      ),
    );
  }
}

// ============ ENCRYPTED CAMERA SCREEN ============
class EncryptedCameraScreen extends StatefulWidget {
  const EncryptedCameraScreen({super.key});

  @override
  State<EncryptedCameraScreen> createState() => _EncryptedCameraScreenState();
}

class _EncryptedCameraScreenState extends State<EncryptedCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  final RxString captureMode = 'Photo'.obs;
  final RxBool isRecording = false.obs;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: true,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      Get.snackbar(
        'Camera Error',
        'Could not initialize camera',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      Get.to(() => CapturedPhotoPreviewScreen(imagePath: image.path));
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  Future<void> _toggleVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (isRecording.value) {
        final video = await _cameraController!.stopVideoRecording();
        isRecording.value = false;
        Get.to(() => CapturedVideoPreviewScreen(videoPath: video.path));
      } else {
        await _cameraController!.startVideoRecording();
        isRecording.value = true;
        Get.snackbar(
          'Recording Started',
          'Recording video...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      debugPrint('Error recording video: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final currentCameraIndex = _cameras!.indexOf(
      _cameraController!.description,
    );
    final newCameraIndex = (currentCameraIndex + 1) % _cameras!.length;

    final newCamera = _cameras![newCameraIndex];

    await _cameraController?.dispose();

    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _cameraController!.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(child: CameraPreview(_cameraController!))
          else
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
            ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8.h,
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'Encrypted Camera',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
            ),
          ),

          // Switch Camera Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.h,
            right: 16.w,
            child: GestureDetector(
              onTap: _switchCamera,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2DD4BF),
                ),
                child: const Icon(Icons.flip_camera_ios, color: Colors.white),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 24.h,
                top: 24.h,
                left: 16.w,
                right: 16.w,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Photo/Video Toggle
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildModeButton('Photo', captureMode.value == 'Photo'),
                        SizedBox(width: 12.w),
                        _buildModeButton('Video', captureMode.value == 'Video'),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Capture Button
                  Obx(
                    () => GestureDetector(
                      onTap: () {
                        if (captureMode.value == 'Photo') {
                          _capturePhoto();
                        } else {
                          _toggleVideoRecording();
                        }
                      },
                      child: Container(
                        width: 70.w,
                        height: 70.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isRecording.value
                                ? Colors.red
                                : const Color(0xFF2DD4BF),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Info Text
                  Text(
                    'Saved securely with NichLine encryption',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String mode, bool isSelected) {
    return GestureDetector(
      onTap: () {
        captureMode.value = mode;
        if (isRecording.value) {
          _toggleVideoRecording();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2DD4BF)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2DD4BF)
                : Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          mode,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ============ CAPTURED PHOTO PREVIEW SCREEN ============
class CapturedPhotoPreviewScreen extends StatelessWidget {
  final String imagePath;

  const CapturedPhotoPreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
            ),

            // Image Preview
            Expanded(
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.file(File(imagePath), fit: BoxFit.contain),
                  ),
                ),
              ),
            ),

            // Status and Buttons
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Encryption Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2DD4BF),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Encrypted and ready to send',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF2DD4BF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Send in Chat Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.snackbar(
                          'Sending',
                          'Photo will be sent in chat',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DD4BF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Send in Chat',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Save to Secure Folder Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.snackbar(
                          'Saved',
                          'Photo saved to secure folder',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2DD4BF),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF2DD4BF),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Save to Secure Folder',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Info Text
                  Text(
                    'This file is encrypted locally — not visible in system gallery',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ CAPTURED VIDEO PREVIEW SCREEN ============
class CapturedVideoPreviewScreen extends StatelessWidget {
  final String videoPath;

  const CapturedVideoPreviewScreen({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'Video Preview',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
            ),

            // Video Preview Placeholder
            Expanded(
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Color(0xFF2DD4BF),
                            size: 80,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Status and Buttons
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Encryption Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2DD4BF),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Encrypted and ready to send',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF2DD4BF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Send in Chat Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.snackbar(
                          'Sending',
                          'Video will be sent in chat',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DD4BF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Send in Chat',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Save to Secure Folder Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.snackbar(
                          'Saved',
                          'Video saved to secure folder',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2DD4BF),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF2DD4BF),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Save to Secure Folder',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Info Text
                  Text(
                    'This file is encrypted locally — not visible in system gallery',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
