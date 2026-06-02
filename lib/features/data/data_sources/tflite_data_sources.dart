import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:hand_detection/hand_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

Float32List _buildHeatmapTensor(Map<String, dynamic> params) {
  final int numFrames = params['numFrames'];
  final int imgSize = params['imgSize'];

  // poseDataList: List of {lShoulder, rShoulder, lElbow, rElbow, lWrist, rWrist}
  // handDataList: List of {left: List<[x,y]>, right: List<[x,y]>}
  final List poseDataList = params['poseDataList'];
  final List handDataList = params['handDataList'];

  final Float32List tensor = Float32List(numFrames * imgSize * imgSize * 2);

  for (int f = 0; f < numFrames; f++) {
    final Map poseData = poseDataList[f];
    final Map handData = handDataList[f];

    // Base offset untuk frame ini
    final int frameBase = f * imgSize * imgSize * 2;
    final int ch0 = frameBase;
    final int ch1 = frameBase + imgSize * imgSize;

    // ── Gambar arm kiri (ch0)
    _drawArmOnTensor(tensor, ch0, imgSize, poseData, 'l');
    // ── Gambar arm kanan (ch1)
    _drawArmOnTensor(tensor, ch1, imgSize, poseData, 'r');
    // ── Gambar tangan kiri (ch0)
    if (handData.containsKey('left')) {
      final List<List<int>> pts = (handData['left'] as List)
          .map<List<int>>((e) => [e[0] as int, e[1] as int])
          .toList();
      _drawHandOnTensor(tensor, ch0, imgSize, pts);
    }

    // ── Gambar tangan kanan (ch1)
    if (handData.containsKey('right')) {
      final List<List<int>> pts = (handData['right'] as List)
          .map<List<int>>((e) => [e[0] as int, e[1] as int])
          .toList();
      _drawHandOnTensor(tensor, ch1, imgSize, pts);
    }
  }
  return tensor;
}

void _drawArmOnTensor(
  Float32List tensor,
  int channelBase,
  int size,
  Map poseData,
  String side,
) {
  List<int>? shoulder = _parsePoint(poseData['${side}Shoulder']);
  List<int>? elbow = _parsePoint(poseData['${side}Elbow']);
  List<int>? wrist = _parsePoint(poseData['${side}Wrist']);

  if (shoulder != null && elbow != null) {
    _tensorDrawLine(tensor, channelBase, size, shoulder, elbow);
  }
  if (elbow != null && wrist != null) {
    _tensorDrawLine(tensor, channelBase, size, elbow, wrist);
  }
}

void _drawHandOnTensor(
  Float32List tensor,
  int channelBase,
  int size,
  List<List<int>> pts,
) {
  const List<List<int>> handConnections = [
    [0, 1],
    [1, 2],
    [2, 3],
    [3, 4],
    [0, 5],
    [5, 6],
    [6, 7],
    [7, 8],
    [5, 9],
    [9, 10],
    [10, 11],
    [11, 12],
    [9, 13],
    [13, 14],
    [14, 15],
    [15, 16],
    [13, 17],
    [17, 18],
    [18, 19],
    [19, 20],
    [0, 17],
  ];

  for (final p in pts) {
    _tensorDrawPoint(tensor, channelBase, size, p[0], p[1]);
  }

  for (final conn in handConnections) {
    final int a = conn[0];
    final int b = conn[1];
    if (a < pts.length && b < pts.length) {
      _tensorDrawLine(tensor, channelBase, size, pts[a], pts[b]);
    }
  }
}

List<int>? _parsePoint(dynamic val) {
  if (val == null) return null;
  return [val[0] as int, val[1] as int];
}

void _tensorDrawPoint(
  Float32List tensor,
  int base,
  int size,
  int x,
  int y, {
  int r = 1,
}) {
  for (int i = -r; i <= r; i++) {
    for (int j = -r; j <= r; j++) {
      if (i * i + j * j <= r * r) {
        final int xi = x + i;
        final int yj = y + j;
        if (xi >= 0 && xi < size && yj >= 0 && yj < size) {
          tensor[base + yj * size + xi] = 1.0;
        }
      }
    }
  }
}

