import 'package:flutter/material.dart';
import 'package:metadata_editor_pro_app/models/image_metadata.dart';
import 'package:provider/provider.dart';
import '../providers/metadata_provider.dart';
import '../services/ai_detector_service.dart';

class AIDetectionWidget extends StatelessWidget {
  final ImageMetadata image;
  final MetadataProvider provider;
  const AIDetectionWidget({super.key, required this.image, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (!image.hasAIDetection) return _NotDetectedCard(image: image, provider: provider);
    return Card(
      color: image.isAIGenerated! ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  image.isAIGenerated! ? Icons.rocket : Icons.verified_user,
                  color: image.isAIGenerated! ? Colors.red.shade700 : Colors.green.shade700,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        image.isAIGenerated! ? '🤖 Image IA Détectée' : '✓ Image Réelle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: image.isAIGenerated! ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                      Text(
                        image.aiDetectionModel ?? 'Modèle inconnu',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _redetect(context),
                  tooltip: 'Redétecter',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: image.aiConfidence,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor(image.aiConfidence!)),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Confiance: ${image.aiConfidence!.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(image.aiConfidence!).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getConfidenceLevel(image.aiConfidence!),
                    style: TextStyle(
                      color: _getConfidenceColor(image.aiConfidence!),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (image.aiDetectedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Détecté le: ${_formatDate(image.aiDetectedAt!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.red;
    if (confidence > 0.6) return Colors.orange;
    if (confidence > 0.4) return Colors.yellow;
    return Colors.green;
  }

  String _getConfidenceLevel(double confidence) {
    if (confidence > 0.8) return 'Très probable';
    if (confidence > 0.6) return 'Probable';
    if (confidence > 0.4) return 'Possible';
    return 'Peu probable';
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

  void _redetect(BuildContext context) async {
    try {
      await provider.detectAIForImage(image);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('✅ Détection mise à jour')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ Erreur: $e')));
      }
    }
  }
}

class _NotDetectedCard extends StatelessWidget {
  final ImageMetadata image;
  final MetadataProvider provider;
  const _NotDetectedCard({required this.image, required this.provider});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.psychology_outlined, size: 48, color: Colors.blue.shade700),
            const SizedBox(height: 12),
            const Text('Détection IA non effectuée',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Analysez cette image pour détecter si elle est générée par IA',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _detect(context),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Détecter l\'IA'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            ),
          ],
        ),
      ),
    );
  }

  void _detect(BuildContext context) async {
    final method = await showDialog<DetectionMethod>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Méthode de détection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Google Gemini'),
              subtitle: const Text('Recommandé - Gratuit'),
              onTap: () => Navigator.pop(context, DetectionMethod.gemini),
            ),
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Hive AI'),
              subtitle: const Text('API payante'),
              onTap: () => Navigator.pop(context, DetectionMethod.hive),
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Sightengine'),
              subtitle: const Text('Freemium'),
              onTap: () => Navigator.pop(context, DetectionMethod.sightengine),
            ),
          ],
        ),
      ),
    );
    if (method != null && context.mounted) {
      try {
        await provider.detectAIForImage(image, method: method);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('✅ Détection terminée')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('❌ Erreur: $e')));
        }
      }
    }
  }
}