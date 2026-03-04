import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/bindings/main_page_binding.dart';
import 'package:signa_video_to_text/features/config/bindings/splashscreen_binding.dart';
import 'package:signa_video_to_text/features/config/routes/route_names.dart';
import 'package:signa_video_to_text/features/presentation/pages/main_page.dart';
import 'package:signa_video_to_text/features/presentation/pages/camera_page.dart';
import 'package:signa_video_to_text/features/presentation/pages/splashscreen/splashscreen.dart';
import 'package:signa_video_to_text/features/presentation/pages/result_page.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: RouteNames.splashscreen,
      page: () => Splashscreen(),
      binding: SplashscreenBinding(),
    ),
    GetPage(
      name: RouteNames.main,
      page: () => MainPage(),
      binding: MainPageBinding(),
    ),
    GetPage(name: RouteNames.record, page: () => CameraPage()),
    GetPage(name: RouteNames.result, page: () => ResultPage()),
  ];
}
