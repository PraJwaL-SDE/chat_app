import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/message_model.dart';

class FullScreenMediaView extends StatefulWidget {
  final String url;
  final MessageType type;

  const FullScreenMediaView({
    super.key,
    required this.url,
    required this.type,
  });

  @override
  State<FullScreenMediaView> createState() => _FullScreenMediaViewState();
}

class _FullScreenMediaViewState extends State<FullScreenMediaView> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.type == MessageType.video) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
          });
          _videoController.play();
        });
    }
  }

  @override
  void dispose() {
    if (widget.type == MessageType.video) {
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              // Implement download functionality if needed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download started...')),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: widget.type == MessageType.image
            ? InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: widget.url,
                  child: CachedNetworkImage(
                    imageUrl: widget.url,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : _isInitialized
                ? Hero(
                    tag: widget.url,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: VideoPlayer(_videoController),
                        ),
                        _ControlsOverlay(controller: _videoController),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoProgressIndicator(
                            _videoController,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.red,
                              bufferedColor: Colors.white24,
                              backgroundColor: Colors.white10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showControls
            ? Container(
                color: Colors.black38,
                child: Center(
                  child: IconButton(
                    iconSize: 64,
                    icon: Icon(
                      widget.controller.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        widget.controller.value.isPlaying
                            ? widget.controller.pause()
                            : widget.controller.play();
                      });
                    },
                  ),
                ),
              )
            : const SizedBox.expand(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.transparent),
                ),
              ),
      ),
    );
  }
}
