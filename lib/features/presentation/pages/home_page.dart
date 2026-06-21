import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/translation_controller.dart';
import 'package:signa_video_to_text/features/presentation/tutorial/app_tutorial_controller.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Get.find<TranslationController>();

  final GlobalKey _recordKey = GlobalKey();
  final GlobalKey _uploadKey = GlobalKey();

  void _showHomeTutorial() {
    final tutCtrl = Get.find<AppTutorialController>();
    const total = 2;

    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'home_record',
          keyTarget: _recordKey,
          shape: ShapeLightFocus.Circle,
          paddingFocus: 12,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (ctx, ctrl) => AppTutorialController.buildCard(
                ctrl: ctrl,
                emoji: '🎥',
                title: 'Rekam Video Langsung',
                description:
                    'Ketuk tombol ini untuk membuka kamera dan merekam gerakan bahasa isyarat BISINDO secara langsung.',
                step: 1,
                total: total,
                alwaysShowNext: true,
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'home_upload',
          keyTarget: _uploadKey,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          paddingFocus: 8,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (ctx, ctrl) => AppTutorialController.buildCard(
                ctrl: ctrl,
                emoji: '📁',
                title: 'Upload Video BISINDO',
                description:
                    'Sudah punya video? Pilih video BISINDO dari galeri perangkat untuk diterjemahkan oleh AI SIGNA.',
                step: 2,
                total: total,
                alwaysShowNext: true,
              ),
            ),
          ],
        ),
      ],
      colorShadow: WarnaApp.wrBlack,
      opacityShadow: 0.85,
      paddingFocus: 10,
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
        tutCtrl.startTutorial();
        Get.toNamed(RouteNames.trim, arguments: '__tutorial__');
      },
      onSkip: () {
        return true;
      },
    ).show(context: context);
  }

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
                  "Terjemahkan gerakan bahasa isyarat BISINDO menjadi teks secara otomatis",
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: WarnaApp.wrTextBlack,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 44.h),

                InkWell(
                  key: _recordKey,
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
                    key: _uploadKey,
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
            onPressed: _showHomeTutorial,
            icon: Icon(Icons.info_outline_rounded, size: 32),
            color: WarnaApp.wrBlue,
            splashRadius: 24,
          ),
        ),
      ],
    );
  }
}
