import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:hand_detection/hand_detection.dart';
import 'package:image/image.dart' as img;

class TfliteDataSources {
  Interpreter? interpreter;
  List<String> labels = [];
  String? loadError;

  // ── Konstanta sesuai preprocessing Python (run10 main GRU.py) ──
  static const int numFrames = 16;
  static const int imgSize = 128;
  static const int landmarkDim =
      153; // 9 pose*3 + 21 leftHand*3 + 21 rightHand*3
  static const int featureDim = 306; // landmarkDim + velocity(landmarkDim)

  // POSE_IDS Python: [0,11,12,13,14,15,16,23,24]
  static const List<PoseLandmarkType> poseIds = [
    PoseLandmarkType.nose,
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.leftElbow,
    PoseLandmarkType.rightElbow,
    PoseLandmarkType.leftWrist,
    PoseLandmarkType.rightWrist,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip,
  ];

  TfliteDataSources() {
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(
        'assets/model/modelv10_GRU.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      print("Model GRU berhasil di load");
      print(
        "   Input : ${interpreter!.getInputTensor(0).shape} "
        "(${interpreter!.getInputTensor(0).type})",
      );
      print(
        "   Output: ${interpreter!.getOutputTensor(0).shape} "
        "(${interpreter!.getOutputTensor(0).type})",
      );

      final String jsonStr = await rootBundle.loadString(
        'assets/model/label_map.json',
      );
      labels = List<String>.from(json.decode(jsonStr));
      print("Labels: ${labels.length} kelas");

      loadError = null;
    } catch (e) {
      print("Gagal load: $e");
      loadError = e.toString();
    }
  }

