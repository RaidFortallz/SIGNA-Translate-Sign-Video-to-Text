import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/translation_controller.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';

class HomePage extends StatelessWidget {
  final controller = Get.find<TranslationController>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.h),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextCustom(
                  "Selamat Datang Di",
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: WarnaApp.wrTextBlack,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextCustom(
                      "SIGN",
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: WarnaApp.wrBlue,
                    ),
                    TextCustom(
                      "A",
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: WarnaApp.wrOrange,
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                TextCustom(
                  "Mulai rekam video bahasa isyarat \n   untuk melihat terjemahannya",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: WarnaApp.wrTextBlack,
                ),
                SizedBox(height: 44.h),

                InkWell(
                  onTap: () => controller.recordVideo(),
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 96.w,
                    height: 96.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: WarnaApp.wrWhite,
                      boxShadow: [
                        BoxShadow(
                          color: WarnaApp.wrOrange.withValues(alpha: 0.6),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/images/sign.png",
                        height: 87.w,
                        color: WarnaApp.wrOrangeDeep,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 26.h),
                TextCustom("Ketuk untuk mulai rekam", fontSize: 13),
                SizedBox(
                  height: 36.w,
                  width: 192.w,
                  child: Divider(
                    thickness: 3,
                    color: WarnaApp.wrGrey.withValues(alpha: 0.3),
                  ),
                ),

                IconButton(
                  onPressed: controller.uploadVideo,
                  icon: Icon(
                    Icons.drive_folder_upload,
                    size: 53.sp,
                    color: WarnaApp.wrOrange,
                  ),
                ),
                TextCustom(
                  "Upload Video",
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 44.w,
          width: 74.w,
          child: IconButton(
            onPressed: () {
              Get.snackbar("Info", "Posisikan tubuh di tengah kamera saat merekam.");
            },
            icon: Icon(Icons.info_outline_rounded, size: 32),
            color: WarnaApp.wrBlue,
            splashRadius: 24,
          ),
        ),
      ],
    );
  }
}
