import 'package:get/get.dart';
import 'package:signa_video_to_text/features/presentation/controllers/splashscreen_controller.dart';

class SplashscreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SplashscreenController());
  }
}