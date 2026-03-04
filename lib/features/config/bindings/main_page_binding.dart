import 'package:get/get.dart';
import 'package:signa_video_to_text/features/data/data_sources/firebase_data_sources.dart';
import 'package:signa_video_to_text/features/data/data_sources/local_file_data_source.dart';
import 'package:signa_video_to_text/features/data/data_sources/tflite_data_sources.dart';
import 'package:signa_video_to_text/features/data/repository_impl/translation_repository_impl.dart';
import 'package:signa_video_to_text/features/domain/repositories/translation_repository.dart';
import 'package:signa_video_to_text/features/domain/usecases/delete_history_usecase.dart';
import 'package:signa_video_to_text/features/domain/usecases/get_history_usecase.dart';
import 'package:signa_video_to_text/features/domain/usecases/translate_video_usecase.dart';
import 'package:signa_video_to_text/features/presentation/controllers/main_page_controller.dart';
import 'package:signa_video_to_text/features/presentation/controllers/translation_controller.dart';

class MainPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(MainPageController());

    //Data Layer
    Get.put(FirebaseDataSources());
    Get.put(LocalFileDataSource());
    Get.put(TfliteDataSources());

    //Domain Layer
    Get.put<ITranslationRepository>(
      TranslationRepositoryImpl(
        aiSource: Get.find<TfliteDataSources>(),
        clouSource: Get.find<FirebaseDataSources>(),
        localSource: Get.find<LocalFileDataSource>(),
      ),
    );

    Get.put(TranslateVideoUsecase(repo: Get.find<ITranslationRepository>()));
    Get.put(GetHistoryUsecase(repo: Get.find<ITranslationRepository>()));
    Get.put(DeleteHistoryUsecase(repo: Get.find<ITranslationRepository>()));

    //Presentation Layer
    Get.put(
      TranslationController(
        translateUC: Get.find<TranslateVideoUsecase>(),
        historyUC: Get.find<GetHistoryUsecase>(),
        deleteUC: Get.find<DeleteHistoryUsecase>(),
      ),
    );
  }
}
