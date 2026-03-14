class AppConfig {
  // ⚠️ Important Notes (CSV File 1 - Translated)
  static const List<Map<String, String>> warnings = [
    {
      'subject': 'Compatibility',
      'note': 'Some formats (HEIC, WebP) may not support EXIF'
    },
    {
      'subject': 'Data Loss',
      'note': 'Editing may overwrite existing metadata'
    },
    {
      'subject': 'C2PA',
      'note': 'Provenance signatures (DALL-E) may be invalidated'
    },
    {
      'subject': 'Social Media',
      'note': 'Facebook, Instagram, Twitter remove EXIF on upload'
    },
    {
      'subject': 'Backup',
      'note': 'Always keep an original copy before editing'
    },
  ];

  // ✅ Features (CSV File 2 - Translated)
  static const List<Map<String, String>> features = [
    {
      'feature': '📸 Direct Photo Capture',
      'description': 'Use camera instead of gallery'
    },
    {
      'feature': '🗂️ Batch Processing',
      'description': 'Edit multiple images at once'
    },
    {
      'feature': '📤 Export/Import',
      'description': 'Save metadata as JSON'
    },
    {
      'feature': '🔍 Search',
      'description': 'Filter images by metadata'
    },
    {
      'feature': '📊 Statistics',
      'description': 'Track images with/without metadata'
    },
    {
      'feature': '🌐 XMP/IPTC Support',
      'description': 'Add other metadata formats'
    },
    {
      'feature': '🎨 Auto Watermark',
      'description': 'Add visible watermark'
    },
  ];
}