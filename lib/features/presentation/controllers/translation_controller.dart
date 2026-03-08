import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/domain/entities/translation_entity.dart';
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

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> uploadVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null && result.files.single.path != null) {
        String videoPath = result.files.single.path!;

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
        Get.toNamed(RouteNames.result);
        await processVideoPath(videoPath);
      }
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

  Future<void> processVideoPath(String path) async {
    try {
      isLoading.value = true;
      currentResult.value = null;

      final directory = await getApplicationSupportDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(5);
      final String safeFileName = 'signa_vid_$timestamp.mp4';
      final String permanentPath = p.join(directory.path, safeFileName);

      print("Source path: $path");
      print("Source exists: ${await File(path).exists()}");
      print("Target path: $permanentPath");

      final session = await FFmpegKit.execute(
        '-i "$path" -vcodec libx264 -profile:v baseline -level 3.1 -vf "scale=720:1280,format=yuv420p" -crf 28 -preset ultrafast -acodec aac -movflags +faststart -color_range 1 -colorspace 1 "$permanentPath"',
      );

      final returnCode = await session.getReturnCode();
      final output = await session.getOutput();
      
      // final logs = await session.getLogs();

      print("FFmpeg return code: $returnCode");
      print("FFmpeg success: ${ReturnCode.isSuccess(returnCode)}");
      print("FFmpeg output: $output");

      if (!ReturnCode.isSuccess(returnCode)) {
        throw Exception("FFmpeg transcode gagal!");
      }

      if (await File(permanentPath).exists()) {
        final result = await translateUC.execute(permanentPath);
        currentResult.value = result;
        print("Video path disimpan: $permanentPath");
        print("File exists: ${await File(permanentPath).exists()}");

        final File cachedVideo = File(path);

        if (await cachedVideo.exists()) {
          await cachedVideo.delete();
        }
      } else {
        throw Exception("Gagal memindahkan file video");
      }

      await loadHistory();
    } catch (e) {
      Get.snackbar('Error Proses', e.toString());
    } finally {
      isLoading.value = false;
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
      Get.snackbar('Sukses', 'Riwayat berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error Hapus', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
