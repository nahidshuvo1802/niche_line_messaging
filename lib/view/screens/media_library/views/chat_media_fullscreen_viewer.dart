import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niche_line_messaging/core/app_navigation.dart';
import 'package:niche_line_messaging/view/screens/media_library/model/media-model.dart';
import 'package:video_player/video_player.dart';

enum ChatMediaPreviewKind { photo, video }

/// Full-screen photo gallery (swipe + pinch-zoom) or video playback for chat media.
class ChatMediaFullscreenViewer extends StatefulWidget {
  const ChatMediaFullscreenViewer({
    super.key,
    required this.kind,
    required this.items,
    this.initialIndex = 0,
  });

  final ChatMediaPreviewKind kind;
  final List<MediaItem> items;
  final int initialIndex;

  @override
  State<ChatMediaFullscreenViewer> createState() =>
      _ChatMediaFullscreenViewerState();
}

class _ChatMediaFullscreenViewerState extends State<ChatMediaFullscreenViewer> {
  late final PageController _pageController;
  int _currentPage = 0;

  VideoPlayerController? _videoController;
  bool _videoInitFailed = false;

  @override
  void initState() {
    super.initState();
    final maxIndex = widget.items.isEmpty ? 0 : widget.items.length - 1;
    final start = widget.initialIndex.clamp(0, maxIndex);
    _currentPage = start;
    _pageController = PageController(initialPage: start);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (widget.kind == ChatMediaPreviewKind.video && widget.items.isNotEmpty) {
      _initVideo(widget.items[start].url);
    }
  }

  Future<void> _initVideo(String url) async {
    _videoController?.dispose();
    _videoController = null;
    _videoInitFailed = false;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _videoController = controller;
      });
      await controller.play();
    } catch (_) {
      await controller.dispose();
      if (mounted) {
        setState(() {
          _videoInitFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => AppNav.back(),
          ),
        ),
        body: const Center(
          child: Text(
            'No media',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    if (widget.kind == ChatMediaPreviewKind.video) {
      return _buildVideoScaffold(context);
    }

    return _buildPhotoScaffold(context);
  }

  Widget _buildPhotoScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final url = widget.items[index].url;
              return ColoredBox(
                color: Colors.black,
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5,
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      width: MediaQuery.sizeOf(context).width,
                      placeholder: (context, _) => const SizedBox(
                        height: 120,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2DD4BF),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, _, __) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => AppNav.back(),
                  ),
                  if (widget.items.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentPage + 1} / ${widget.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoScaffold(BuildContext context) {
    final vc = _videoController;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: _videoInitFailed
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Could not load video',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : vc == null || !vc.value.isInitialized
                ? const CircularProgressIndicator(
                    color: Color(0xFF2DD4BF),
                  )
                : AspectRatio(
                    aspectRatio: vc.value.aspectRatio,
                    child: VideoPlayer(vc),
                  ),
          ),
          if (vc != null && vc.value.isInitialized)
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      vc.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 56,
                    ),
                    onPressed: () {
                      setState(() {
                        if (vc.value.isPlaying) {
                          vc.pause();
                        } else {
                          vc.play();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => AppNav.back(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
