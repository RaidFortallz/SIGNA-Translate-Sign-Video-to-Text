import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/translation_controller.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final controller = Get.find<TranslationController>();
  bool _isProcessing = false;
  SensorPosition _currentSensor = SensorPosition.back;

  final ValueNotifier<int> _durationNotifer = ValueNotifier(0);
  final ValueNotifier<bool> _blinkNotifier = ValueNotifier(true);
  final ValueNotifier<double> _brightnessNotifier = ValueNotifier(0.0);
  Timer? _timer;
  int _ticks = 0; //buat hitung putaran timer

  late SensorConfig _sensorConfig;

  @override
  void initState() {
    super.initState();
    _initSensorConfig();
  }

  void _initSensorConfig() {
    _sensorConfig = SensorConfig.single(
      sensor: Sensor.position(_currentSensor),
      flashMode: FlashMode.none,
      aspectRatio: CameraAspectRatios.ratio_16_9,
    );
    // Reset brightness ke 0 tiap kali sensor berganti
    _brightnessNotifier.value = 0.0;
  }

  // Panggil setBrightness langsung ke sensorConfig yang tersimpan
  void _applyBrightness(double val) {
    _brightnessNotifier.value = val;
    _sensorConfig.setBrightness(val);
  }

  void _startTimer() {
    _durationNotifer.value = 0;
    _blinkNotifier.value = true;
    _ticks = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _blinkNotifier.value = !_blinkNotifier.value;
      _ticks++;

      if (_ticks % 2 == 0) _durationNotifer.value++;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _blinkNotifier.value = false;
  }

  String _formatDuration(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _stopTimer();
    _durationNotifer.dispose();
    _blinkNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey(_currentSensor),
      backgroundColor: WarnaApp.wrTextBlack,
      // CAMERA PREVIEW
      body: CameraAwesomeBuilder.custom(
        enablePhysicalButton: true,
        mirrorFrontCamera: true,
        saveConfig: SaveConfig.video(),
        filter: AwesomeFilter.None,
        previewFit: CameraPreviewFit.contain,
        sensorConfig: _sensorConfig,

        progressIndicator: const Center(
          child: CircularProgressIndicator(color: WarnaApp.wrRed),
        ),
        onPreviewTapBuilder: (state) => OnPreviewTap(
          onTap: (position, flutterPreviewSize, pixelPreviewSize) {
            state.when(
              onVideoMode: (s) => s.focusOnPoint(
                flutterPosition: position,
                pixelPreviewSize: pixelPreviewSize,
                flutterPreviewSize: flutterPreviewSize,
              ),
              onVideoRecordingMode: (s) => s.focusOnPoint(
                flutterPosition: position,
                pixelPreviewSize: pixelPreviewSize,
                flutterPreviewSize: flutterPreviewSize,
              ),
            );
          },
        ),

        onPreviewScaleBuilder: (state) =>
            OnPreviewScale(onScale: (scale) => _sensorConfig.setZoom(scale)),

        onMediaCaptureEvent: (event) {
          if (_isProcessing) return;
          if (event.status == MediaCaptureStatus.success &&
              event.isPicture == false) {
            event.captureRequest.when(
              single: (single) {
                final videoPath = single.file?.path;
                if (videoPath != null) {
                  _isProcessing = true;
                  controller.videoSource.value = 'rekam';
                  controller.isFrontCamera.value =
                      _currentSensor == SensorPosition.front;

                  Get.offNamed(RouteNames.trim, arguments: videoPath);
                }
              },
              multiple: (multiple) => null,
            );
          }
        },

        builder: (cameraState, previewSize) {
          bool isRecording = false;
          VoidCallback? onRecordTap;

          cameraState.when(
            onPreparingCamera: (state) => null,
            onPhotoMode: (state) => null,
            onVideoMode: (videoState) {
              isRecording = false;
              onRecordTap = () {
                videoState.startRecording();
                _startTimer();
              };
            },

            onVideoRecordingMode: (recordingState) {
              isRecording = true;
              onRecordTap = () {
                if (_durationNotifer.value < 2) {
                  Get.snackbar(
                    "Terlalu Singkat",
                    "Durasi rekaman minimal 2 detik",
                    backgroundColor: WarnaApp.wrRed,
                    colorText: WarnaApp.wrWhite,
                  );
                  return;
                }
                recordingState.stopRecording();
                _stopTimer();
              };
            },
          );

          return Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isRecording)
                        AwesomeOrientedWidget(
                          child: Center(
                            child: Container(
                              width: 46.w,
                              height: 46.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: WarnaApp.wrGrey.withValues(alpha: 0.3),
                                ),
                                borderRadius: BorderRadius.circular(16),
                                color: WarnaApp.wrTextBlack,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => Get.offNamed(RouteNames.main),
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 32.sp,
                                  color: WarnaApp.wrWhite,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(width: 46.w),

                      if (isRecording)
                        AwesomeOrientedWidget(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: WarnaApp.wrGrey.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(13),
                              color: WarnaApp.wrTextBlack,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ValueListenableBuilder<bool>(
                                  valueListenable: _blinkNotifier,
                                  builder: (context, isBlinking, _) {
                                    return Opacity(
                                      opacity: (isRecording && isBlinking)
                                          ? 1.0
                                          : 0.0,
                                      child: Container(
                                        width: 12.w,
                                        height: 12.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: WarnaApp.wrRedAccent,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 10.w),
                                TextCustom(
                                  "REC",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: WarnaApp.wrWhite,
                                  letterSpacing: 1.7,
                                ),
                                SizedBox(width: 10.h),
                                ValueListenableBuilder<int>(
                                  valueListenable: _durationNotifer,
                                  builder: (context, duration, _) {
                                    return TextCustom(
                                      _formatDuration(duration),
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: WarnaApp.wrWhite,
                                      letterSpacing: 1.5,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        const SizedBox(),

                      Row(
                        children: [
                          AwesomeOrientedWidget(
                            child: Container(
                              width: 46.w,
                              height: 46.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: WarnaApp.wrGrey.withValues(alpha: 0.3),
                                ),
                                borderRadius: BorderRadius.circular(13),
                                color: WarnaApp.wrTextBlack,
                              ),
                              child: cameraState.when(
                                onPreparingCamera: (_) =>
                                    const SizedBox(width: 40),
                                onPhotoMode: (_) => const SizedBox(width: 40),
                                onVideoMode: (state) =>
                                    _buildFlashButton(state),
                                onVideoRecordingMode: (state) =>
                                    _buildFlashButton(state),
                              ),
                            ),
                          ),
                          SizedBox(width: 18.w),

                          AwesomeOrientedWidget(
                            child: Container(
                              width: 46.w,
                              height: 46.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: WarnaApp.wrGrey.withValues(alpha: 0.3),
                                ),
                                borderRadius: BorderRadius.circular(13),
                                color: WarnaApp.wrTextBlack,
                              ),
                              child: cameraState.when(
                                onPreparingCamera: (_) =>
                                    const SizedBox(width: 40),
                                onPhotoMode: (_) => const SizedBox(width: 40),
                                onVideoMode: (state) => IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    // state.switchCameraSensor();
                                    setState(() {
                                      _currentSensor =
                                          _currentSensor == SensorPosition.back
                                          ? SensorPosition.front
                                          : SensorPosition.back;
                                      _initSensorConfig();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.cameraswitch_rounded,
                                    color: WarnaApp.wrWhite,
                                    size: 26,
                                  ),
                                ),
                                onVideoRecordingMode: (_) => IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: null,
                                  icon: Icon(
                                    Icons.cameraswitch_rounded,
                                    color: WarnaApp.wrGrey,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              //AREA GESTURE FOCUS & FRAMING GUIDE
              Expanded(
                child: ClipRRect(
                  child: Stack(
                    children: [
                      if (!isRecording)
                        Center(
                          child: IgnorePointer(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              height: MediaQuery.of(context).size.height * 0.45,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: WarnaApp.wrWhite.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: WarnaApp.wrTextBlack.withValues(
                                    alpha: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextCustom(
                                  "Posisikan badan & tangan di area ini",
                                  fontSize: 12,
                                  color: WarnaApp.wrWhite.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (!isRecording)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 4.h,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.brightness_low,
                        color: WarnaApp.wrWhite.withValues(alpha: 0.5),
                        size: 18.sp,
                      ),
                      Expanded(
                        child: ValueListenableBuilder<double>(
                          valueListenable: _brightnessNotifier,
                          builder: (context, brightness, _) => SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: WarnaApp.wrWhite.withValues(
                                alpha: 0.6,
                              ),
                              inactiveTrackColor: WarnaApp.wrWhite.withValues(
                                alpha: 0.15,
                              ),
                              thumbColor: WarnaApp.wrWhite,
                              overlayShape: SliderComponentShape.noOverlay,
                              trackHeight: 2.h,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 6.r,
                              ),
                            ),
                            child: Slider(
                              value: brightness,
                              min: -1.0,
                              max: 1.0,
                              onChanged: _applyBrightness,
                              onChangeEnd: _applyBrightness,
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.brightness_high,
                        color: WarnaApp.wrWhite.withValues(alpha: 0.5),
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              _buildBottomControls(
                isRecording: isRecording,
                onRecordTap: onRecordTap ?? () {},
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _buildFlashButton(CameraState state) {
  return StreamBuilder<FlashMode>(
    stream: state.sensorConfig.flashMode$,
    builder: (context, snapshot) {
      final isFlashOn = snapshot.data == FlashMode.always;
      return IconButton(
        onPressed: () {
          state.sensorConfig.setFlashMode(
            isFlashOn ? FlashMode.none : FlashMode.always,
          );
        },
        icon: Icon(
          isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          color: isFlashOn ? Colors.yellow : WarnaApp.wrWhite,
          size: 26,
        ),
      );
    },
  );
}

Widget _buildBottomControls({
  required bool isRecording,
  required VoidCallback onRecordTap,
}) {
  return Container(
    height: 160.h,
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 38.h),
    decoration: const BoxDecoration(
      color: WarnaApp.wrBody,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(34),
        topRight: Radius.circular(34),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onRecordTap,
          child: Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: WarnaApp.wrWhite, width: 4),
              boxShadow: [
                BoxShadow(
                  color: WarnaApp.wrRed.withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isRecording ? 26.w : 52.w,
                height: isRecording ? 26.w : 52.w,
                decoration: BoxDecoration(
                  color: WarnaApp.wrRed,
                  borderRadius: BorderRadius.circular(isRecording ? 6 : 100),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 14.h),
        SizedBox(
          height: 20.h,
          child: TextCustom(
            isRecording ? "Sedang merekam..." : "Ketuk untuk mulai rekam",
            fontSize: 14,
            color: WarnaApp.wrTextBlack,
          ),
        ),
      ],
    ),
  );
}
