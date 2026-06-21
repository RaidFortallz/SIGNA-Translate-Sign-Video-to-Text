import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class AppTutorialController extends GetxController {
  var isTutorialMode = false.obs;

  void startTutorial() => isTutorialMode.value = true;
  void endTutorial() => isTutorialMode.value = false;

  static Widget buildCard({
    required TutorialCoachMarkController ctrl,
    required String emoji,
    required String title,
    required String description,
    required int step,
    required int total,
    bool alwaysShowNext = false,
  }) {
    final bool isLast = !alwaysShowNext && (step == total);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [WarnaApp.wrBlue, WarnaApp.wrBlue2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WarnaApp.wrBlue.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: TextStyle(fontSize: 26.sp)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextCustom(
                    "$step / $total",
                    color: WarnaApp.wrWhite,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            TextCustom(
              title,
              color: WarnaApp.wrWhite,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 6.h),
            TextCustom(
              description,
              color: WarnaApp.wrWhite.withValues(alpha: 0.85),
              fontSize: 12.sp,
              height: 1.5,
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: ctrl.next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WarnaApp.wrWhite,
                  foregroundColor: WarnaApp.wrBlue,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 9.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextCustom(
                      isLast ? "Selesai" : "Selanjutnya",
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      size: 14.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
