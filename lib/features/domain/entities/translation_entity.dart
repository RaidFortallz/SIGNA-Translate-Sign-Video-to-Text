class TranslationEntity {
  final String id;
  final String text;
  final double accuracy;
  final String videoPath;
  final DateTime timestamp;

  TranslationEntity({
    required this.id,
    required this.text,
    required this.accuracy,
    required this.videoPath,
    required this.timestamp,
  });
}
