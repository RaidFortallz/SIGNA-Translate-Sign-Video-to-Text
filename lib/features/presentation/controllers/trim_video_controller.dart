import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/presentation/controllers/translation_controller.dart';
import 'package:media_kit/media_kit.dart';

class TrimVideoController extends GetxController {
  late final Player player;
  late final VideoController videoController;

  var isPlaying = false.obs;
  var isSaving = false.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var trimRange = const RangeValues(0.0, 1.0).obs;

  String _videoPath = '';

  @override
  void onInit() {
    super.onInit();
    _videoPath = Get.arguments as String;
    player = Player();
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

    // Auto stop & seek balik ke start saat posisi melewati end trim
    player.stream.position.listen((pos) {
      position.value = pos;
      final totalMs = duration.value.inMilliseconds;
      if (totalMs == 0) return;

      final endMs = (trimRange.value.end * totalMs).round();
      if (pos.inMilliseconds >= endMs && isPlaying.value) {
        player.pause();
        _seekToStart();
      }
    });
  }

  void _seekToStart() {
    final startMs = (trimRange.value.start * duration.value.inMilliseconds)
        .round();
    player.seek(Duration(milliseconds: startMs));
  }

  void togglePlay() {
    if (isPlaying.value) {
      player.pause();
    } else {
      _seekToStart();
      player.play();
    }
  }

  void updateTrimRange(RangeValues values) {
    trimRange.value = values;
    final startMs = (values.start * duration.value.inMilliseconds).round();
    player.seek(Duration(milliseconds: startMs));
  }

  // Format Duration jadi mm:ss
  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Duration get trimStart => Duration(
    milliseconds: (trimRange.value.start * duration.value.inMilliseconds)
        .round(),
  );

  Duration get trimEnd => Duration(
    milliseconds: (trimRange.value.end * duration.value.inMilliseconds).round(),
  );

  Future<void> saveAndTranslate() async {
    isSaving.value = true;
    player.pause();

    // pindah halaman ke result
    final transController = Get.find<TranslationController>();
    Get.offNamed(RouteNames.result);

    await transController.processVideoPath(
      _videoPath,
      trimStart: trimStart,
      trimEnd: trimEnd,
    );
    isSaving.value = false;
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