  Future<Map<String, dynamic>> runInference(String videoPath) async {
    if (interpreter == null || labels.isEmpty) await loadModel();
    if (interpreter == null || labels.isEmpty) {
      throw Exception("Model belum siap! ${loadError ?? 'unknown'}");
    }

    try {
      // ── Step 1: Extract 16 frame + fixed shoulder crop ──
      final List<String> croppedPaths = await _extractAndCropFrames(videoPath);
      if (croppedPaths.isEmpty) {
        return {'label': 'Gagal ekstrak frame', 'confidence': 0.0};
      }

      // ── Step 2: Landmark extraction per frame → (16, 153) ──
      final List<List<double>> landmarkSeq = await _extractLandmarkSequence(
        croppedPaths,
      );

      // ── Step 3: Velocity + concat + forward-fill → (16, 306) ──
      final List<List<double>> featureSeq = _buildFeatureSequence(landmarkSeq);

      // Reshape ke [1, 16, 306]
      final List<dynamic> inputTensor = [featureSeq];

      const int numRuns = 3;
      final List<double> avgScores = List.filled(labels.length, 0.0);

      for (int run = 0; run < numRuns; run++) {
        final List<double> outputRaw = List.filled(labels.length, 0.0);
        final List<List<double>> output = [outputRaw];
        interpreter!.run(inputTensor, output);
        for (int i = 0; i < labels.length; i++) {
          avgScores[i] += output[0][i] / numRuns;
        }
      }

      final List<MapEntry<int, double>> ranked =
          avgScores.asMap().entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      final int topIdx = ranked[0].key;
      final double topScore = ranked[0].value;
      final double confidence = topScore * 100;

      print("Top-1: ${labels[topIdx]} (${confidence.toStringAsFixed(1)}%)");
      if (ranked.length > 1) {
        final double secScore = ranked[1].value;
        print(
          "Top-2: ${labels[ranked[1].key]} "
          "(${(secScore * 100).toStringAsFixed(1)}%)",
        );
      }

      return {'label': labels[topIdx], 'confidence': confidence};
    } catch (e) {
      throw Exception("Gagal melakukan inferensi: $e");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // STEP 1 — Replikasi get_fixed_crop() + fixed_shoulder_crop():
  // crop box dihitung SEKALI dari frame pertama (raw), lalu diterapkan
  // ke semua 16 frame yang disampling.
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<String>> _extractAndCropFrames(String videoPath) async {
    final tempDir = await getTemporaryDirectory();
    final rawDir = Directory('${tempDir.path}/raw_frames');
    final cropDir = Directory('${tempDir.path}/crop_frames');

    for (final d in [rawDir, cropDir]) {
      if (await d.exists()) await d.delete(recursive: true);
      await d.create();
    }

    await FFmpegKit.execute('-i "$videoPath" "${rawDir.path}/frame_%04d.jpg"');

    final List<FileSystemEntity> rawFiles =
        rawDir.listSync().where((f) => f.path.endsWith('.jpg')).toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    print("   Raw frames: ${rawFiles.length}");
    if (rawFiles.isEmpty) return [];

    // ── Replikasi: np.linspace(0, total-1, 16) → unique → astype(int) ──
    final int totalFrames = rawFiles.length;
    final Set<int> seen = {};
    final List<int> sampledIdx = [];
    for (int i = 0; i < numFrames; i++) {
      final double t = i * (totalFrames - 1) / (numFrames - 1);
      final int idx = t.toInt(); // truncate, sama seperti astype(int)
      if (seen.add(idx)) sampledIdx.add(idx);
    }

    final List<String> sampledPaths = sampledIdx
        .map((idx) => rawFiles[idx].path)
        .toList();

    print("   Sampled unique frames: ${sampledPaths.length}/$numFrames");

    // ── fixed_crop dihitung SEKALI dari frame pertama (raw, belum crop) ──
    final List<int>? cropBox = await _getFixedCrop(sampledPaths.first);

    // ── Terapkan crop yang SAMA ke semua frame ──
    final List<String> result = await compute(_batchCropFrames, {
      'inputPaths': sampledPaths,
      'outputDir': cropDir.path,
      'cropBox': cropBox,
      'imgSize': imgSize,
    });

    print("   Cropped frames: ${result.length}");
    return result;
  }

  // get_fixed_crop: shoulder-based crop box dari 1 frame (resolusi raw)
  Future<List<int>?> _getFixedCrop(String framePath) async {
    try {
      final detector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.single),
      );
      final poses = await detector.processImage(
        InputImage.fromFilePath(framePath),
      );
      await detector.close();

      final imgBytes = await File(framePath).readAsBytes();
      final decoded = img.decodeImage(imgBytes);
      if (decoded == null) return null;

      final int w0 = decoded.width;
      final int h0 = decoded.height;

      if (poses.isEmpty) {
        final int size = min(w0, h0);
        return [
          (w0 - size) ~/ 2,
          (h0 - size) ~/ 2,
          (w0 + size) ~/ 2,
          (h0 + size) ~/ 2,
        ];
      }

      final pose = poses.first;
      final lSh = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rSh = pose.landmarks[PoseLandmarkType.rightShoulder];

      if (lSh == null || rSh == null) {
        final int size = min(w0, h0);
        return [
          (w0 - size) ~/ 2,
          (h0 - size) ~/ 2,
          (w0 + size) ~/ 2,
          (h0 + size) ~/ 2,
        ];
      }

      // ML Kit sudah pixel coords di frame asli (= int(lm.x*w0) di Python)
      final int lx = lSh.x.toInt();
      final int ly = lSh.y.toInt();
      final int rx = rSh.x.toInt();
      final int ry = rSh.y.toInt();

      final int cx = ((lx + rx) / 2).toInt();
      int cy = ((ly + ry) / 2).toInt();
      final int shoulderDist = (rx - lx).abs();

      final int offsetX = (shoulderDist * 1.3).toInt();
      final int offsetTop = (shoulderDist * 0.9).toInt();
      final int offsetBottom = (shoulderDist * 2.5).toInt();
      cy = cy + (shoulderDist * -0.9).toInt();

      return [cx - offsetX, cy - offsetTop, cx + offsetX, cy + offsetBottom];
    } catch (e) {
      print("   get_fixed_crop gagal: $e");
      return null;
    }
  }

