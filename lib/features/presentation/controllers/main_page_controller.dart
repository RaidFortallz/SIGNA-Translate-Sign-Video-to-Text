import 'package:get/get.dart';

class MainPageController extends GetxController {
  var currentIndex = 0.obs;
  var hideCircle = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 400), () {
      hideCircle.value = true;
    });
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

}