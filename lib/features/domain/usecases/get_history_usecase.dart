import 'package:signa_video_to_text/features/domain/entities/translation_entity.dart';
import 'package:signa_video_to_text/features/domain/repositories/translation_repository.dart';

class GetHistoryUsecase {
  final ITranslationRepository repo;

  GetHistoryUsecase({required this.repo});

  Future<List<TranslationEntity>> execute() async {
    return await repo.getHistory();
  }
}