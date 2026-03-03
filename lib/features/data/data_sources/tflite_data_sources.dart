import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TfliteDataSources {
  Interpreter? interpreter;

  final List<String> labels = ['Halo', 'Minum', 'Terima Kasih'];

  final int targetFrames = 16;
  final int imgWidth = 112;
  final int imgHeight = 112;

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(
        'assets/model/3dcnn_model.tflite',
      );
      print("Model 3D CNN berhasil di load");
    } catch (e) {
      print("Gagal load model: $e");
    }
  }

  Future<Map<String, dynamic>> runInference(String path) async {
    if (interpreter == null) {
      throw Exception("Interpreter model belum siap!");
    }

    try {
      print("Mulai ekstrak video...");
      var inputTensor = await _extractFramesFromVideo(path);

      var outputTensor = List.filled(
        1 * labels.length,
        0.0,
      ).reshape([1, labels.length]);
      print("Mulai berpikir (Inference)...");

      interpreter!.run(inputTensor, outputTensor);

      List<double> predictions = outputTensor[0];

      int maxIndex = 0;
      double maxConfidence = 0.0;

      for (int i = 0; i < predictions.length; i++) {
        if (predictions[i] > maxConfidence) {
          maxConfidence = predictions[i];
          maxIndex = i;
        }
      }

      return {'label': labels[maxIndex], 'confidence': maxConfidence * 100};
    } catch (e) {
      throw Exception("Gagal melakukan inferensi: $e");
    }
  }

  Future<List<dynamic>> _extractFramesFromVideo(String videoPath) async {
    final tempDir = await getTemporaryDirectory();
    final frameDir = Directory('${tempDir.path}/frames');

    if (await frameDir.exists()) {
      await frameDir.delete(recursive: true);
    }
    await frameDir.create();

    final command =
        '-i "$videoPath" -vf "fps=$targetFrames/1,scale=$imgWidth:$imgHeight" -vframes $targetFrames "${frameDir.path}/frame_%03d.jpg"';
    await FFmpegKit.execute(command);

    List<List<List<List<double>>>> videoFrames = [];

    for (int i = 1; i <= targetFrames; i++) {
      String fileName = 'frame_${i.toString().padLeft(3, '0')}.jpg';
      File imgFile = File('${frameDir.path}/$fileName');

      List<List<List<double>>> frameData = [];

      if (imgFile.existsSync()) {
        img.Image? image = img.decodeImage(imgFile.readAsBytesSync());

        for (int y = 0; y < imgHeight; y++) {
          List<List<double>> row = [];
          for (int x = 0; x < imgWidth; x++) {
            img.Pixel pixel = image!.getPixel(x, y);

            row.add([pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0]);
          }
          frameData.add(row);
        }
      } else {
        for (int y = 0; y < imgHeight; y++) {
          List<List<double>> row = [];
          for (int x = 0; x < imgWidth; x++) {
            row.add([0.0, 0.0, 0.0]);
          }
          frameData.add(row);
        }
      }
      videoFrames.add(frameData);
    }
    return [videoFrames];
  }

  void close() {
    interpreter?.close();
  }
}
