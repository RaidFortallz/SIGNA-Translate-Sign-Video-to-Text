import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final data = controller.currentResult.value;

        
        return Stack(
          children: [
            if (!isLoading && data != null)
            Padding(
            padding: const EdgeInsets.fromLTRB(24, 78, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  "Preview: ",
                  fontSize: 26,
                  fontWeight: FontWeight.normal,
                  color: WarnaApp.wrTextBlack,
                ),
                SizedBox(height: 8),
                Container(
                  height: 184,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: WarnaApp.wrGrey,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: VideoPreviewWidget(videoPath: data.videoPath),
                ),
                SizedBox(height: 38),
                Center(
                  child: TextCustom(
                    "Hasil Terjemahan Video ke Teks",
                    fontSize: 19,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  // height: 114,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: WarnaApp.wrOrangeLight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextCustom(
                      data.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: WarnaApp.wrTextBlack,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextCustom(
                  "Informasi Rekaman: ",
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: WarnaApp.wrTextBlack,
                ),
          
                SizedBox(height: 8),
          
                TextCustom(
                  "Tingkat Akurasi AI: ${data.accuracy.toStringAsFixed(1)}%",
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: WarnaApp.wrTextBlack,
                ),
                SizedBox(height: 4),
          
                TextCustom(
                  "Waktu Rekaman: ${_formatDate(data.timestamp)}",
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: WarnaApp.wrTextBlack,
                ),
                SizedBox(height: 4,),
                TextCustom(
                  "Sumber: ${controller.videoSource.value == 'rekam' ? 'Rekaman Video' : 'Video Upload'}",
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: WarnaApp.wrTextBlack,
                ),
              ],
            ),
          ),

          if (!isLoading && data == null)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_outlined,
                  size: 80.sp,
                  color: WarnaApp.wrGrey.withValues(alpha: 0.6),
                  
                ),
                SizedBox(height: 16.h,),
                TextCustom(
                  "Gagal Menerjemahkan Video.",
                  fontSize: 18, color: WarnaApp.wrRed,
                )
              ],
            ),
          ),

          if (isLoading)
          Container(
            color: WarnaApp.wrWhite,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      color: WarnaApp.wrBlue,
                      backgroundColor: WarnaApp.wrBlue.withValues(alpha: 0.2),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 24,),
                  TextCustom(
                    "AI Sedang Menerjemahkan...\nMohon tunggu sebentar.",
                    fontSize: 16, color: WarnaApp.wrTextBlack,
                  )
                ],
              ),
            ),
          ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value) return const SizedBox.shrink();


        return Container(
              height: 124,
              width: double.infinity,
              decoration: BoxDecoration(color: WarnaApp.wrBody),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 26),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                      child: GestureDetector(
                        onTap: () => Get.offNamed(RouteNames.main),
                        child: Container(
                          height: 52,
                          width: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: WarnaApp.wrBlue,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_outlined,
                              size: 22,
                              color: WarnaApp.wrWhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
                      child: GestureDetector(
                        onTap: () => Get.toNamed(RouteNames.record),
                        child: Container(
                          height: 52,
                          width: 196,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: WarnaApp.wrBlue,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam_outlined,
                                size: 30,
                                color: WarnaApp.wrWhite,
                              ),
                              SizedBox(width: 14),
                              TextCustom(
                                "Rekam Lagi",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
  }),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} | ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
