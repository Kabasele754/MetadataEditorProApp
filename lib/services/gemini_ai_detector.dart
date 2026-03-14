import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:convert/convert.dart';
import '../config/app_config.dart';
import 'ai_detector_service.dart';

class GeminiAIDetector {
  late final GenerativeModel _model;

  GeminiAIDetector() {
    final apiKey = const String.fromEnvironment('GEMINI_API_KEY');
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<AIDetectionResult> detectWithGemini(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final imageData = DataPart('image/jpeg', imageBytes);

      final prompt = '''
Analyse cette image pour détecter si elle a été générée par une IA.
Examine: mains, texte, symétrie, éclairage, détails, proportions.
Réponds EXCLUSIVEMENT en JSON:
{
  "is_ai_generated": true ou false,
  "confidence": nombre entre 0.0 et 1.0,
  "reasoning": "explication en français",
  "detected_anomalies": ["liste anomalies"],
  "possible_models": ["DALL-E", "Midjourney", "Stable Diffusion"]
}
''';

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), imageData])
      ]);
      final responseText = response.text ?? '{}';
      final jsonResult = _extractJsonFromResponse(responseText);

      if (jsonResult != null) {
        return AIDetectionResult(
          isAIGenerated: jsonResult['is_ai_generated'] ?? false,
          confidence: (jsonResult['confidence'] ?? 0.0).toDouble(),
          modelName: 'Google Gemini 1.5 Flash',
          details: {
            'reasoning': jsonResult['reasoning'] ?? '',
            'anomalies': jsonResult['detected_anomalies'] ?? [],
            'possibleModels': jsonResult['possible_models'] ?? []
          },
        );
      }
      return AIDetectionResult(
          isAIGenerated: false, confidence: 0.0, errorMessage: 'Réponse invalide');
    } catch (e) {
      return AIDetectionResult(
          isAIGenerated: false, confidence: 0.0, errorMessage: 'Erreur Gemini: $e');
    }
  }

  Map<String, dynamic>? _extractJsonFromResponse(String response) {
    try {
      return jsonDecode(response);
    } catch (e) {
      final jsonRegex = RegExp(r'\{[\s\S]*\}');
      final match = jsonRegex.firstMatch(response);
      if (match != null) {
        try {
          return jsonDecode(match.group(0)!);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
  }
}