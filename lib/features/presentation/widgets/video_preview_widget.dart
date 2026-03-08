import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewWidget extends StatefulWidget {
  final String videoPath;

  const VideoPreviewWidget({super.key, required this.videoPath});

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    final file = File(widget.videoPath);
    if (!file.existsSync()) {
      print("File video tidak ditemukan: ${widget.videoPath}");
      return;
    }

    _videoController =
        VideoPlayerController.file(
            file,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
          ..initialize()
              .then((_) {
                if (mounted) {
                  setState(() {
                    _isInitialized = true;
                  });
                }
              })
              .catchError((e) {
                print("Gagal init video: $e");
                if (mounted) setState(() => _isInitialized = false);
              });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!File(widget.videoPath).existsSync()) {
      return const Center(
        child: Icon(Icons.videocam_off, color: WarnaApp.wrGrey, size: 40),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: WarnaApp.wrWhite),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController.value.size.width,
              height: _videoController.value.size.height,
              child: VideoPlayer(_videoController),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _videoController.value.isPlaying
                  ? _videoController.pause()
                  : _videoController.play();
            });
          },
          icon: Icon(
            _videoController.value.isPlaying
                ? Icons.pause_circle_outline_outlined
                : Icons.play_circle_outline_rounded,
            size: 62,
            color: WarnaApp.wrWhite.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
