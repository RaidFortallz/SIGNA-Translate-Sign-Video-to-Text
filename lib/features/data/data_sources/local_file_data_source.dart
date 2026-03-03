import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LocalFileDataSource {
  Future<String> saveVideo(File videoFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      String fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      String newPath = p.join(directory.path, fileName);

      final savedFile = await videoFile.copy(newPath);
      await videoFile.delete();

      return savedFile.path;
    } catch (e) {
      throw Exception("Gagal simpan video ke lokal: $e");
    }
  }

  Future<void> deleteVideo(String path) async {
    try {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception("Gagal menghapus video lokal: $e");
    }
  }
}
