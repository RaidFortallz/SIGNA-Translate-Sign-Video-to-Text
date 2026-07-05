import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/translation_controller.dart';
import 'package:signa_video_to_text/features/presentation/controllers/trim_video_controller.dart';
import 'package:signa_video_to_text/features/presentation/tutorial/app_tutorial_controller.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TrimEditVideoPage extends StatefulWidget {
  const TrimEditVideoPage({super.key});

  @override
  State<TrimEditVideoPage> createState() => _TrimEditVideoPageState();
}

class _TrimEditVideoPageState extends State<TrimEditVideoPage> {
  late final TrimVideoController controller;

  final GlobalKey _videoPreviewKey = GlobalKey();
  final GlobalKey _progressBarKey = GlobalKey();
  final GlobalKey _segmentChipKey = GlobalKey();
  final GlobalKey _addSegmentKey = GlobalKey();
  final GlobalKey _sliderKey = GlobalKey();
  final GlobalKey _translateKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = Get.put(TrimVideoController());

    final tutCtrl = Get.find<AppTutorialController>();
    if (tutCtrl.isTutorialMode.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _showTrimTutorial();
        });
      });
    }
  }

  void _showTrimTutorial() {
    final tutCtrl = Get.find<AppTutorialController>();
    const total = 6;

    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'trim_preview',
          keyTarget: _videoPreviewKey,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          paddingFocus: 6,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (ctx, ctrl) => AppTutorialController.buildCard(
                ctrl: ctrl,
                emoji: '🎬',
                title: 'Preview Video',
                description:
                    'Area ini menampilkan video rekaman kamu. Ketuk ▶ untuk memutar dan cek gerakan isyarat yang sudah direkam.',
                step: 1,
                total: total,
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'trim_progress',
          keyTarget: _progressBarKey,
          shape: ShapeLightFocus.RRect,
          radius: 4,
          paddingFocus: 10,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (ctx, ctrl) => AppTutorialController.buildCard(
                ctrl: ctrl,
                emoji: '📊',
                title: 'Progress Bar Segmen',
                description:
                    'Bar ini menampilkan posisi semua segmen dalam video. Merah = segmen aktif yang sedang diedit, Biru = segmen lainnya. Garis putih = posisi putar saat ini.',
                step: 2,
                total: total,
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'trim_chip',
          keyTarget: _segmentChipKey,
          shape: ShapeLightFocus.RRect,
          radius: 20,
          paddingFocus: 8,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (ctx, ctrl) => AppTutorialController.buildCard(
                ctrl: ctrl,
                emoji: '🏷️',
                title: 'Marker Gerakan (Kata)',
                description:
                    'Setiap chip adalah satu kata/gerakan isyarat. Ketuk untuk memilih dan mengatur batas waktu gerakan tersebut. Tombol × untuk menghapus segmen.',
                step: 3,
                total: total,
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'trim_add',
          keyTarget: _addSegmentKey,
          shape: ShapeLightFocus.RRect,
          radius: 20,
          paddingFocus: 8,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (ctx, ctrl) => AppTutorialController.buildCard(
                ctrl: ctrl,
                emoji: '➕',
                title: 'Tambah Gerakan Baru',
                description:
                    'Jika video berisi lebih dari satu kata isyarat, ketuk ini untuk menambah segmen baru. Tiap segmen akan diterjemahkan secara terpisah lalu digabung jadi kalimat.',
                step: 4,
                total: total,
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'trim_slider',
          keyTarget: _sliderKey,
          shape: ShapeLightFocus.RRect,
          radius: 8,
          paddingFocus: 10,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (ctx, ctrl) => AppTutorialController.buildCard(
                ctrl: ctrl,
                emoji: '⏱️',
                title: 'Atur Rentang Waktu',
                description:
                    'Geser ujung kiri untuk waktu mulai gerakan, ujung kanan untuk waktu selesai. Preview video akan mengikuti posisi slider secara real-time.',
                step: 5,
                total: total,
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'trim_translate',
          keyTarget: _translateKey,
          shape: ShapeLightFocus.RRect,
          radius: 14,
          paddingFocus: 6,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (ctx, ctrl) => AppTutorialController.buildCard(
                ctrl: ctrl,
                emoji: '🤖',
                title: 'Terjemahkan Isyarat',
                description:
                    'Setelah semua segmen ditandai dan diatur, ketuk tombol ini. Model AI SIGNA akan memproses setiap gerakan dan menghasilkan terjemahan teks BISINDO.',
                step: 6,
                total: total,
              ),
            ),
          ],
        ),
      ],
      colorShadow: WarnaApp.wrBlack,
      opacityShadow: 0.85,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 350),
      unFocusAnimationDuration: const Duration(milliseconds: 300),
      alignSkip: Alignment.topRight,
      skipWidget: Container(
        margin: EdgeInsets.only(top: 52.h, right: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: WarnaApp.wrWhite.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: WarnaApp.wrWhite.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: TextCustom(
          "Lewati",
          fontSize: 12,
          color: WarnaApp.wrWhite,
          fontWeight: FontWeight.w500,
        ),
      ),
      onFinish: () {
        tutCtrl.endTutorial();
        Get.offAllNamed(RouteNames.main);
      },
      onSkip: () {
        tutCtrl.endTutorial();
        Get.offAllNamed(RouteNames.main);
        return true;
      },
    ).show(context: context);
  }

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
                    onTap: () {
                      final transCtrl = Get.find<TranslationController>();
                      if (transCtrl.videoSource.value == 'upload') {
                        Get.offNamed(RouteNames.main);
                      } else {
                        Get.offNamed(RouteNames.record);
                      }
                    },
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
                  key: _videoPreviewKey,
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
              final int totalMs = controller.duration.value.inMilliseconds;
              final int activeIdx = controller.activeSegmentIdx.value;
              final RangeValues activeSeg = controller.activeSegment;

              final Duration startDur = Duration(
                milliseconds: (activeSeg.start * totalMs).round(),
              );
              final Duration endDur = Duration(
                milliseconds: (activeSeg.end * totalMs).round(),
              );
              final double selectedSec =
                  (endDur - startDur).inMilliseconds / 1000.0;
              final double posRatio = totalMs == 0
                  ? 0.0
                  : controller.isDragging.value
                  ? controller.dragSeekRatio.value
                  : (controller.position.value.inMilliseconds / totalMs).clamp(
                      0.0,
                      1.0,
                    );

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
                    // ── Label instruksi ────────────────────────────────────────────
                    Row(
                      children: [
                        Icon(
                          Icons.content_cut_rounded,
                          color: WarnaApp.wrOrange,
                          size: 14.sp,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: TextCustom(
                            controller.segments.length == 1
                                ? "Atur segmen, atau tambah segmen baru per gerakan"
                                : "${controller.segments.length} segmen → akan digabung jadi kalimat",
                            fontSize: 11,
                            color: WarnaApp.wrWhite.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // ── Progress bar: semua segmen ditampilkan ─────────────────────
                    LayoutBuilder(
                      key: _progressBarKey,
                      builder: (context, constraints) {
                        final double w = constraints.maxWidth;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Track background
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                height: 5.h,
                                color: WarnaApp.wrWhite.withValues(alpha: 0.1),
                              ),
                            ),

                            // Semua segmen
                            ...controller.segments.asMap().entries.map((entry) {
                              final bool isActive = entry.key == activeIdx;
                              final double left = entry.value.start * w;
                              final double width =
                                  (entry.value.end - entry.value.start) * w;
                              return Positioned(
                                left: left,
                                width: width.clamp(2.0, w),
                                top: 0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    height: 5.h,
                                    color: isActive
                                        ? WarnaApp.wrRed
                                        : WarnaApp.wrBlue.withValues(
                                            alpha: 0.55,
                                          ),
                                  ),
                                ),
                              );
                            }),

                            // Playhead
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

                    SizedBox(height: 12.h),

                    // ── Segment chips + tombol tambah ──────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: controller.segmentScrollController,
                      child: Row(
                        children: [
                          ...controller.segments.asMap().entries.map((entry) {
                            final int idx = entry.key;
                            final bool isActive = idx == activeIdx;
                            return GestureDetector(
                              key: idx == 0 ? _segmentChipKey : null,
                              onTap: () => controller.setActiveSegment(idx),
                              child: Container(
                                margin: EdgeInsets.only(right: 8.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? WarnaApp.wrRed.withValues(alpha: 0.15)
                                      : WarnaApp.wrWhite.withValues(
                                          alpha: 0.05,
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isActive
                                        ? WarnaApp.wrRed.withValues(alpha: 0.6)
                                        : WarnaApp.wrWhite.withValues(
                                            alpha: 0.15,
                                          ),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextCustom(
                                      "Kata ${idx + 1}",
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? WarnaApp.wrRed
                                          : WarnaApp.wrWhite.withValues(
                                              alpha: 0.6,
                                            ),
                                    ),
                                    if (controller.segments.length > 1) ...[
                                      SizedBox(width: 5.w),
                                      GestureDetector(
                                        onTap: () =>
                                            controller.removeSegment(idx),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 13.sp,
                                          color: isActive
                                              ? WarnaApp.wrRed.withValues(
                                                  alpha: 0.8,
                                                )
                                              : WarnaApp.wrWhite.withValues(
                                                  alpha: 0.35,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Tombol + tambah segmen
                          GestureDetector(
                            key: _addSegmentKey,
                            onTap: controller.addSegment,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: WarnaApp.wrWhite.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: WarnaApp.wrWhite.withValues(
                                    alpha: 0.15,
                                  ),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    size: 13.sp,
                                    color: WarnaApp.wrWhite.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  TextCustom(
                                    "Tambah",
                                    fontSize: 11,
                                    color: WarnaApp.wrWhite.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // ── RangeSlider untuk segmen aktif ─────────────────────────────
                    SliderTheme(
                      key: _sliderKey,
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
                        values: activeSeg,
                        min: 0.0,
                        max: 1.0,
                        onChanged: controller.updateActiveSegment,
                        onChangeStart: (_) {
                          controller.player.pause();
                          controller.startDragging();
                        },
                        onChangeEnd: (_) {
                          controller.stopDragging();
                        },
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // ── Timestamps segmen aktif ────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _TimeChip(
                          label: "Mulai",
                          time: controller.formatDuration(startDur),
                        ),
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
                            "${selectedSec.toStringAsFixed(1)}s",
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: WarnaApp.wrRed,
                          ),
                        ),
                        _TimeChip(
                          label: "Selesai",
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
                  key: _translateKey,
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
