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
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: -60,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                            width: 40,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.04),
                            width: 30,
                          ),
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              "assets/icon/logo_foreground.png",
                              height: 58,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 28),
                        Text(
                          "S I G N A",
                          style: TextStyle(
                            fontSize: 46,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 10,
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 1.5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 60,
                              height: 1.5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 20,
                              height: 1.5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            "Terjemah Bahasa Isyarat",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 0.5,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "C",
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Copyright by Aridwan & MDimasDP",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.4,
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 32,
                              height: 0.5,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ],
                        ),
                      ],
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
