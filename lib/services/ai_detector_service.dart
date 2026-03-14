import 'dart:io';
import 'gemini_ai_detector.dart';

enum DetectionMethod { gemini, hive, sightengine }

class AIDetectionResult {
  final bool isAIGenerated;
  final double confidence;
  final String? modelName;
  final Map<String, dynamic>? details;
  final String? errorMessage;

  AIDetectionResult({
    required this.isAIGenerated,
    required this.confidence,
    this.modelName,
    this.details,
    this.errorMessage,
  });

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  String get status {
    if (confidence > 0.8) return 'Très probable';
    if (confidence > 0.6) return 'Probable';
    if (confidence > 0.4) return 'Possible';
    return 'Peu probable';
  }
}

class AIDetectorService {
  final GeminiAIDetector _geminiDetector = GeminiAIDetector();

  Future<AIDetectionResult> detectWithGemini(File imageFile) async =>
      await _geminiDetector.detectWithGemini(imageFile);

  Future<AIDetectionResult> detectWithHiveAI(File imageFile) async =>
      AIDetectionResult(
          isAIGenerated: false,
          confidence: 0.0,
          errorMessage: 'API Hive non configurée');

  Future<AIDetectionResult> detectWithSightengine(File imageFile) async =>
      AIDetectionResult(
          isAIGenerated: false,
          confidence: 0.0,
          errorMessage: 'API Sight non configurée');

  Future<AIDetectionResult> detectAI({
    required File imageFile,
    DetectionMethod method = DetectionMethod.gemini,
  }) async {
    switch (method) {
      case DetectionMethod.gemini:
        return await detectWithGemini(imageFile);
      case DetectionMethod.hive:
        return await detectWithHiveAI(imageFile);
      case DetectionMethod.sightengine:
        return await detectWithSightengine(imageFile);
    }
  }
}