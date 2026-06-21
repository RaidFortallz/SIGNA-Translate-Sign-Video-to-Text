import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/return_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/data/data_sources/tflite_data_sources.dart';
import 'package:signa_video_to_text/features/domain/entities/translation_entity.dart';
import 'package:signa_video_to_text/features/domain/repositories/translation_repository.dart';
import 'package:signa_video_to_text/features/domain/usecases/delete_history_usecase.dart';
import 'package:signa_video_to_text/features/domain/usecases/get_history_usecase.dart';
import 'package:signa_video_to_text/features/domain/usecases/translate_video_usecase.dart';

class TranslationController extends GetxController {
  final TranslateVideoUsecase translateUC;
  final GetHistoryUsecase historyUC;
  final DeleteHistoryUsecase deleteUC;

  TranslationController({
    required this.translateUC,
    required this.historyUC,
    required this.deleteUC,
  });

  var isLoading = false.obs;
  var historyList = <TranslationEntity>[].obs;
  var currentResult = Rxn<TranslationEntity>();
  var videoSource = 'rekam'.obs;
  var isFrontCamera = false.obs;
  var progressMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> uploadVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

      if (video == null) return;

      final String videoPath = video.path;

      if (!videoPath.toLowerCase().endsWith('.mp4')) {
        Get.defaultDialog(
          title: "Format Tidak Didukung",
          middleText: "Harap masukkan video dengan format .mp4",
          textConfirm: "OK",
          confirmTextColor: WarnaApp.wrWhite,
          onConfirm: () => Get.back(),
        );
        return;
      }

