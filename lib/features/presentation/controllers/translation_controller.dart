import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
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

      final result = await translateUC.execute(path);
      currentResult.value = result;

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
