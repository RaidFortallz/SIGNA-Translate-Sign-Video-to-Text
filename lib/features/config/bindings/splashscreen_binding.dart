import 'package:get/get.dart';
import 'package:signa_video_to_text/features/data/data_sources/firebase_data_sources.dart';
import 'package:signa_video_to_text/features/data/repository_impl/auth_repository_impl.dart';
import 'package:signa_video_to_text/features/domain/repositories/auth_repository.dart';
import 'package:signa_video_to_text/features/domain/usecases/sign_in_usecase.dart';
import 'package:signa_video_to_text/features/presentation/controllers/auth_controller.dart';
import 'package:signa_video_to_text/features/presentation/controllers/splashscreen_controller.dart';

class SplashscreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SplashscreenController());

    //Data Layer
    Get.put(FirebaseDataSources(), permanent: true);

    //Domain Layer
    Get.put<IAuthRepository>(
      AuthRepositoryImpl(dataSource: Get.find<FirebaseDataSources>()),
      permanent: true
    );
    Get.put(SignInUsecase(repo: Get.find<IAuthRepository>()), permanent: true);

    //Presentation Layer
    Get.put(
      AuthController(signinUC: Get.find<SignInUsecase>()),
      permanent: true,
    );
  }
}
