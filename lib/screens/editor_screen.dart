import 'package:flutter/material.dart';
import 'package:metadata_editor_pro_app/models/image_metadata.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';  // ✅ Import share_plus
import 'dart:io';
import '../providers/metadata_provider.dart';
import '../widgets/ai_detection_widget.dart';

class EditorScreen extends StatefulWidget {
  final ImageMetadata image;
  final MetadataProvider provider;
  const EditorScreen({super.key, required this.image, required this.provider});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _artistController;
  late TextEditingController _copyrightController;
  late TextEditingController _descriptionController;
  late TextEditingController _softwareController;
  late TextEditingController _watermarkController;
  bool _isModified = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _artistController = TextEditingController(text: widget.image.artist ?? '');
    _copyrightController = TextEditingController(text: widget.image.copyright ?? '');
    _descriptionController = TextEditingController(text: widget.image.description ?? '');
    _softwareController = TextEditingController(text: widget.image.software ?? '');
    _watermarkController = TextEditingController();
  }

  @override
  void dispose() {
    _artistController.dispose();
    _copyrightController.dispose();
    _descriptionController.dispose();
    _softwareController.dispose();
    _watermarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // 🎨 Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // ✅ Share Button
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () => _shareImage(context),
                tooltip: 'Share Image',
              ),
              // ✅ Save Button
              IconButton(
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                onPressed: _isModified && !_isSaving ? _saveMetadata : null,
                tooltip: 'Save Changes',
              ),
              const SizedBox(width: 8),
            ],
            title: const Text(
              'Metadata Editor',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),

          // 📋 Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼️ Image Preview Card
                  _ImagePreviewCard(imagePath: widget.image.path),
                  const SizedBox(height: 20),

                  // 📋 Current Metadata Section
                  _buildSectionTitle('📋 Current Metadata'),
                  const SizedBox(height: 12),
                  _MetadataInfoCard(image: widget.image),
                  const SizedBox(height: 24),

                  // 🤖 AI Detection Widget
                  AIDetectionWidget(image: widget.image, provider: widget.provider),
                  const SizedBox(height: 24),

                  // ✏️ Edit Metadata Section
                  _buildSectionTitle('✏️ Edit Metadata'),
                  const SizedBox(height: 12),
                  _MetadataForm(
                    artistController: _artistController,
                    copyrightController: _copyrightController,
                    descriptionController: _descriptionController,
                    softwareController: _softwareController,
                    onModified: () => setState(() => _isModified = true),
                  ),
                  const SizedBox(height: 24),

                  // 🔧 Action Buttons (Save + Share)
                  _buildActionButtons(),
                  const SizedBox(height: 24),

                  // ⚠️ Warning Card
                  _buildWarningCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      // ✅ Sticky Bottom Bar with Save & Share
      bottomNavigationBar: _isModified || _isSaving
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Share Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareImage(context),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Save Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isModified && !_isSaving ? _saveMetadata : null,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  // ✅ Share Image Function
  Future<void> _shareImage(BuildContext context) async {
    try {
      final imageFile = File(widget.image.path);
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔄 Preparing to share...'), duration: Duration(seconds: 1)),
      );

      // Share the image file
      final result = await Share.shareXFiles(
        [XFile(widget.image.path)],
        text: _buildShareText(),
        subject: 'MetaEdit Pro - ${widget.image.path.split('/').last}',
      );

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Image shared successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Share failed: $e')),
        );
      }
    }
  }

  // ✅ Build Share Text with Metadata
  String _buildShareText() {
    final artist = widget.image.artist ?? 'Unknown';
    final description = widget.image.description ?? '';
    final copyright = widget.image.copyright ?? '';
    
    return '''
📸 ${widget.image.path.split('/').last}

👤 Artist: $artist
${description.isNotEmpty ? '📝 $description\n' : ''}${copyright.isNotEmpty ? '© $copyright\n' : ''}
🔧 Edited with MetaEdit Pro

#MetaEditPro #Metadata #EXIF
''';
  }

  // ✅ Save Metadata Function with Share Option
  Future<void> _saveMetadata() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      await widget.provider.updateMetadata(
        widget.image,
        artist: _artistController.text,
        copyright: _copyrightController.text,
        description: _descriptionController.text,
        software: _softwareController.text,
      );
      
      setState(() => _isModified = false);
      
      if (context.mounted) {
        // Show success with share option
        _showSaveSuccessDialog(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ✅ Show Success Dialog with Share Option
  void _showSaveSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Saved!'),
          ],
        ),
        content: const Text('Metadata has been saved successfully. Would you like to share this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _shareImage(context);
            },
            icon: const Icon(Icons.share_rounded),
            label: const Text('Share Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  SnackBar _buildSnackBar(String message, Color color) {
    return SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    );
  }

  void _showWatermarkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.mark_as_unread_outlined, color: Colors.blue),
            SizedBox(width: 8),
            Text('Add Watermark'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the text to add as a visible watermark on your image.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _watermarkController,
              decoration: InputDecoration(
                labelText: 'Watermark Text',
                hintText: 'Ex: © Your Name 2026',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.text_fields_rounded),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.provider.addWatermark(widget.image, _watermarkController.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Watermark added')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    await widget.provider.createBackup(widget.image);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Backup created')),
      );
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _GradientActionButton(
          icon: Icons.mark_as_unread_outlined,
          title: 'Add Watermark',
          subtitle: 'Add visible text overlay',
          gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
          onTap: _showWatermarkDialog,
        ),
        const SizedBox(height: 10),
        _GradientActionButton(
          icon: Icons.backup_rounded,
          title: 'Create Backup',
          subtitle: 'Save original before editing',
          gradient: const LinearGradient(colors: [Color(0xFF11998e), Color(0xFF38ef7d)]),
          onTap: _createBackup,
        ),
      ],
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_rounded, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          // ✅ FIXED: Wrap in Expanded to prevent overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ Important Notice',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Editing may invalidate C2PA signatures and overwrite existing metadata. Always keep a backup of your original files.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🖼️ Image Preview Card (with overflow fix)
class _ImagePreviewCard extends StatelessWidget {
  final String imagePath;
  const _ImagePreviewCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_rounded, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Image not found', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ FIXED: Wrap in Flexible
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          imagePath.split('/').last,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Preview', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 📋 Metadata Info Card
class _MetadataInfoCard extends StatelessWidget {
  final ImageMetadata image;
  const _MetadataInfoCard({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRowEnhanced(
            icon: Icons.folder_rounded,
            label: 'File Path',
            value: image.path.split('/').last,
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 10),
          _InfoRowEnhanced(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: image.dateTime ?? 'Not available',
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: image.hasMetadata ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: image.hasMetadata ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  image.hasMetadata ? Icons.check_circle_rounded : Icons.warning_rounded,
                  color: image.hasMetadata ? Colors.green : Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                // ✅ FIXED: Wrap in Expanded
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Metadata Status', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      Text(
                        image.hasMetadata ? '✓ Has metadata' : '⚠ No metadata',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: image.hasMetadata ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 📋 Enhanced Info Row (with overflow fix)
class _InfoRowEnhanced extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  const _InfoRowEnhanced({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        // ✅ FIXED: Wrap in Expanded
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ✏️ Metadata Form
class _MetadataForm extends StatelessWidget {
  final TextEditingController artistController;
  final TextEditingController copyrightController;
  final TextEditingController descriptionController;
  final TextEditingController softwareController;
  final VoidCallback onModified;
  const _MetadataForm({
    required this.artistController,
    required this.copyrightController,
    required this.descriptionController,
    required this.softwareController,
    required this.onModified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _ModernTextField(
            controller: artistController,
            label: 'Artist / Author',
            hint: 'Enter artist name',
            icon: Icons.person_rounded,
            onChanged: onModified,
          ),
          const SizedBox(height: 12),
          _ModernTextField(
            controller: copyrightController,
            label: 'Copyright',
            hint: 'Ex: © 2026 Your Name',
            icon: Icons.copyright_rounded,
            onChanged: onModified,
          ),
          const SizedBox(height: 12),
          _ModernTextField(
            controller: descriptionController,
            label: 'Description',
            hint: 'Describe this image...',
            icon: Icons.description_rounded,
            maxLines: 3,
            onChanged: onModified,
          ),
          const SizedBox(height: 12),
          _ModernTextField(
            controller: softwareController,
            label: 'Software',
            hint: 'Software used to create/edit',
            icon: Icons.build_rounded,
            onChanged: onModified,
          ),
        ],
      ),
    );
  }
}

// 🎨 Modern Text Field
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final VoidCallback onChanged;
  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onChanged: (_) => onChanged(),
    );
  }
}

// 🎨 Gradient Action Button (with overflow fix)
class _GradientActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;
  const _GradientActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              // ✅ FIXED: Wrap in Expanded
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}