import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signa_video_to_text/features/config/helper/format_duration.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';

class SemifullscreenVideoWidget extends StatefulWidget {
  final String videoPath;
  const SemifullscreenVideoWidget({super.key, required this.videoPath});

  @override
  State<SemifullscreenVideoWidget> createState() =>
      _SemifullscreenVideoWidgetState();
}

class _SemifullscreenVideoWidgetState extends State<SemifullscreenVideoWidget> {
  late final Player _player;
  late final VideoController _controller;
  bool _isPortrait = true;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _player.open(Media(widget.videoPath), play: true);

    _player.stream.videoParams.listen((params) {
      if (params.w != null && params.h != null && mounted) {
        setState(() {
          _isPortrait = params.h! >= params.w!;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double dialogWidth = _isPortrait
        ? screenWidth * 0.78
        : screenWidth * 0.92;
    final double dialogHeight = _isPortrait
        ? screenHeight * 0.62
        : screenWidth * 0.92 * (9 / 16);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: Stack(
                children: [
                  Video(controller: _controller, fit: BoxFit.cover),
                  if (_isPortrait)
                    Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.2,
                          colors: [
                            Colors.transparent,
                            WarnaApp.wrTextBlack.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            WarnaApp.wrTextBlack.withValues(alpha: 0.45),
                            Colors.transparent,
                            Colors.transparent,
                            WarnaApp.wrTextBlack.withValues(alpha: 0.45),
                          ],
                          stops: const [0.0, 0.2, 0.8, 1.0],
                        ),
                      ),
                    ),
                  StreamBuilder<bool>(
                    stream: _player.stream.playing,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? false;
                      return Stack(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () => _player.playOrPause(),
                              child: AnimatedOpacity(
                                opacity: isPlaying ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.play_circle_outline_rounded,
                                  size: 64,
                                  color: WarnaApp.wrWhite.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (isPlaying)
                            GestureDetector(
                              onTap: () => _player.playOrPause(),
                              child: Container(color: Colors.transparent),
                            ),
                        ],
                      );
                    },
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: WarnaApp.wrTextBlack.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: WarnaApp.wrWhite,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: StreamBuilder<Duration>(
                      stream: _player.stream.duration,
                      builder: (context, durSnapshot) {
                        final duration = durSnapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration>(
                          stream: _player.stream.position,
                          builder: (context, posSnapshot) {
                            final position = posSnapshot.data ?? Duration.zero;
                            final progress = duration.inMilliseconds > 0
                                ? (position.inMilliseconds /
                                      duration.inMilliseconds).clamp(0.0, 1.0)
                                : 0.0;

                            return Container(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    WarnaApp.wrTextBlack.withValues(alpha: 0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape: RoundSliderOverlayShape(
                                        overlayRadius: 12,
                                      ),
                                      trackHeight: 2.5,
                                      activeTrackColor: WarnaApp.wrWhite,
                                      inactiveTrackColor: WarnaApp.wrWhite.withValues(alpha: 0.3),
                                      thumbColor: WarnaApp.wrWhite,
                                      overlayColor: WarnaApp.wrWhite.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                    child: Slider(
                                      value: progress,
                                      onChanged: duration.inMilliseconds > 0 ? (val) {
                                        _player.seek(Duration(
                                          milliseconds: (val * duration.inMilliseconds).toInt()
                                        ));
                                      } : null,
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatDuration(position),
                                          style: TextStyle(
                                            color: WarnaApp.wrWhite.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          formatDuration(duration),
                                          style: TextStyle(
                                            color: WarnaApp.wrWhite.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
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
}