void _tensorDrawLine(
  Float32List tensor,
  int base,
  int size,
  List<int> p1,
  List<int> p2,
) {
  final int dx = (p2[0] - p1[0]).abs();
  final int dy = (p2[1] - p1[1]).abs();
  final int steps = max(dx, dy) + 1;

  for (int i = 0; i < steps; i++) {
    final double t = steps == 1 ? 0.0 : i / (steps - 1);
    final int x = (p1[0] + t * (p2[0] - p1[0])).round();
    final int y = (p1[1] + t * (p2[1] - p1[1])).round();
    _tensorDrawPoint(tensor, base, size, x, y);
  }
}

class TfliteDataSources {
  Interpreter? interpreter;
  List<String> labels = [];

  final int numFrames = 16;
  final int imgSize = 128;

  TfliteDataSources() {
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(
        'assets/model/modelv10.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      print("Model 3D CNN berhasil di load");
      print("   Input : ${interpreter!.getInputTensor(0).shape}");
      print("   Output: ${interpreter!.getOutputTensor(0).shape}");

      final String jsonStr = await rootBundle.loadString(
        'assets/model/label_map.json',
      );
      labels = List<String>.from(json.decode(jsonStr));
      print("Labels: ${labels.length} kelas");
    } catch (e) {
      print("Gagal load: $e");
    }
  }

  Future<Map<String, dynamic>> runInference(String videoPath) async {
    if (interpreter == null || labels.isEmpty) await loadModel();
    if (interpreter == null || labels.isEmpty) {
      throw Exception("Model belum siap!");
    }

    try {
      // ── Step 1: Extract + crop 16 frames
      print("── [1/4] Extract & crop frames ──");
      final List<String> croppedPaths = await _extractAndCropFrames(videoPath);
      if (croppedPaths.isEmpty) {
        return {'label': 'Gagal ekstrak frame', 'confidence': 0.0};
      }
      // ── Step 2: Pose detection (untuk arm skeleton)
      print("── [2/4] Pose detection (arm skeleton) ──");
      final List<Map<String, dynamic>> poseDataList =
          await _detectPoseAllFrames(croppedPaths);

      // ── Step 3: Hand detection (21 titik jari)
      print("── [3/4] Hand landmark detection ──");
      final List<Map<String, dynamic>> handDataList =
          await _detectHandAllFrames(croppedPaths, poseDataList);

      // ── Step 4: Build heatmap tensor di isolate
      print("── [4/4] Build heatmap + inference ──");
      final Float32List flatTensor = await compute(_buildHeatmapTensor, {
        'numFrames': numFrames,
        'imgSize': imgSize,
        'poseDataList': poseDataList,
        'handDataList': handDataList,
      });

      // ── Reshape → nested list [1, 16, 128, 128, 2]
      final List<dynamic> inputTensor = _reshapeToNestedList(flatTensor);

      // ── Multi-run: jalankan 3x, average scores
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

      // ── Sort scores untuk ambil top-2
      final List<MapEntry<int, double>> ranked =
          avgScores.asMap().entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      final int topIdx = ranked[0].key;
      final double topScore = ranked[0].value;
      final double secScore = ranked.length > 1 ? ranked[1].value : 0.0;
      final double gap = topScore - secScore; // selisih skor 1 & 2

      final double confidence = topScore * 100;
      final double gapPct = gap * 100;

      print("✅ Top-1: ${labels[topIdx]} (${confidence.toStringAsFixed(1)}%)");
      print(
        "   Top-2: ${labels[ranked[1].key]} (${(secScore * 100).toStringAsFixed(1)}%)",
      );
      print("   Gap  : ${gapPct.toStringAsFixed(1)}%");

      // Confidence
      return {'label': labels[topIdx], 'confidence': confidence};
    } catch (e) {
      throw Exception("Gagal melakukan inferensi: $e");
    }
  }

  // ── Step 1: Extract raw frames → shoulder crop → resize 128x128
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

    final List<String> sampledPaths = List.generate(numFrames, (i) {
      final int idx = (i * rawFiles.length / numFrames).floor().clamp(
        0,
        rawFiles.length - 1,
      );
      return rawFiles[idx].path;
    });

