import 'package:signa_video_to_text/features/domain/entities/translation_entity.dart';
import 'package:signa_video_to_text/features/domain/repositories/translation_repository.dart';

class TranslateVideoUsecase {
  final ITranslationRepository repo;

  TranslateVideoUsecase({required this.repo});

  Future<TranslationEntity> execute(
    String videoPath, {
    Duration? trimStart,
    Duration? trimEnd,
  }) async {
    return await repo.processVideo(
      videoPath,
      trimStart: trimStart,
      trimEnd: trimEnd,
    );
  }
}
