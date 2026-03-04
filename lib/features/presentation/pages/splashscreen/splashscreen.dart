import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/controllers/auth_controller.dart';
import 'package:signa_video_to_text/features/presentation/controllers/splashscreen_controller.dart';

class Splashscreen extends StatelessWidget {
  final controller = Get.find<SplashscreenController>();
  final authController = Get.find<AuthController>();
  Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaApp.wrBody,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // lottie animation
            Lottie.asset(
              'assets/lottie_animation/hand_shake.json',
              width: 600,
              repeat: true,
              onLoaded: (composition) {
                controller.startSplashFlow(composition.duration);
              },
            ),

            Obx(
              () => AnimatedScale(
                scale: controller.showCircle.value ? 20 : 0.01,
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeInOut,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: WarnaApp.wrBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            Obx(
              () => AnimatedOpacity(
                opacity: controller.showTitle.value ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "S I G N A",
                      style: TextStyle(
                        fontSize: 42,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Terjemah Bahasa Isyarat",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
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
