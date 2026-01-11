import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/main_page_controller.dart';
import 'package:signa_video_to_text/features/presentation/pages/history_page.dart';
import 'package:signa_video_to_text/features/presentation/pages/home_page.dart';
import 'package:signa_video_to_text/features/presentation/widgets/main_bot_navbar.dart';

class MainPage extends StatelessWidget {
  final controller = Get.find<MainPageController>();
  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Obx(
            () => IndexedStack(
              index: controller.currentIndex.value,
              children: [HomePage(), HistoryPage()],
            ),
          ),
          bottomNavigationBar: MainBotNavbar(controller: controller),
        ),

        Center(
          child: Obx(
            () => AnimatedScale(
              scale: controller.hideCircle.value ? 0.01 : 25,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              alignment: Alignment.center,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: WarnaApp.wrBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
