import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';
import 'package:image/image.dart' as img;
import '../models/image_metadata.dart';
import '../services/ai_detector_service.dart';

class MetadataProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final AIDetectorService _aiDetector = AIDetectorService();

  List<ImageMetadata> _images = [];
  ImageMetadata? _selectedImage;
  bool _isLoading = false;
  bool _isDetecting = false;
  String _searchQuery = '';
  String _filterStatus = 'all';
  String _aiFilterStatus = 'all';

  List<ImageMetadata> get images => _filteredImages;
  ImageMetadata? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  bool get isDetecting => _isDetecting;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  String get aiFilterStatus => _aiFilterStatus;

  List<ImageMetadata> get _filteredImages {
    return _images.where((image) {
      final matchesSearch = _searchQuery.isEmpty ||
          (image.artist?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (image.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          image.path.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _filterStatus == 'all' ||
          (_filterStatus == 'with' && image.hasMetadata) ||
          (_filterStatus == 'without' && !image.hasMetadata);

      final matchesAIFilter = _aiFilterStatus == 'all' ||
          (_aiFilterStatus == 'ai' && image.isAIGenerated == true) ||
          (_aiFilterStatus == 'real' && image.isAIGenerated == false) ||
          (_aiFilterStatus == 'unknown' && !image.hasAIDetection);

      return matchesSearch && matchesFilter && matchesAIFilter;
    }).toList();
  }

  Map<String, int> get statistics {
    final total = _images.length;
    final withMetadata = _images.where((i) => i.hasMetadata).length;
    final withoutMetadata = total - withMetadata;
    final aiGenerated = _images.where((i) => i.isAIGenerated == true).length;
    final realImages = _images.where((i) => i.isAIGenerated == false).length;
    final unknownAI = _images.where((i) => !i.hasAIDetection).length;

    return {
      'total': total,
      'withMetadata': withMetadata,
      'withoutMetadata': withoutMetadata,
      'aiGenerated': aiGenerated,
      'realImages': realImages,
      'unknownAI': unknownAI,
      'percentage': total > 0 ? ((withMetadata / total) * 100).round() : 0,
      'aiPercentage': total > 0 ? ((aiGenerated / total) * 100).round() : 0,
    };
  }

  Future<void> pickImageFromGallery() async {
    _isLoading = true;
    notifyListeners();
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) await _addImage(pickedFile.path);
    } catch (e) {
      debugPrint('Erreur galerie: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> takePhoto() async {
    _isLoading = true;
    notifyListeners();
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) await _addImage(pickedFile.path);
    } catch (e) {
      debugPrint('Erreur caméra: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickMultipleImages() async {
    _isLoading = true;
    notifyListeners();
    try {
      final pickedFiles = await _picker.pickMultiImage();
      for (var file in pickedFiles) await _addImage(file.path);
    } catch (e) {
      debugPrint('Erreur multi-images: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

Future<void> _addImage(String path) async {
  try {
    // ✅ Vérifier que le fichier existe
    final imageFile = File(path);
    if (!await imageFile.exists()) {
      debugPrint('❌ Fichier inexistant: $path');
      return;
    }

    // ✅ Lire les métadonnées avec native_exif (avec gestion null)
    Exif? exif;
    Map<String, dynamic>? attributes;
    
    try {
      exif = await Exif.fromPath(path);
      attributes = await exif.getAttributes();
    } catch (e) {
      debugPrint('⚠️ EXIF non disponible pour cette image: $e');
      attributes = {}; // Fallback: métadonnées vides
    }

    // ✅ Extraction sécurisée des métadonnées (avec ?? pour null)
    final artist = attributes?['Artist'] as String?;
    final copyright = attributes?['Copyright'] as String?;
    final description = attributes?['ImageDescription'] as String?;
    final software = attributes?['Software'] as String?;
    final dateTime = attributes?['DateTime'] as String?;

    final hasMetadata =
        artist != null || copyright != null || description != null;

    final imageMetadata = ImageMetadata(
      path: path,
      artist: artist,
      copyright: copyright,
      description: description,
      software: software,
      dateTime: dateTime,
      hasMetadata: hasMetadata,
      addedAt: DateTime.now(),
    );

    // ✅ Fermer l'instance EXIF (avec vérification null)
    if (exif != null) {
      await exif.close();
    }
    
    _images.add(imageMetadata);
    await _saveImagesList();
    notifyListeners();
    
    debugPrint('✅ Image ajoutée: ${path.split('/').last}');
  } catch (e) {
    debugPrint('❌ Erreur ajout image: $e');
    // ✅ Même en cas d'erreur, ajouter l'image sans métadonnées
    try {
      final imageMetadata = ImageMetadata(
        path: path,
        hasMetadata: false,
        addedAt: DateTime.now(),
      );
      _images.add(imageMetadata);
      await _saveImagesList();
      notifyListeners();
    } catch (e2) {
      debugPrint('❌ Erreur fallback: $e2');
    }
  }
}
 
 
  Future<void> updateMetadata(ImageMetadata image,
    {String? artist, String? copyright, String? description, String? software}) async {
  try {
    // ✅ Vérifier que le fichier existe
    final imageFile = File(image.path);
    if (!await imageFile.exists()) {
      throw Exception('Fichier inexistant: ${image.path}');
    }

    // ✅ Écrire les métadonnées avec native_exif
    Exif? exif;
    try {
      exif = await Exif.fromPath(image.path);

      final attributes = <String, String>{};
      if (artist != null && artist.isNotEmpty) attributes['Artist'] = artist;
      if (copyright != null && copyright.isNotEmpty) attributes['Copyright'] = copyright;
      if (description != null && description.isNotEmpty) attributes['ImageDescription'] = description;
      if (software != null && software.isNotEmpty) attributes['Software'] = software;

      if (attributes.isNotEmpty) {
        await exif.writeAttributes(attributes);
      }
    } catch (e) {
      debugPrint('⚠️ Erreur écriture EXIF: $e');
      rethrow;
    } finally {
      // ✅ Toujours fermer l'instance
      if (exif != null) {
        await exif.close();
      }
    }

    // Mettre à jour l'objet local
    image.artist = artist ?? image.artist;
    image.copyright = copyright ?? image.copyright;
    image.description = description ?? image.description;
    image.software = software ?? image.software;
    image.hasMetadata = true;

    await _saveImagesList();
    notifyListeners();
  } catch (e) {
    debugPrint('❌ Erreur mise à jour: $e');
    rethrow;
  }
}
  Future<void> detectAIForImage(ImageMetadata image,
      {DetectionMethod method = DetectionMethod.gemini}) async {
    _isDetecting = true;
    notifyListeners();
    try {
      final result = await _aiDetector.detectAI(
          imageFile: File(image.path), method: method);
      image.isAIGenerated = result.isAIGenerated;
      image.aiConfidence = result.confidence;
      image.aiDetectionModel = result.modelName;
      image.aiDetectedAt = DateTime.now();
      image.aiDetails = result.details;
      await _saveImagesList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur détection IA: $e');
      rethrow;
    } finally {
      _isDetecting = false;
      notifyListeners();
    }
  }

  Future<void> detectAIForAllImages(
      {DetectionMethod method = DetectionMethod.gemini}) async {
    _isDetecting = true;
    notifyListeners();
    for (var image in _images) {
      if (!image.hasAIDetection) {
        try {
          await detectAIForImage(image, method: method);
        } catch (e) {
          debugPrint('Erreur sur ${image.path}: $e');
        }
      }
    }
    _isDetecting = false;
    notifyListeners();
  }

 Future<void> addWatermark(ImageMetadata image, String text) async {
  try {
    // Charger l'image principale
    final mainImage = img.decodeImage(await File(image.path).readAsBytes());
    if (mainImage == null) return;
    
    // Charger l'overlay (watermark.png dans assets)
    // Créez un petit PNG 200x40px avec votre texte dans un éditeur
    final overlayBytes = await rootBundle.load('assets/watermark.png');
    final overlay = img.decodeImage(overlayBytes.buffer.asUint8List());
    if (overlay == null) return;
    
    // Superposer en bas à droite
    img.copyResize(overlay, width: 200, height: 40);
    img.compositeImage(
      mainImage,
      overlay,
      dstX: mainImage.width - 210,
      dstY: mainImage.height - 50,
    );
    
    // Sauvegarder
    final newBytes = img.encodeJpg(mainImage, quality: 95);
    final newPath = image.path.replaceAll('.jpg', '_wm.jpg');
    await File(newPath).writeAsBytes(newBytes);
    
    image.path = newPath;
    await _saveImagesList();
    notifyListeners();
  } catch (e) {
    debugPrint('Erreur overlay: $e');
  }
}
  Future<void> exportMetadata() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/metadata_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final jsonData =
          jsonEncode(_images.map((i) => i.toJson()).toList());
      await File(filePath).writeAsString(jsonData);
    } catch (e) {
      debugPrint('Erreur export: $e');
      rethrow;
    }
  }

  Future<void> importMetadata(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      for (var json in jsonList) _images.add(ImageMetadata.fromJson(json));
      await _saveImagesList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur import: $e');
      rethrow;
    }
  }

  Future<void> createBackup(ImageMetadata image) async {
    try {
      final originalFile = File(image.path);
      final directory = await getApplicationDocumentsDirectory();
      final backupPath =
          '${directory.path}/backup_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await originalFile.copy(backupPath);
    } catch (e) {
      debugPrint('Erreur backup: $e');
    }
  }

  Future<void> createAllBackups() async {
    for (var image in _images) await createBackup(image);
  }

  void removeImage(ImageMetadata image) {
    _images.remove(image);
    _saveImagesList();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void updateAIFilterStatus(String status) {
    _aiFilterStatus = status;
    notifyListeners();
  }

  Future<void> _saveImagesList() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/images_list.json';
      final jsonData =
          jsonEncode(_images.map((i) => i.toJson()).toList());
      await File(filePath).writeAsString(jsonData);
    } catch (e) {
      debugPrint('Erreur sauvegarde: $e');
    }
  }

  Future<void> loadImagesList() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/images_list.json';
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _images = jsonList.map((json) => ImageMetadata.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur chargement: $e');
    }
  }
}