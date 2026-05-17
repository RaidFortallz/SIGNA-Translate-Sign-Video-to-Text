import 'dart:convert';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

Future<List<List<List<List<double>>>>> _processFramesFromPaths(
  Map<String, dynamic> params,
) async {
  int targetFrames = params['targetFrames'];
  int imgWidth = params['imgWidth'];
  int imgHeight = params['imgHeight'];
  List<String> framePaths = List<String>.from(params['framePaths']);

  List<List<List<List<double>>>> videoFrames = [];

  for (int i = 0; i < targetFrames; i++) {
    List<List<List<double>>> frameData = [];

    final path = i < framePaths.length ? framePaths[i] : null;
    final imgFile = path != null ? File(path) : null;

    if (imgFile != null && imgFile.existsSync()) {
      img.Image? image = img.decodeImage(imgFile.readAsBytesSync());

      for (int y = 0; y < imgHeight; y++) {
        List<List<double>> row = [];
        for (int x = 0; x < imgWidth; x++) {
          if (image != null) {
            img.Pixel pixel = image.getPixel(x, y);
            row.add([pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0]);
          } else {
            row.add([0.0, 0.0, 0.0]);
          }
        }
        frameData.add(row);
      }
    } else {
      if (videoFrames.isNotEmpty) {
        frameData = videoFrames.last;
      } else {
        for (int y = 0; y < imgHeight; y++) {
          List<List<double>> row = [];
          for (int x = 0; x < imgWidth; x++) {
            row.add([0.0, 0.0, 0.0]);
          }
          frameData.add(row);
        }
      }
    }
    videoFrames.add(frameData);
  }
  return videoFrames;
}

class TfliteDataSources {
  Interpreter? interpreter;

  List<String> labels = [];

  final int targetFrames = 16;
  final int imgWidth = 112;
  final int imgHeight = 112;

