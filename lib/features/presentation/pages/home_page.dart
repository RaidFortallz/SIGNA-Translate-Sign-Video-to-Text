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
                  fontSize: 18,
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
                  "Terjemahkan gerakan bahasa isyarat BISINDO \n   menjadi teks secara otomatis",
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
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
                GestureDetector(
                  onTap: () => controller.recordVideo(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: WarnaApp.wrOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: WarnaApp.wrOrange.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: TextCustom(
                      "Ketuk untuk mulai rekam",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: WarnaApp.wrOrangeDeep,
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: WarnaApp.wrOrange.withValues(alpha: 0.6),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: TextCustom(
                        "atau",
                        fontSize: 12,
                        color: WarnaApp.wrGrey.withValues(alpha: 0.5),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: WarnaApp.wrOrange.withValues(alpha: 0.6),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                IconButton(
                  onPressed: controller.uploadVideo,
                  icon: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [WarnaApp.wrOrange, WarnaApp.wrBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Icon(
                      Icons.drive_folder_upload,
                      size: 53.sp,
                      color: WarnaApp.wrOrange,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.uploadVideo(),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: WarnaApp.wrWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: WarnaApp.wrBlue.withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: WarnaApp.wrOrange.withValues(alpha: 0.14),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: TextCustom(
                        "Upload Video",
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: WarnaApp.wrBlue,
                      ),
                    ),
                  ),
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
              Get.snackbar(
                "Tips Merekam",
                "Pastikan gerakan tangan dan isyarat terlihat jelas di dalam frame kamera.",
                backgroundColor: WarnaApp.wrWhite,
                colorText: WarnaApp.wrTextBlack,
                snackPosition: SnackPosition.TOP,
                margin: EdgeInsets.only(top: 24.h, left: 16.w, right: 16.w),
                borderRadius: 16,
                borderWidth: 1.3,
                borderColor: WarnaApp.wrBlue,
                icon: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: WarnaApp.wrOrange,
                  size: 38.sp,
                ),
                shouldIconPulse: true,
                boxShadows: [
                  BoxShadow(
                    color: WarnaApp.wrBlue.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                ],
                duration: const Duration(seconds: 3),
                animationDuration: const Duration(milliseconds: 500),
                forwardAnimationCurve: Curves.easeOutBack,
              );
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