      videoSource.value = 'upload';
      Get.toNamed(RouteNames.trim, arguments: videoPath);
    } catch (e) {
      Get.snackbar('Error Upload', e.toString());
    }
  }

  Future<void> recordVideo() async {
    Get.toNamed(RouteNames.record);
    print("Membuka halaman CameraAwesome...");
  }

  Future<void> loadHistory() async {
    try {
      isLoading.value = true;
      final data = await historyUC.execute();
      historyList.assignAll(data);
    } catch (e) {
      Get.snackbar('Error load history', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processSegments(
    String originalPath,
    List<RangeValues> segments,
    int totalDurationMs,
  ) async {
    try {
      isLoading.value = true;
      currentResult.value = null;
      progressMessage.value = 'Mempersiapkan video...';

      // 1. Simpan video asli ke permanent path (untuk preview di result page)
      final directory = await getApplicationSupportDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(5);
      final String safeFileName = 'signa_vid_$timestamp.mp4';
      final String permanentPath = p.join(directory.path, safeFileName);

      final bool needFlip = isFrontCamera.value;

      if (needFlip) {
        final session = await FFmpegKit.execute(
          '-i "$originalPath" -vf hflip '
          '-c:v libx264 -preset ultrafast -crf 22 -an '
          '-y "$permanentPath"',
        );
        final rc = await session.getReturnCode();
        if (!ReturnCode.isSuccess(rc)) {
          await File(originalPath).copy(permanentPath);
        }
      } else {
        await File(originalPath).copy(permanentPath);
      }

      // Hapus cache asli
      final File cacheFile = File(originalPath);
      if (await cacheFile.exists()) await cacheFile.delete();

      print("Permanent: $permanentPath | Segmen: ${segments.length}");

      // 2. Inferensi per segmen
      final tflite = Get.find<TfliteDataSources>();
      final tempDir = await getTemporaryDirectory();

      final List<String> words = [];
      final List<double> confidences = [];
      String? lastError;

      for (int i = 0; i < segments.length; i++) {
        progressMessage.value = segments.length == 1
            ? 'Menganalisis gerakan...'
            : 'Memproses gerakan ${i + 1} dari ${segments.length}...';
        await Future.delayed(Duration.zero);

        final RangeValues seg = segments[i];
        final Duration segStart = Duration(
          milliseconds: (seg.start * totalDurationMs).round(),
        );
        final Duration segEnd = Duration(
          milliseconds: (seg.end * totalDurationMs).round(),
        );

        print(
          "── Segmen ${i + 1}/${segments.length}: "
          "${_toFFmpegTime(segStart)} → ${_toFFmpegTime(segEnd)}",
        );

        final String segTempPath = '${tempDir.path}/seg_${i}_$timestamp.mp4';

        final session = await FFmpegKit.execute(
          '-ss ${_toFFmpegTime(segStart)} '
          '-to ${_toFFmpegTime(segEnd)} '
          '-i "$permanentPath" '
          '-c copy -y "$segTempPath"',
        );
        final rc = await session.getReturnCode();

        if (!ReturnCode.isSuccess(rc)) {
          print("   Segmen ${i + 1}: FFmpeg gagal, skip");
          continue;
        }

        try {
          final Map<String, dynamic> result = await tflite.runInference(
            segTempPath,
          );
          final String label = result['label'] as String;
          final double confidence = (result['confidence'] as num).toDouble();
          words.add(label);
          confidences.add(confidence);
          print("Segmen ${i + 1}: $label (${confidence.toStringAsFixed(1)}%)");
        } catch (e) {
          print("Segmen ${i + 1} inferensi gagal: $e");
          lastError = e.toString();
        } finally {
          final File segFile = File(segTempPath);
          if (await segFile.exists()) await segFile.delete();
        }
      }

      if (words.isEmpty) {
        throw Exception(
          "Semua segmen gagal diproses: ${lastError ?? 'unknown error'}",
        );
      }

      final String combinedText = words.join(' ');
      final double avgConfidence = confidences.isEmpty
          ? 0.0
          : confidences.reduce((a, b) => a + b) / confidences.length;

      print(
        "Kalimat: '$combinedText' "
        "(conf avg: ${avgConfidence.toStringAsFixed(1)}%)",
      );

      progressMessage.value = 'Menyimpan hasil...';
      await Future.delayed(Duration.zero);

      // 3. Simpan ke Firestore via repository
      final repo = Get.find<ITranslationRepository>();
      final entity = await repo.saveResult(
        text: combinedText,
        accuracy: avgConfidence,
        videoPath: permanentPath,
      );

      currentResult.value = entity;
      // await loadHistory();

      if (!historyList.any((h) => h.id == entity.id)) {
        historyList.insert(0, entity);
      }

      Future.delayed(const Duration(seconds: 3), _refreshHistoryBackground);
    } catch (e) {
      Get.snackbar('Error Proses', e.toString());
    } finally {
      isLoading.value = false;
      isFrontCamera.value = false;
      progressMessage.value = '';
    }
  }

  Future<void> processVideoPath(
    String path, {
    Duration? trimStart,
    Duration? trimEnd,
  }) async {
    try {
      isLoading.value = true;
      currentResult.value = null;

      final directory = await getApplicationSupportDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(5);
      final String safeFileName = 'signa_vid_$timestamp.mp4';
      final String permanentPath = p.join(directory.path, safeFileName);

      final bool hasTrim = trimStart != null && trimEnd != null;
      final bool needFlip = isFrontCamera.value;

      // Tentukan filter video
      final String vfFlag = needFlip ? '-vf hflip ' : '';
      final String codecFlag = needFlip
          ? '-c:v libx264 -preset ultrafast -crf 22 -an '
          : '-c copy ';

      if (hasTrim) {
        final session = await FFmpegKit.execute(
          '-ss ${_toFFmpegTime(trimStart)} '
          '-to ${_toFFmpegTime(trimEnd)} '
          '-i "$path" '
          '$vfFlag'
          '$codecFlag'
          '-y "$permanentPath"',
        );
        final rc = await session.getReturnCode();
        if (!ReturnCode.isSuccess(rc)) await File(path).copy(permanentPath);
      } else {
        if (needFlip) {
          final session = await FFmpegKit.execute(
            '-i "$path" $vfFlag$codecFlag-y "$permanentPath"',
          );
          final rc = await session.getReturnCode();
          if (!ReturnCode.isSuccess(rc)) await File(path).copy(permanentPath);
        } else {
          await File(path).copy(permanentPath);
        }
      }

      print("Source path: $path");
      print("Target path: $permanentPath");
      print("Front camera flip: $needFlip");
      print("Source exists: ${await File(path).exists()}");

      if (await File(permanentPath).exists()) {
        final result = await translateUC.execute(permanentPath);
        currentResult.value = result;

        print("Video path disimpan: $permanentPath");
        print("File exists: true");

        final File cachedVideo = File(path);
        if (await cachedVideo.exists()) await cachedVideo.delete();
      } else {
        throw Exception("Gagal memindahkan file video");
      }

      await loadHistory();
    } catch (e) {
      Get.snackbar('Error Proses', e.toString());
    } finally {
      isLoading.value = false;
      isFrontCamera.value = false;
    }
  }

  Future<void> deleteHistoryItem(String id, String path) async {
    try {
      isLoading.value = true;

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      await deleteUC.execute(id, path);
      await loadHistory();
      Get.snackbar(
        'Sukses',
        'Riwayat berhasil dihapus',
        duration: const Duration(milliseconds: 850),
      );
    } catch (e) {
      Get.snackbar('Error Hapus', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String _toFFmpegTime(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  Future<void> _refreshHistoryBackground() async {
    try {
      final data = await historyUC.execute();
      historyList.assignAll(data);
    } catch (e) {
      print("Background history refresh: $e");
    }
  }
}
