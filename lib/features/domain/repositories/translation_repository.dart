import 'package:signa_video_to_text/features/domain/entities/translation_entity.dart';

abstract class ITranslationRepository {
  Future<TranslationEntity> processVideo(String path, {
    Duration? trimStart,
    Duration? trimEnd,
  });

  Future<List<TranslationEntity>> getHistory();

  Future<void> deleteHistory(String id, String path);
}