  Future<List<List<double>>> _extractLandmarkSequence(
    List<String> croppedPaths,
  ) async {
    final poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.single),
    );
    final handDetector = await HandDetector.create(
      performanceConfig: PerformanceConfig.xnnpack(numThreads: 4),
    );

    final List<List<double>> sequence = [];

    for (final path in croppedPaths) {
      sequence.add(await _landmarkToVector(path, poseDetector, handDetector));
    }

    await poseDetector.close();
    await handDetector.dispose();

    // ── Padding: kalau frame hasil sampling < 16, ulangi frame terakhir
    // (sebelum velocity dihitung — sama seperti Python) ──
    while (sequence.length < numFrames) {
      sequence.add(List<double>.from(sequence.last));
    }

    return sequence;
  }

  Future<List<double>> _landmarkToVector(
    String framePath,
    PoseDetector poseDetector,
    HandDetector handDetector,
  ) async {
    final List<double> vector = [];

    double centerX = 0.5;
    double centerY = 0.5;
    double shoulderWidth = 1.0;

    final poses = await poseDetector.processImage(
      InputImage.fromFilePath(framePath),
    );
    final Pose? pose = poses.isNotEmpty ? poses.first : null;

    if (pose != null) {
      final lSh = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rSh = pose.landmarks[PoseLandmarkType.rightShoulder];
      if (lSh != null && rSh != null) {
        // Normalisasi pixel (0..128) → 0..1 sesuai skala MediaPipe Tasks
        final double lx = lSh.x / imgSize;
        final double ly = lSh.y / imgSize;
        final double rx = rSh.x / imgSize;
        final double ry = rSh.y / imgSize;
        centerX = (lx + rx) / 2;
        centerY = (ly + ry) / 2;
        shoulderWidth = (rx - lx).abs();
        if (shoulderWidth < 1e-6) shoulderWidth = 1e-6;
      }
    }

    // ── POSE: 9 landmark (POSE_IDS) × 3 (x,y,z) = 27 ──
    if (pose != null) {
      for (final type in poseIds) {
        final lm = pose.landmarks[type];
        if (lm != null) {
          final double xNorm = (lm.x / imgSize - centerX) / shoulderWidth;
          final double yNorm = (lm.y / imgSize - centerY) / shoulderWidth;
          final double zNorm = (lm.z / imgSize) / shoulderWidth;
          vector.addAll([xNorm, yNorm, zNorm]);
        } else {
          vector.addAll([0.0, 0.0, 0.0]);
        }
      }
    } else {
      // Tidak ada pose → 27 nol (jaga FEATURE_DIM=306 selalu konsisten,
      // lihat catatan di bawah soal perbedaan dgn fallback Python)
      vector.addAll(List.filled(27, 0.0));
    }

    // ── HAND: leftHand(21×3) + rightHand(21×3) = 126 ──
    final List<double> leftHand = List.filled(63, 0.0);
    final List<double> rightHand = List.filled(63, 0.0);

    try {
      final Uint8List imgBytes = await File(framePath).readAsBytes();
      final List<Hand> hands = await handDetector.detect(imgBytes);

      for (final hand in hands.take(2)) {
        if (!hand.hasLandmarks) continue;

        final List<double> coords = [];
        for (final lm in hand.landmarks) {
          final double xNorm = (lm.x / imgSize - centerX) / shoulderWidth;
          final double yNorm = (lm.y / imgSize - centerY) / shoulderWidth;
          // ASUMSI: hand_detection package punya field .z — lihat catatan
          final double zNorm = (lm.z / imgSize) / shoulderWidth;
          coords.addAll([xNorm, yNorm, zNorm]);
        }

        if (hand.handedness == Handedness.left) {
          for (int i = 0; i < 63; i++) {
            leftHand[i] = coords[i];
          }
        } else if (hand.handedness == Handedness.right) {
          for (int i = 0; i < 63; i++) {
            rightHand[i] = coords[i];
          }
        }
      }
    } catch (_) {}

    vector.addAll(leftHand);
    vector.addAll(rightHand);

    return vector; // total 153
  }

  // ═══════════════════════════════════════════════════════════════════════
  // STEP 3 — velocity + concat + forward_fill_sequence → (16, 306)
  // ═══════════════════════════════════════════════════════════════════════

  List<List<double>> _buildFeatureSequence(List<List<double>> landmarkSeq) {
    final int n = landmarkSeq.length; // 16
    final int d = landmarkDim; // 153

    final List<List<double>> velocity = List.generate(
      n,
      (_) => List.filled(d, 0.0),
    );
    for (int i = 1; i < n; i++) {
      for (int j = 0; j < d; j++) {
        velocity[i][j] = landmarkSeq[i][j] - landmarkSeq[i - 1][j];
      }
    }

    final List<List<double>> combined = List.generate(n, (i) {
      return [...landmarkSeq[i], ...velocity[i]];
    });

    // forward_fill_sequence: kalau frame (306-dim) all-zero, ganti last_valid
    List<double>? lastValid;
    for (int i = 0; i < n; i++) {
      final bool isAllZero = combined[i].every((v) => v == 0.0);
      if (!isAllZero) {
        lastValid = List<double>.from(combined[i]);
      } else if (lastValid != null) {
        combined[i] = List<double>.from(lastValid);
      }
    }

    return combined; // (16, 306)
  }

  void close() => interpreter?.close();
}

