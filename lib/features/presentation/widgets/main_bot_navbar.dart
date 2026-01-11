import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/main_page_controller.dart';

class MainBotNavbar extends StatelessWidget {
  final MainPageController controller;
   const MainBotNavbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 60.h, vertical: 50.h),
      child: Obx(
        () => GNav(
          backgroundColor: WarnaApp.wrBody,
          color: WarnaApp.wrBlue,
          activeColor: WarnaApp.wrWhite,
          tabBackgroundColor: WarnaApp.wrBlue,
          gap: 12.h,
          selectedIndex: controller.currentIndex.value,
          onTabChange: controller.changeTab,
          iconSize: 32.sp,
          padding: EdgeInsets.all(16.h),
          tabs: [
            GButton(
              icon: Icons.sign_language_rounded,
              text: "Terjemahan",
              borderRadius: BorderRadius.circular(22),
            ),
            GButton(
              icon: Icons.history_edu_rounded,
              text: "Riwayat",
              borderRadius: BorderRadius.circular(22),
            ),
          ],
        ),
      ),
    );
  }
}
