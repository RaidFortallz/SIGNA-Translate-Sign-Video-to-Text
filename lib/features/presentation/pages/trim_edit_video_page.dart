import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/trim_video_controller.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';

class TrimEditVideoPage extends StatelessWidget {
  final TrimVideoController controller = Get.put(TrimVideoController());

  TrimEditVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaApp.wrTextBlack,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.offNamed(RouteNames.record),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: WarnaApp.wrRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: WarnaApp.wrRed.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: TextCustom(
                        "Batal",
                        color: WarnaApp.wrRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextCustom(
                    "Sesuaikan Gerakan",
                    color: WarnaApp.wrWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(width: 70.w),
                ],
              ),
            ),

            //VIDEO PREVIEW
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      Video(
                        controller: controller.videoController,
                        fit: BoxFit.contain,
                        controls: NoVideoControls,
                      ),

                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.2),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Obx(
                        () => GestureDetector(
                          onTap: controller.togglePlay,
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: controller.isPlaying.value
                                ? const SizedBox.shrink(key: ValueKey('on'))
                                : Container(
                                    key: const ValueKey('off'),
                                    width: 58.w,
                                    height: 58.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      border: Border.all(
                                        color: WarnaApp.wrWhite.withValues(
                                          alpha: 0.25,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: WarnaApp.wrWhite,
                                      size: 34.sp,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // TRIM CONTROL
            Obx(() {
              final totalMs = controller.duration.value.inMilliseconds;
              final startDur = Duration(
                milliseconds: (controller.trimRange.value.start * totalMs)
                    .round(),
              );
              final endDur = Duration(
                milliseconds: (controller.trimRange.value.end * totalMs)
                    .round(),
              );
              final selectedSec = (endDur - startDur).inMilliseconds / 1000.0;
              final posRatio = totalMs == 0
                  ? 0.0
                  : (controller.position.value.inMilliseconds /
                        totalMs).clamp(0.0, 1.0);
              final startRatio = controller.trimRange.value.start;
              final endRatio = controller.trimRange.value.end;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: WarnaApp.wrWhite.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: WarnaApp.wrWhite.withValues(alpha: 0.08),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // label intruksi
                    Row(
                      children: [
                        Icon(
                          Icons.content_cut_rounded,
                          color: WarnaApp.wrOrange,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),

                        Expanded(
                          child: TextCustom(
                            "Potong bagian diam, sisakan gerakan isyarat saja",
                            fontSize: 11,
                            color: WarnaApp.wrWhite.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Progres saat ini
                    //Progress bar dengan trim zone highlight
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double w = constraints.maxWidth;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                height: 5.h,
                                color: WarnaApp.wrWhite.withValues(alpha: 0.1),
                              ),
                            ),
                            // Zona trim (highlight antara start–end)
                            Positioned(
                              left: startRatio * w,
                              width: (endRatio - startRatio) * w,
                              top: 0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  height: 5.h,
                                  color: WarnaApp.wrRed.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                            Positioned(
                              left: (posRatio * w - 1).clamp(0, w - 2),
                              top: -2.h,
                              child: Container(
                                width: 2.5,
                                height: 9.h,
                                decoration: BoxDecoration(
                                  color: WarnaApp.wrWhite,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 16.h),

                    // Range Slider
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: WarnaApp.wrRed,
                        inactiveTrackColor: WarnaApp.wrWhite.withValues(
                          alpha: 0.15,
                        ),
                        thumbColor: WarnaApp.wrWhite,
                        overlayColor: WarnaApp.wrRed.withValues(alpha: 0.15),
                        rangeThumbShape: const RoundRangeSliderThumbShape(
                          enabledThumbRadius: 10,
                          disabledThumbRadius: 8,
                        ),
                        rangeTrackShape:
                            const RoundedRectRangeSliderTrackShape(),
                        trackHeight: 4.h,
                        minThumbSeparation: 20,
                      ),
                      child: RangeSlider(
                        values: controller.trimRange.value,
                        min: 0.0,
                        max: 1.0,
                        onChanged: controller.updateTrimRange,
                        onChangeStart: (values) {
                          controller.player.pause();
                        },
                        onChangeEnd: (values) {
                          final int ms =
                              (values.start *
                                      controller.duration.value.inMilliseconds)
                                  .round();
                          controller.player.seek(Duration(milliseconds: ms));
                        },
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // TimeStamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _TimeChip(
                          label: "Mulai",
                          time: controller.formatDuration(startDur),
                        ),
                        // Durasi Segmen
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: WarnaApp.wrRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextCustom(
                            "${selectedSec.toStringAsFixed(1)}s dipilih",
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: WarnaApp.wrRed,
                          ),
                        ),
                        _TimeChip(
                          label: "selesai",
                          time: controller.formatDuration(endDur),
                          alignEnd: true,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 16.h),

            Obx(
              () => Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 28.h),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaApp.wrBlue,
                    disabledBackgroundColor: WarnaApp.wrBlue.withValues(
                      alpha: 0.5,
                    ),
                    minimumSize: Size(double.infinity, 52.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: controller.isSaving.value
                      ? null
                      : () => controller.saveAndTranslate(),
                  child: controller.isSaving.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18.h,
                              width: 18.h,
                              child: const CircularProgressIndicator(
                                color: WarnaApp.wrWhite,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            TextCustom(
                              "Memproses...",
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: WarnaApp.wrWhite,
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: WarnaApp.wrWhite,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            TextCustom(
                              "Terjemahkan Isyarat",
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: WarnaApp.wrWhite,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget Time Chip
class _TimeChip extends StatelessWidget {
  final String label;
  final String time;
  final bool alignEnd;
  const _TimeChip({
    required this.label,
    required this.time,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        TextCustom(
          label,
          fontSize: 10,
          color: WarnaApp.wrWhite.withValues(alpha: 0.4),
          fontWeight: FontWeight.w500,
        ),
        TextCustom(
          time,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: WarnaApp.wrWhite.withValues(alpha: 0.85),
        ),
      ],
    );
  }
}