Future<List<String>> _batchCropFrames(Map<String, dynamic> params) async {
  final List<String> inputPaths = List<String>.from(params['inputPaths']);
  final String outputDir = params['outputDir'] as String;
  final List<int>? cropBox = (params['cropBox'] as List<dynamic>?)?.cast<int>();
  final int imgSize = params['imgSize'] as int;

  final List<String> results = [];

  for (int i = 0; i < inputPaths.length; i++) {
    final String outPath =
        '$outputDir/crop_${i.toString().padLeft(3, '0')}.jpg';
    try {
      final Uint8List bytes = await File(inputPaths[i]).readAsBytes();
      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) continue;

      final int w = decoded.width;
      final int h = decoded.height;
      img.Image cropped;

      if (cropBox != null) {
        final int padLeft = max(0, -cropBox[0]);
        final int padTop = max(0, -cropBox[1]);
        final int padRight = max(0, cropBox[2] - w);
        final int padBottom = max(0, cropBox[3] - h);

        final int x1 = max(0, cropBox[0]);
        final int y1 = max(0, cropBox[1]);
        final int x2 = min(w, cropBox[2]);
        final int y2 = min(h, cropBox[3]);

        cropped = img.copyCrop(
          decoded,
          x: x1,
          y: y1,
          width: x2 - x1,
          height: y2 - y1,
        );

        if (padLeft > 0 || padTop > 0 || padRight > 0 || padBottom > 0) {
          cropped = img.copyExpandCanvas(
            cropped,
            newWidth: cropped.width + padLeft + padRight,
            newHeight: cropped.height + padTop + padBottom,
            position: img.ExpandCanvasPosition.topLeft,
            backgroundColor: img.ColorRgb8(0, 0, 0),
          );
        }
      } else {
        final int size = min(w, h);
        cropped = img.copyCrop(
          decoded,
          x: (w - size) ~/ 2,
          y: (h - size) ~/ 2,
          width: size,
          height: size,
        );
      }

      final img.Image resized = img.copyResize(
        cropped,
        width: imgSize,
        height: imgSize,
      );
      await File(outPath).writeAsBytes(img.encodeJpg(resized, quality: 90));
      results.add(outPath);
    } catch (e) {
      print('   Frame $i crop error: $e');
    }
  }

  return results;
}
