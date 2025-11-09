import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ============ SECURE MEDIA SCREEN ============
class SecureMediaScreen extends StatelessWidget {
  SecureMediaScreen({super.key});

  final RxString selectedTab = 'Photos'.obs;

  // Demo image URLs
  final List<String> photos = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
    'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400',
    'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=400',
    'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=400',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400',
    'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=400',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
    'https://images.unsplash.com/photo-1542397284385-6010376c5337?w=400',
    'https://images.unsplash.com/photo-1495954484750-af469f2f9be5?w=400',
  ];

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF000000),
              Color(0xFF1A1F3A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 16.h),

            // Tab Selector
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(() => Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          'Photos',
                          selectedTab.value == 'Photos',
                          () => selectedTab.value = 'Photos',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTabButton(
                          'Videos',
                          selectedTab.value == 'Videos',
                          () => selectedTab.value = 'Videos',
                        ),
                      ),
                    ],
                  )),
            ),

            SizedBox(height: 16.h),

            // Media Grid
            Expanded(
              child: Obx(() {
                if (selectedTab.value == 'Photos') {
                  return _buildPhotoGrid();
                } else {
                  return _buildVideosGrid();
                }
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const EncryptedCameraScreen());
        },
        backgroundColor: const Color(0xFF2DD4BF),
        child: const Icon(
          Icons.add_a_photo,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2DD4BF)
              : const Color(0xFF2A3B5A).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2DD4BF)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return _buildMediaItem(photos[index], false, index);
      },
    );
  }

  Widget _buildVideosGrid() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64.sp,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No videos yet',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Videos you add will appear here',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(String imageUrl, bool isVideo, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to media detail screen
        Get.to(() => MediaDetailScreen(
              imageUrl: imageUrl,
              mediaIndex: index,
              isVideo: isVideo,
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: const Color(0xFF2A3B5A),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
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
                  return Container(
                    color: const Color(0xFF2A3B5A),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFF2DD4BF),
                      ),
                    ),
                  );
                },
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

          // Action Buttons
          Container(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Delete Button
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  color: const Color(0xFFFF6B6B),
                  onTap: () {
                    _showDeleteConfirmation(context);
                  },
                ),

                // Share Button
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: const Color(0xFF2DD4BF),
                  onTap: () {
                    Get.snackbar(
                      'Share',
                      'Opening share options...',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF2DD4BF),
                      colorText: Colors.white,
                    );
                  },
                ),

                // Save Button
                _buildActionButton(
                  icon: Icons.save_alt_outlined,
                  label: 'Save',
                  color: Colors.white,
                  onTap: () {
                    Get.snackbar(
                      'Saved',
                      'Media saved to gallery',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                ),
              ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                color: const Color(0xFFFF6B6B),
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'Delete Media?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'This media will be permanently deleted from secure folder.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.back(); // Go back to gallery
                        Get.snackbar(
                          'Deleted',
                          'Media deleted successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFFFF6B6B),
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

    final currentCameraIndex =
        _cameras!.indexOf(_cameraController!.description);
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
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2DD4BF),
              ),
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
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
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
                child: const Icon(
                  Icons.flip_camera_ios,
                  color: Colors.white,
                ),
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
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Photo/Video Toggle
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildModeButton(
                              'Photo', captureMode.value == 'Photo'),
                          SizedBox(width: 12.w),
                          _buildModeButton(
                              'Video', captureMode.value == 'Video'),
                        ],
                      )),

                  SizedBox(height: 32.h),

                  // Capture Button
                  Obx(() => GestureDetector(
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
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
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
                      )),

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

  const CapturedPhotoPreviewScreen({
    super.key,
    required this.imagePath,
  });

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
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
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

  const CapturedVideoPreviewScreen({
    super.key,
    required this.videoPath,
  });

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