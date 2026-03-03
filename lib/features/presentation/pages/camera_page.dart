import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaApp.wrTextBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.h),
          child: IconButton(
            onPressed: () => Get.offNamed(RouteNames.main),
            icon: Icon(
              Icons.arrow_back_outlined,
              size: 32.sp,
              color: WarnaApp.wrWhite,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.h),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: WarnaApp.wrRed,
                  ),
                ),
                SizedBox(width: 6.h),
                TextCustom(
                  "REC",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: WarnaApp.wrRed,
                  letterSpacing: 1.5,
                ),
                SizedBox(width: 6.h),
                TextCustom(
                  "00:05",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: WarnaApp.wrRed,
                  letterSpacing: 1.5,
                ),
              ],
            ),
          ),
        ],
      ),
      // CAMERA PREVIEW
      body: CameraAwesomeBuilder.custom(
        saveConfig: SaveConfig.video(),
        previewFit: CameraPreviewFit.cover,

        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          flashMode: FlashMode.none,
          aspectRatio: CameraAspectRatios.ratio_16_9,
          // zoom: 0.0,
        ),
        builder: (cameraState, previewSize) {
          bool isRecording = false;
          VoidCallback? onRecordTap;

          cameraState.when(
            onPreparingCamera: (state) => null,
            onPhotoMode: (state) => null,
            onVideoMode: (videoState) {
              isRecording =
              false;
              onRecordTap =
              () => videoState.startRecording();
            },

            onVideoRecordingMode: (recordingState) {
              isRecording =
              true;
              onRecordTap =
              () => recordingState.stopRecording();
            },
          );

          return Column(
            children: [
              Expanded(
                child: cameraState.when(
                  onPreparingCamera: (_) => const Center(
                    child: CircularProgressIndicator(color: WarnaApp.wrRed),
                  ),
                  onVideoMode: (state) => _buildTopOverlay(state),
                  onVideoRecordingMode: (state) => _buildTopOverlay(state),

                  onPhotoMode: (_) => const SizedBox.shrink(),
                ),
              ),
              _buildBottomControls(isRecording: isRecording, onRecordTap: onRecordTap ?? () {})
            ],
          );
        },
      ),
    );
  }
}

Widget _buildTopOverlay(CameraState state) {
  return Stack(
    children: [
      Positioned(
        top: 20,
        left: 16,
        child: StreamBuilder<FlashMode>(
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
                size: 30,
              ),
            );
          },
        ),
      ),

      Positioned(
        top: 20,
        right: 16,
        child: IconButton(
          onPressed: () => state.switchCameraSensor(),
          icon: const Icon(
            Icons.cameraswitch_rounded,
            color: WarnaApp.wrWhite,
            size: 30,
          ),
        ),
      ),
    ],
  );
}

Widget _buildBottomControls({
  required bool isRecording,
  required VoidCallback onRecordTap,
}) {
  return Container(
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isRecording ? 50.w : 60.w,
            height: isRecording ? 50.w : 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius:BorderRadius.circular(isRecording ? 16 : 100),
              color: WarnaApp.wrRed,
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
              child: Icon(
                isRecording
                    ? Icons.stop_rounded
                    : Icons.fiber_manual_record_rounded,
                color: WarnaApp.wrWhite,
                size: 30.sp ,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 14.h),
        TextCustom(
          isRecording ? "Sedang merekam..." :
          "Ketuk untuk mulai rekam",
          fontSize: 14,
          color: WarnaApp.wrTextBlack,
        ),
      ],
    ),
  );
}