    // crop dari 3 frame
    final List<int>? cropBox = await _detectShoulderCrop(sampledPaths);

    final List<String> result = [];
    for (int i = 0; i < sampledPaths.length; i++) {
      final String outPath =
          '${cropDir.path}/crop_${i.toString().padLeft(3, '0')}.jpg';
      await _applyCropAndResize(sampledPaths[i], outPath, cropBox);
      result.add(outPath);
    }

    print("   Cropped frames: ${result.length}");
    return result;
  }

  Future<List<int>?> _detectShoulderCrop(List<String> sampledPaths) async {
    // Coba 3 frame: index 0, tengah, terakhir
    final List<int> candidates = [
      0,
      sampledPaths.length ~/ 2,
      sampledPaths.length - 1,
    ];

    final List<List<int>> cropBoxes = [];

    for (final idx in candidates) {
      final box = await _detectShoulderCropFromFrame(sampledPaths[idx]);
      if (box != null) cropBoxes.add(box);
    }

    if (cropBoxes.isEmpty) return null;

    // Ambil median dari setiap koordinat (lebih stabil dari average)
    final List<int> result = List.generate(4, (i) {
      final vals = cropBoxes.map((b) => b[i]).toList()..sort();
      return vals[vals.length ~/ 2];
    });

    print("   Shoulder crop (median dari ${cropBoxes.length} frame): $result");
    return result;
  }

  // ── Deteksi shoulder crop dari frame pertama
  Future<List<int>?> _detectShoulderCropFromFrame(String framePath) async {
    try {
      final detector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.single),
      );
      final poses = await detector.processImage(
        InputImage.fromFilePath(framePath),
      );
      await detector.close();

      if (poses.isEmpty) return null;

      final pose = poses.first;
      final imgBytes = await File(framePath).readAsBytes();
      final decoded = img.decodeImage(imgBytes);
      if (decoded == null) return null;

      final int w = decoded.width;
      final int h = decoded.height;

      final lSh = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rSh = pose.landmarks[PoseLandmarkType.rightShoulder];

      if (lSh == null || rSh == null) {
        final int size = min(w, h);
        return [
          (w - size) ~/ 2,
          (h - size) ~/ 2,
          (w + size) ~/ 2,
          (h + size) ~/ 2,
        ];
      }

      final int cx = ((lSh.x + rSh.x) / 2).round();
      final int cy = ((lSh.y + rSh.y) / 2).round();
      final int shoulderDist = (rSh.x - lSh.x).abs().round();

      if (shoulderDist < 10) return null;

      final int offsetX = (shoulderDist * 1.3).round();
      final int offsetTop = (shoulderDist * 0.9).round();
      final int offsetBottom = (shoulderDist * 2.5).round();
      final int cyShifted = cy + (shoulderDist * -0.6).round();

      return [
        cx - offsetX,
        cyShifted - offsetTop,
        cx + offsetX,
        cyShifted + offsetBottom,
      ];
    } catch (e) {
      print("   Crop frame gagal: $e");
      return null;
    }
  }

  // ── Crop + resize 1 frame
  Future<void> _applyCropAndResize(
    String inputPath,
    String outputPath,
    List<int>? cropBox,
  ) async {
    final Uint8List bytes = await File(inputPath).readAsBytes();
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) return;

    final int w = decoded.width;
    final int h = decoded.height;

    img.Image cropped;

    if (cropBox != null) {
      // Hitung padding kalau box keluar batas
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
    await File(outputPath).writeAsBytes(img.encodeJpg(resized, quality: 90));
  }

  // ── Step 2: Pose detection semua frame
  Future<List<Map<String, dynamic>>> _detectPoseAllFrames(
    List<String> paths,
  ) async {
    final detector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.single),
    );

    final List<Map<String, dynamic>> result = [];

    for (final path in paths) {
      try {
        final poses = await detector.processImage(
          InputImage.fromFilePath(path),
        );
        if (poses.isNotEmpty) {
          result.add(_extractArmPoints(poses.first));
        } else {
          result.add({});
        }
      } catch (_) {
        result.add({});
      }
    }

    await detector.close();
    return result;
  }

  Map<String, dynamic> _extractArmPoints(Pose pose) {
    Map<String, dynamic> data = {};

    void add(String key, PoseLandmarkType type) {
      final lm = pose.landmarks[type];
      // Koordinat sudah pixel di gambar 128x128
      if (lm != null && lm.likelihood > 0.3) {
        data[key] = [
          lm.x.round().clamp(0, imgSize - 1),
          lm.y.round().clamp(0, imgSize - 1),
        ];
      }
    }

    add('lShoulder', PoseLandmarkType.leftShoulder);
    add('rShoulder', PoseLandmarkType.rightShoulder);
    add('lElbow', PoseLandmarkType.leftElbow);
    add('rElbow', PoseLandmarkType.rightElbow);
    add('lWrist', PoseLandmarkType.leftWrist);
    add('rWrist', PoseLandmarkType.rightWrist);

    return data;
  }

  // ── Step 3: Hand detection semua frame
  Future<List<Map<String, dynamic>>> _detectHandAllFrames(
    List<String> paths,
    List<Map<String, dynamic>> poseDataList,
  ) async {
    // Buat satu detector, reuse untuk semua frame
    final HandDetector handDetector = await HandDetector.create(
      performanceConfig: PerformanceConfig.xnnpack(numThreads: 4),
    );

    final List<Map<String, dynamic>> result = [];

    for (int i = 0; i < paths.length; i++) {
      try {
        final Uint8List imgBytes = await File(paths[i]).readAsBytes();
        final List<Hand> hands = await handDetector.detect(imgBytes);

        final Map<String, dynamic> frameData = {};
        final Map poseData = poseDataList[i];

        final List<int>? lWrist = _parsePointFromPose(poseData, 'lWrist');
        final List<int>? rWrist = _parsePointFromPose(poseData, 'rWrist');

        for (final hand in hands.take(2)) {
          if (!hand.hasLandmarks) continue;

          // Ambil 21 titik
          final List<List<int>> pts = hand.landmarks
              .map(
                (lm) => [
                  lm.x.round().clamp(0, imgSize - 1),
                  lm.y.round().clamp(0, imgSize - 1),
                ],
              )
              .toList();

          // Assign kiri/kanan
          // Prioritas: handedness dari detector
          // Fallback: jarak ke wrist dari pose
          String side;
          if (hand.handedness == Handedness.left) {
            side = 'left';
          } else if (hand.handedness == Handedness.right) {
            side = 'right';
          } else {
            // Fallback: hitung jarak center hand ke wrist pose
            final double hx =
                pts.map((p) => p[0]).reduce((a, b) => a + b) / pts.length;
            final double hy =
                pts.map((p) => p[1]).reduce((a, b) => a + b) / pts.length;

            double distL = double.infinity;
            double distR = double.infinity;
            if (lWrist != null) {
              distL = pow(hx - lWrist[0], 2) + pow(hy - lWrist[1], 2) as double;
            }
            if (rWrist != null) {
              distR = pow(hx - rWrist[0], 2) + pow(hy - rWrist[1], 2) as double;
            }
            side = distL < distR ? 'left' : 'right';
          }

          frameData[side] = pts;
        }

        result.add(frameData);
      } catch (_) {
        result.add({});
      }
    }

    await handDetector.dispose();
    return result;
  }

  List<int>? _parsePointFromPose(Map data, String key) {
    if (!data.containsKey(key)) return null;
    final v = data[key];
    return [v[0] as int, v[1] as int];
  }

  // ── Reshape flat Float32List → nested list [1,16,128,128,2]
  List<dynamic> _reshapeToNestedList(Float32List flat) {
    return List.generate(
      1,
      (_) => List.generate(
        numFrames,
        (f) => List.generate(
          imgSize,
          (y) => List.generate(imgSize, (x) {
            final int frameBase = f * imgSize * imgSize * 2;
            final int ch0Idx = frameBase + y * imgSize + x;
            final int ch1Idx = frameBase + imgSize * imgSize + y * imgSize + x;
            return [flat[ch0Idx], flat[ch1Idx]];
          }),
        ),
      ),
    );
  }

  void close() => interpreter?.close();
}