  TfliteDataSources() {
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(
        'assets/model/v1newdataset3dcnn_model.tflite',
      );
      print("Model 3D CNN berhasil di load");

      final String jsonString = await rootBundle.loadString(
        'assets/model/classes.json',
      );
      final List<dynamic> jsonResponse = json.decode(jsonString);
      labels = jsonResponse.cast<String>();
      print("Labels JSON berhasil di-load. Jumlah kata: ${labels.length}");
    } catch (e) {
      print("Gagal load model atau labels: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>> runInference(
    String path, {
    Duration? trimStart,
    Duration? trimEnd,
  }) async {
    if (interpreter == null || labels.isEmpty) {
      print(
        "Interpreter model atau label belum siap, nunggu loadModel() bentar...",
      );
      await loadModel();
    }

    if (interpreter == null || labels.isEmpty) {
      throw Exception("File model .tflite atau classes.json tidak ketemu!");
    }

    try {
      print("Mulai ekstrak video...");
      var inputTensor = await _extractFramesFromVideo(
        path,
        trimStart: trimStart,
        trimEnd: trimEnd,
      );

      var outputTensor = List.filled(
        1 * labels.length,
        0.0,
      ).reshape([1, labels.length]);
      print("Mulai berpikir (Inference)...");

      interpreter!.run(inputTensor, outputTensor);

      print("Inference Selesai Cok! Lanjut hitung akurasi...");

      List<double> predictions = outputTensor[0];

      int maxIndex = 0;
      double maxConfidence = 0.0;

      for (int i = 0; i < predictions.length; i++) {
        if (predictions[i] > maxConfidence) {
          maxConfidence = predictions[i];
          maxIndex = i;
        }
      }

      double finalConfidence = maxConfidence * 100;
      if (finalConfidence < 80.0) {
        return {
          'label': 'Gerakan Tidak Diketahui',
          'confidence': finalConfidence,
        };
      }

      return {'label': labels[maxIndex], 'confidence': finalConfidence};
    } catch (e) {
      throw Exception("Gagal melakukan inferensi: $e");
    }
  }

  Future<List<dynamic>> _extractFramesFromVideo(
    String videoPath, {
    Duration? trimStart,
    Duration? trimEnd,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final frameDir = Directory('${tempDir.path}/frames');
    final allFrameDir = Directory('${tempDir.path}/all_frames');

    for (final dir in [frameDir, allFrameDir]) {
      if (await dir.exists()) await dir.delete(recursive: true);
      await dir.create();
    }

    final bool hasTrim = trimStart != null && trimEnd != null;

    final String trimFlags = hasTrim
        ? '-ss ${_formatDuration(trimStart)} -to ${_formatDuration(trimEnd)}'
        : '';

    //Ekstrak semua frame
    final extractAll =
        '$trimFlags'
        '-i "$videoPath" '
        '-vf "crop=min(iw\\,ih):min(iw\\,ih),scale=$imgWidth:$imgHeight" '
        '"${allFrameDir.path}/frame_%04d.jpg"';

    await FFmpegKit.execute(extractAll);

    //Baca semua frame yang berhasil diekstrak
    final List<FileSystemEntity> allFiles =
        allFrameDir.listSync().where((f) => f.path.endsWith('.jpg')).toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    print("Total frame mentah yang diekstrak: ${allFiles.length}");

    if (allFiles.isEmpty) return [_generateBlankFrames()];

    //Kalau ada trim: langsung uniform sample, skip motion detection
    final List<String> selectedPaths;

    if (hasTrim) {
      selectedPaths = List.generate(targetFrames, (i) {
        final idx = (i * allFiles.length / targetFrames).floor().clamp(
          0,
          allFiles.length - 1,
        );
        return allFiles[idx].path;
      });
      print(
        "Trim aktif — uniform sample $targetFrames frames dari segmen trim",
      );
    } else {
      //Motion detection — hitung diff antar frame
      final List<double> motionScores = [];
      img.Image? prevGray;

      for (int i = 0; i < allFiles.length; i++) {
        final bytes = File(allFiles[i].path).readAsBytesSync();
        final image = img.decodeImage(bytes);
        if (image == null) continue;

        final gray = img.grayscale(image);

        if (prevGray != null) {
          double diff = 0;
          for (int y = 0; y < gray.height; y++) {
            for (int x = 0; x < gray.width; x++) {
              final p1 = gray.getPixel(x, y).r.toDouble();
              final p2 = prevGray.getPixel(x, y).r.toDouble();
              diff += (p1 - p2).abs();
            }
          }
          motionScores.add(diff / (gray.width * gray.height));
        }
        prevGray = gray;
      }

      //Cari motion start
      int startIdx = 0;
      if (motionScores.isNotEmpty) {
        final double meanMotion =
            motionScores.reduce((a, b) => a + b) / motionScores.length;
        final double threshold = meanMotion * 1.3;

        final motionIndices = motionScores
            .asMap()
            .entries
            .where((e) => e.value > threshold)
            .map((e) => e.key)
            .toList();

        if (motionIndices.isNotEmpty) {
          startIdx = (motionIndices.first - 2).clamp(0, allFiles.length - 1);
        } else {
          startIdx = allFiles.length ~/ 3;
        }
      }

      print("Motion start index: $startIdx");

      //Ambil targetFrames frame dari startIdx, dengan padding
      selectedPaths = List.generate(targetFrames, (i) {
        final idx = (startIdx + i).clamp(0, allFiles.length - 1);
        return allFiles[idx].path;
      });
    }

    print("Mulai bongkar pixel gambar di Background Thread...");
    List<List<List<List<double>>>> resultFrames =
        await compute(_processFramesFromPaths, {
          'targetFrames': targetFrames,
          'imgWidth': imgWidth,
          'imgHeight': imgHeight,
          'framePaths': selectedPaths,
        });

    return [resultFrames];
  }

  //Helper format Duration → HH:mm:ss.mmm untuk FFmpeg ──────────────────
  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  List<List<List<List<double>>>> _generateBlankFrames() {
    return List.generate(
      16,
      (_) =>
          List.generate(112, (_) => List.generate(112, (_) => [0.0, 0.0, 0.0])),
    );
  }

  void close() {
    interpreter?.close();
  }
}
