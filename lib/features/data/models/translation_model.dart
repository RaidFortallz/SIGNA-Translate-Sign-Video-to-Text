import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signa_video_to_text/features/domain/entities/translation_entity.dart';

class TranslationModel extends TranslationEntity {
  TranslationModel({
    required super.id,
    required super.text,
    required super.accuracy,
    required super.videoPath,
    required super.timestamp,
  });

  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      videoPath: json['videoPath'] as String? ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'accuracy': accuracy,
      'videoPath': videoPath,
      'timestamp': timestamp,
    };
  }

  TranslationEntity toEntity() {
    return TranslationEntity(
      id: id,
      text: text,
      accuracy: accuracy,
      videoPath: videoPath,
      timestamp: timestamp,
    );
  }

}
