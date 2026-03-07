import 'package:get/get.dart';
import 'package:signa_video_to_text/features/domain/usecases/sign_in_usecase.dart';

class AuthController extends GetxController {
  final SignInUsecase signinUC;

  AuthController({required this.signinUC});

  @override
  void onInit() {
    super.onInit();
    initApp();
  }

  Future<void> initApp() async {
    try {
      print("Mencoba Login Anonymous ke Firebase...");

      await signinUC.execute();
      print("Berhasil login Anonymous! UID sudah siap digunakan");

      
    } catch (e) {
      print("Gagal login Anonymous: $e");
      Get.snackbar('Error Login', 'Gagal menyambung ke server. Detail: $e');
    }
  }
}
