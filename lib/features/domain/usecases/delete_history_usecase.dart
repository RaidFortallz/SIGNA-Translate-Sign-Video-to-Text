import 'package:signa_video_to_text/features/domain/repositories/translation_repository.dart';

class DeleteHistoryUsecase {
  final ITranslationRepository repo;

  DeleteHistoryUsecase({required this.repo});

  Future<void> execute(String id, String path) async {
    await repo.deleteHistory(id, path);
  }
}