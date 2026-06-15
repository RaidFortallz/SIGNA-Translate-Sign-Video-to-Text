import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/translation_controller.dart';

class TrimVideoController extends GetxController {
  late final Player player;
  late final VideoController videoController;

  var isPlaying        = false.obs;
  var isSaving         = false.obs;
  var duration         = Duration.zero.obs;
  var position         = Duration.zero.obs;

  // Multi-segment
  var segments         = <RangeValues>[const RangeValues(0.0, 1.0)].obs;
  var activeSegmentIdx = 0.obs;

  String _videoPath = '';

  RangeValues get activeSegment => segments[activeSegmentIdx.value];

  @override
  void onInit() {
    super.onInit();
    _videoPath = Get.arguments as String;
    player     = Player();
    videoController = VideoController(player);
    _loadVideo(_videoPath);
    _setupListeners();
  }

  void _loadVideo(String path) async {
    await player.open(Media('file://$path'), play: false);
  }

  void _setupListeners() {
    player.stream.duration.listen((d) => duration.value = d);
    player.stream.playing.listen((v) => isPlaying.value = v);

    player.stream.position.listen((pos) {
      position.value = pos;
      final int totalMs = duration.value.inMilliseconds;
      if (totalMs == 0) return;
      final int endMs = (activeSegment.end * totalMs).round();
      if (pos.inMilliseconds >= endMs && isPlaying.value) {
        player.pause();
        _seekToActiveStart();
      }
    });

    player.stream.completed.listen((done) {
      if (done) _seekToActiveStart();
    });
  }

  void _seekToActiveStart() {
    final int startMs =
        (activeSegment.start * duration.value.inMilliseconds).round();
    player.seek(Duration(milliseconds: startMs));
  }

  void togglePlay() {
    if (isPlaying.value) {
      player.pause();
    } else {
      final int posMs   = position.value.inMilliseconds;
      final int totalMs = duration.value.inMilliseconds;
      final int startMs = (activeSegment.start * totalMs).round();
      final int endMs   = (activeSegment.end   * totalMs).round();
      if (posMs < startMs || posMs >= endMs) _seekToActiveStart();
      player.play();
    }
  }

  // ── Segment management ─────────────────────────────────────────────────────

  void addSegment() {
    if (segments.length >= 10) {
      Get.snackbar('Batas Segmen', 'Maksimal 10 segmen.',
          backgroundColor: WarnaApp.wrRed.withValues(alpha: 0.9),
          colorText: WarnaApp.wrWhite,
          duration: const Duration(seconds: 2));
      return;
    }

    player.pause();

    final double lastEnd =
        segments.map((s) => s.end).reduce((a, b) => a > b ? a : b);

    if (lastEnd >= 0.94) {
      Get.snackbar('Tidak Ada Ruang', 'Tidak cukup ruang di akhir video.',
          backgroundColor: WarnaApp.wrRed.withValues(alpha: 0.9),
          colorText: WarnaApp.wrWhite,
          duration: const Duration(seconds: 2));
      return;
    }

    final double newStart = (lastEnd + 0.02).clamp(0.0, 0.94);
    final double newEnd   = (newStart + 0.15).clamp(newStart + 0.04, 1.0);

    segments.add(RangeValues(newStart, newEnd));
    activeSegmentIdx.value = segments.length - 1;

    final int ms = (newStart * duration.value.inMilliseconds).round();
    player.seek(Duration(milliseconds: ms));
  }

  void removeSegment(int idx) {
    if (segments.length <= 1) {
      Get.snackbar('Minimal 1 Segmen', 'Harus ada setidaknya satu segmen.',
          backgroundColor: WarnaApp.wrRed.withValues(alpha: 0.9),
          colorText: WarnaApp.wrWhite,
          duration: const Duration(seconds: 2));
      return;
    }

    segments.removeAt(idx);

    if (activeSegmentIdx.value >= segments.length) {
      activeSegmentIdx.value = segments.length - 1;
    }
    _seekToActiveStart();
  }

  void setActiveSegment(int idx) {
    if (idx < 0 || idx >= segments.length) return;
    player.pause();
    activeSegmentIdx.value = idx;
    _seekToActiveStart();
  }

  void updateActiveSegment(RangeValues values) {
    final List<RangeValues> updated = List<RangeValues>.from(segments);
    updated[activeSegmentIdx.value] = values;
    segments.assignAll(updated);
    final int ms = (values.start * duration.value.inMilliseconds).round();
    player.seek(Duration(milliseconds: ms));
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> saveAndTranslate() async {
    isSaving.value = true;
    player.pause();

    final transController = Get.find<TranslationController>();
    Get.offNamed(RouteNames.result);

    await transController.processSegments(
      _videoPath,
      List<RangeValues>.from(segments),
      duration.value.inMilliseconds,
    );

    isSaving.value = false;
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}