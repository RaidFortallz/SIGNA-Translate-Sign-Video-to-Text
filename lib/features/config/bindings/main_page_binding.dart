import 'package:get/get.dart';
import 'package:signa_video_to_text/features/presentation/controllers/main_page_controller.dart';

class MainPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(MainPageController());
    
  }
}