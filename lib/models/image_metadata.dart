class ImageMetadata {
  String path;
  String? artist;
  String? copyright;
  String? description;
  String? software;
  String? dateTime;
  bool hasMetadata;
  DateTime addedAt;

  // AI Detection
  bool? isAIGenerated;
  double? aiConfidence;
  String? aiDetectionModel;
  DateTime? aiDetectedAt;
  Map<String, dynamic>? aiDetails;

  ImageMetadata({
    required this.path,
    this.artist,
    this.copyright,
    this.description,
    this.software,
    this.dateTime,
    this.hasMetadata = false,
    required this.addedAt,
    this.isAIGenerated,
    this.aiConfidence,
    this.aiDetectionModel,
    this.aiDetectedAt,
    this.aiDetails,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'artist': artist,
    'copyright': copyright,
    'description': description,
    'software': software,
    'dateTime': dateTime,
    'hasMetadata': hasMetadata,
    'addedAt': addedAt.toIso8601String(),
    'isAIGenerated': isAIGenerated,
    'aiConfidence': aiConfidence,
    'aiDetectionModel': aiDetectionModel,
    'aiDetectedAt': aiDetectedAt?.toIso8601String(),
    'aiDetails': aiDetails,
  };

  factory ImageMetadata.fromJson(Map<String, dynamic> json) => ImageMetadata(
    path: json['path'],
    artist: json['artist'],
    copyright: json['copyright'],
    description: json['description'],
    software: json['software'],
    dateTime: json['dateTime'],
    hasMetadata: json['hasMetadata'] ?? false,
    addedAt: DateTime.parse(json['addedAt']),
    isAIGenerated: json['isAIGenerated'],
    aiConfidence: json['aiConfidence']?.toDouble(),
    aiDetectionModel: json['aiDetectionModel'],
    aiDetectedAt: json['aiDetectedAt'] != null
        ? DateTime.parse(json['aiDetectedAt'])
        : null,
    aiDetails: json['aiDetails'],
  );

  bool get hasAIDetection => isAIGenerated != null;

  String get aiStatus {
    if (!hasAIDetection) return 'Non analysé';
    if (isAIGenerated!) return 'IA Détectée';
    return 'Image réelle';
  }
}