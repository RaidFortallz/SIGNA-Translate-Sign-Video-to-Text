import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbanilWidget extends StatefulWidget {
  final String videoPath;
  final double width;
  final double height;
  const VideoThumbanilWidget({
    super.key,
    required this.videoPath,
    required this.width,
    required this.height,
  });

  @override
  State<VideoThumbanilWidget> createState() => _VideoThumbanilWidgetState();
}

class _VideoThumbanilWidgetState extends State<VideoThumbanilWidget> {
  Uint8List? _thumbnaill;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    if (!File(widget.videoPath).existsSync()) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final thumbnail = await VideoThumbnail.thumbnailData(
      video: widget.videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: widget.width.toInt(),
      quality: 75,
    );

    if (mounted) {
      setState(() {
        _thumbnaill = thumbnail;
        _loading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: WarnaApp.wrGrey
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white54,
            ),
          ),
        ),
      );
    }

    if (_thumbnaill == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: WarnaApp.wrGrey
        ),
        child: Icon(Icons.videocam_off, color: Colors.white54, size: 28,),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(10),
      child: Stack(
        children: [
          Image.memory(
            _thumbnaill!,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
          ),

          Positioned.fill(child: Container(
            decoration: BoxDecoration(
              color: WarnaApp.wrTextBlack.withValues(alpha: 0.25),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_outline_outlined,
                size: 32,
                color: WarnaApp.wrWhite.withValues(alpha: 0.9),
              ),
            ),
          ))
        ],
      ),
    );
    
  }
}
