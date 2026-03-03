import 'package:signa_video_to_text/features/data/data_sources/firebase_data_sources.dart';
import 'package:signa_video_to_text/features/data/data_sources/local_file_data_source.dart';
import 'package:signa_video_to_text/features/data/data_sources/tflite_data_sources.dart';
import 'package:signa_video_to_text/features/data/models/translation_model.dart';
import 'package:signa_video_to_text/features/domain/entities/translation_entity.dart';
import 'package:signa_video_to_text/features/domain/repositories/translation_repository.dart';
import 'package:uuid/uuid.dart';

class TranslationRepositoryImpl implements ITranslationRepository {
  final TfliteDataSources aiSource;
  final FirebaseDataSources clouSource;
  final LocalFileDataSource localSource;

  TranslationRepositoryImpl({
    required this.aiSource,
    required this.clouSource,
    required this.localSource,
  });

  @override
  Future<TranslationEntity> processVideo(String path) async {
    final aiResult = await aiSource.runInference(path);

    final newTranslation = TranslationModel(
      id: const Uuid().v4(),
      text: aiResult['label'],
      accuracy: aiResult['confidence'],
      videoPath: path,
      timestamp: DateTime.now(),
    );

    await clouSource.saveToFirestore(newTranslation.toJson());

    return newTranslation.toEntity();
  }

  @override
  Future<List<TranslationEntity>> getHistory() async {
    final uid = clouSource.getCurrentUid();
    if (uid == null) throw Exception("Userbelum login");

    final List<Map<String, dynamic>> rawData = await clouSource
        .fetchFromFirestore(uid);

    return rawData.map((data) {
      final model = TranslationModel.fromJson(data);
      return model.toEntity();
    }).toList();
  }

  @override
  Future<void> deleteHistory(String id, String path) async {
    await clouSource.deleteFromFirestore(id);

    await localSource.deleteVideo(path);
  }
}
