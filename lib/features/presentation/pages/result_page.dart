import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/translation_controller.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';
import 'package:signa_video_to_text/features/presentation/widgets/video_preview_widget.dart';

class ResultPage extends StatelessWidget {
  final controller = Get.find<TranslationController>();

  ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaApp.wrWhite,
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final data = controller.currentResult.value;

        // ── Loading 
        if (isLoading) {
          return Container(
            color: WarnaApp.wrWhite,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie_animation/loading.json',
                    width: 280.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 32.h),
                  TextCustom(
                    "Sedang Menerjemahkan...",
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: WarnaApp.wrTextBlack,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  TextCustom(
                    "Mohon tunggu sebentar.",
                    fontSize: 14,
                    color: WarnaApp.wrGrey,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // ── Error ────────────────────────────────────────────────────────────
        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 72.sp,
                  color: WarnaApp.wrRed.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16.h),
                TextCustom(
                  "Gagal Menerjemahkan Video.",
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: WarnaApp.wrRed,
                ),
                SizedBox(height: 8.h),
                TextCustom(
                  "Coba rekam ulang dengan pencahayaan\nyang lebih baik.",
                  fontSize: 13,
                  color: WarnaApp.wrGrey,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // ── Result ───────────────────────────────────────────────────────────
        return CustomScrollView(
          slivers: [
            // AppBar tipis
            SliverAppBar(
              backgroundColor: WarnaApp.wrWhite,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              toolbarHeight: 56.h,
              title: TextCustom(
                "Hasil Terjemahan",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: WarnaApp.wrTextBlack,
              ),
              centerTitle: true,
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
              ).copyWith(bottom: 32.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Video Preview ────────────────────────────────────────
                  _SectionLabel("Preview Video"),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 200.h,
                    child: VideoPreviewWidget(videoPath: data.videoPath),
                  ),

                  SizedBox(height: 24.h),

                  // ── Hasil terjemahan ─────────────────────────────────────
                  _SectionLabel("Hasil Terjemahan"),
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: WarnaApp.wrOrangeLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextCustom(
                      data.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: WarnaApp.wrTextBlack,
                      textAlign: TextAlign.center,
                      letterSpacing: 0.5,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── Info rekaman ─────────────────────────────────────────
                  _SectionLabel("Informasi Rekaman"),
                  SizedBox(height: 10.h),
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.percent_rounded,
                        label: "Tingkat Akurasi AI",
                        value: "${data.accuracy.toStringAsFixed(1)}%",
                        valueColor: _accuracyColor(data.accuracy),
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.access_time_rounded,
                        label: "Waktu Rekaman",
                        value: _formatDate(data.timestamp),
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: controller.videoSource.value == 'rekam'
                            ? Icons.videocam_outlined
                            : Icons.upload_file_outlined,
                        label: "Sumber",
                        value: controller.videoSource.value == 'rekam'
                            ? "Rekaman Kamera"
                            : "Upload Video",
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        );
      }),

      // ── Bottom Nav ─────────────────────────────────────────────────────────
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value) return const SizedBox.shrink();
        return Container(
          decoration: BoxDecoration(
            color: WarnaApp.wrBody,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h),
          child: Row(
            children: [
              // Tombol back
              GestureDetector(
                onTap: () => Get.offNamed(RouteNames.main),
                child: Container(
                  height: 52.h,
                  width: 52.w,
                  decoration: BoxDecoration(
                    color: WarnaApp.wrBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: WarnaApp.wrBlue.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20.sp,
                    color: WarnaApp.wrBlue,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Tombol rekam lagi
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(RouteNames.record),
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: WarnaApp.wrBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          size: 24.sp,
                          color: WarnaApp.wrWhite,
                        ),
                        SizedBox(width: 10.w),
                        TextCustom(
                          "Rekam Lagi",
                          fontSize: 16,
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
        );
      }),
    );
  }

  Color _accuracyColor(double acc) {
    if (acc >= 90) return Colors.green.shade600;
    if (acc >= 75) return Colors.orange.shade700;
    return WarnaApp.wrRed;
  }

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.year}  "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }
}

// ── Helper widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return TextCustom(
      text,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: WarnaApp.wrGrey,
      letterSpacing: 0.5,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WarnaApp.wrWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: WarnaApp.wrGrey.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: WarnaApp.wrGrey),
          SizedBox(width: 10.w),
          Expanded(
            child: TextCustom(label, fontSize: 13, color: WarnaApp.wrGrey),
          ),
          TextCustom(
            value,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? WarnaApp.wrTextBlack,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 0.5, color: WarnaApp.wrGrey.withValues(alpha: 0.15));
  }
}
