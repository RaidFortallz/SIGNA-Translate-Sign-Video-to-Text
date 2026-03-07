import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/translation_controller.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';

class HistoryPage extends StatelessWidget {
  final controller = Get.find<TranslationController>();

  HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.historyList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.historyList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_toggle_off_outlined,
                size: 80.sp,
                color: WarnaApp.wrGrey.withValues(alpha: 0.6),
              ),
              SizedBox(height: 16.h),
              TextCustom(
                "Belum ada riwayat terjemahan.",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: WarnaApp.wrTextBlack,
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.fromLTRB(35.h, 76.h, 35.h, 0.h),
        itemCount: controller.historyList.length,
        separatorBuilder: (context, index) => SizedBox(height: 18.h),
        itemBuilder: (context, index) {
          final item = controller.historyList[index];
          String formattedDate =
              "${item.timestamp.day.toString().padLeft(2, '0')}/${item.timestamp.month.toString().padLeft(2, '0')}/${item.timestamp.year}}";

          String previewText = item.text.length > 15
              ? "${item.text.substring(0, 15)}..."
              : item.text;

          return Container(
            height: 102.w,
            width: double.infinity.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: BoxBorder.all(width: 1.5, color: WarnaApp.wrBlue),
              color: WarnaApp.wrWhite,
            ),
            child: Padding(
              padding: EdgeInsets.all(12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: double.infinity.w,
                    width: 76.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: WarnaApp.wrGrey,
                    ),
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 46.sp,
                      color: WarnaApp.wrWhite,
                    ),
                  ),
                  SizedBox(width: 16.h),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        TextCustom(
                          previewText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: WarnaApp.wrTextBlack,
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextCustom(
                              formattedDate,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: WarnaApp.wrTextBlack,
                            ),
                            TextCustom(" | "),
                            TextCustom(
                              "Akurasi: ${item.accuracy.toStringAsFixed(0)}%",
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: WarnaApp.wrTextBlack,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Center(
                    child: IconButton(
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Hapus Riwayat?",
                          middleText:
                              "Video dan hasil terjemahan akan dihapus.",
                          textConfirm: "Hapus",
                          textCancel: "Batal",
                          confirmTextColor: WarnaApp.wrWhite,
                          buttonColor: WarnaApp.wrRed,
                          cancelTextColor: WarnaApp.wrTextBlack,
                          onConfirm: () {
                            Get.back();
                            controller.deleteHistoryItem(
                              item.id,
                              item.videoPath,
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.highlight_remove_outlined,
                        size: 32.sp,
                        color: WarnaApp.wrRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
