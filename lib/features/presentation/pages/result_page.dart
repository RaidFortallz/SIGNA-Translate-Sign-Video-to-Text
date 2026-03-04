import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/translation_controller.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';

class ResultPage extends StatelessWidget {
  final controller = Get.find<TranslationController>();

  ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: WarnaApp.wrBlue),
                const SizedBox(height: 24),
                TextCustom(
                  "AI Sedang Menerjemahkan...\nMohon tunggu sebentar.",
                  fontSize: 16,
                  color: WarnaApp.wrTextBlack,
                ),
              ],
            ),
          );
        }

        final data = controller.currentResult.value;

        if (data == null) {
          return Center(
            child: TextCustom(
              "Gagal menerjemahkan video.",
              fontSize: 18,
              color: WarnaApp.wrRed,
            ),
          );
        }

        String formattedDate =
            "${data.timestamp.day.toString().padLeft(2, '0')}-${data.timestamp.month.toString().padLeft(2, '0')}-${data.timestamp.year} | ${data.timestamp.hour.toString().padLeft(2, '0')}:${data.timestamp.minute.toString().padLeft(2, '0')}";

        return Padding(
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
                child: Icon(
                  Icons.play_circle_outline,
                  size: 62,
                  color: WarnaApp.wrWhite,
                ),
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
                child: TextCustom(
                  data.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: WarnaApp.wrTextBlack,
                  letterSpacing: 1,
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
                "Waktu Rekaman: $formattedDate",
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: WarnaApp.wrTextBlack,
              ),
              // TextCustom(
              //   "Sumber: Rekaman Video",
              //   fontSize: 14,
              //   fontWeight: FontWeight.normal,
              //   color: WarnaApp.wrTextBlack,
              // ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
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
                    height: 88,
                    width: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: WarnaApp.wrBlue,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        size: 34,
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
                    height: 88,
                    width: 196,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: WarnaApp.wrBlue,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Center(
                            child: Icon(
                              Icons.videocam_outlined,
                              size: 38,
                              color: WarnaApp.wrWhite,
                            ),
                          ),
                          SizedBox(width: 10),
                          TextCustom(
                            "Rekam Lagi",
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: WarnaApp.wrWhite,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
