import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';

class SplashscreenController extends GetxController {
  var showCircle = false.obs;
  var showTitle = false.obs;
  bool _started = false;

  void startSplashFlow(Duration lottieDuration) {
    if (_started) return;
    _started = true;

    final totalDuration = lottieDuration * 2.4;

    // setelah animasi dari lottie diputar 2 kali -> munculin circle
    Future.delayed(totalDuration, () {
      showCircle.value = true;
    });

    //
    Future.delayed(totalDuration + const Duration(milliseconds: 950), () {
      showTitle.value = true;
    });

    // pindah halaman setelah circle muncul
    Future.delayed(totalDuration + const Duration(milliseconds: 1300), () {
      Get.offAllNamed(RouteNames.main);
    });
  }
}
