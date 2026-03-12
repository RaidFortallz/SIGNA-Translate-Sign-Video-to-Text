import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/widgets/semifullscreen_video_widget.dart';

class VideoPreviewWidget extends StatefulWidget {
  final String videoPath;

  const VideoPreviewWidget({super.key, required this.videoPath});

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late final Player _player;
  late final VideoController _videoController;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    _player.open(Media(widget.videoPath), play: false);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _openSemiFullscreen() {
    _player.pause();

    showDialog(
      context: context,
      barrierColor: WarnaApp.wrTextBlack.withValues(alpha: 0.85),
      barrierDismissible: false,
      builder: (context) =>
          SemifullscreenVideoWidget(videoPath: widget.videoPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Video(controller: _videoController, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                WarnaApp.wrTextBlack.withValues(alpha: 0.25),
                Colors.transparent,
                Colors.transparent,
                WarnaApp.wrTextBlack.withValues(alpha: 0.25),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: _openSemiFullscreen,
          icon: Icon(
            Icons.play_circle_outline_rounded,
            size: 62,
            color: WarnaApp.wrWhite.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
