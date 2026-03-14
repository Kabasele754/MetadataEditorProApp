import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/metadata_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MetadataProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 🎨 App Bar with Gradient
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
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
                    child: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.settings_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 📋 Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔐 Quick Actions Section
                      _buildSectionHeader(
                        context,
                        icon: Icons.rocket_launch,
                        title: 'Quick Actions',
                        subtitle: 'Manage your application',
                      ),
                      const SizedBox(height: 12),

                      _GradientActionCard(
                        icon: Icons.backup_rounded,
                        title: 'Create All Backups',
                        subtitle: 'Save all original files',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        onTap: () async {
                          await provider.createAllBackups();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              _buildSnackBar('✅ Backups created', Colors.green),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      _GradientActionCard(
                        icon: Icons.upload_file_rounded,
                        title: 'Export Metadata',
                        subtitle: 'Save as JSON file',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                        ),
                        onTap: () async {
                          try {
                            await provider.exportMetadata();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                _buildSnackBar('✅ Export successful', Colors.green),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                _buildSnackBar('❌ Failed: $e', Colors.red),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      _GradientActionCard(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Detect AI for All',
                        subtitle: 'Analyze with Google Gemini',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                        ),
                        onTap: () async {
                          try {
                            await provider.detectAIForAllImages();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                _buildSnackBar('✅ Detection complete', Colors.green),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                _buildSnackBar('❌ Error: $e', Colors.red),
                              );
                            }
                          }
                        },
                      ),

                      const SizedBox(height: 32),

                      // ⚠️ Important Information Section (CSV 1 - Translated)
                      _buildSectionHeader(
                        context,
                        icon: Icons.warning_rounded,
                        title: '⚠️ Important Information',
                        subtitle: 'Read before use',
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 12),

                      _WarningCard(
                        icon: Icons.storage_rounded,
                        title: 'Compatibility',
                        content: 'Some formats (HEIC, WebP) may not support EXIF',
                      ),
                      const SizedBox(height: 8),
                      _WarningCard(
                        icon: Icons.delete_outline_rounded,
                        title: 'Data Loss',
                        content: 'Editing may overwrite existing metadata',
                      ),
                      const SizedBox(height: 8),
                      _WarningCard(
                        icon: Icons.verified_user_rounded,
                        title: 'C2PA',
                        content: 'Provenance signatures (DALL-E) may be invalidated',
                      ),
                      const SizedBox(height: 8),
                      _WarningCard(
                        icon: Icons.share_rounded,
                        title: 'Social Media',
                        content: 'Facebook, Instagram, Twitter remove EXIF on upload',
                      ),
                      const SizedBox(height: 8),
                      _WarningCard(
                        icon: Icons.backup_table_rounded,
                        title: 'Backup',
                        content: 'Always keep an original copy before editing',
                      ),

                      const SizedBox(height: 32),

                      // 🎯 Features Section (CSV 2 - Translated)
                      _buildSectionHeader(
                        context,
                        icon: Icons.star_rounded,
                        title: '🎯 Features',
                        subtitle: 'What your app can do',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),

                      _FeatureGrid([
                        _FeatureItem(
                          icon: Icons.camera_alt_rounded,
                          title: 'Direct Photo Capture',
                          description: 'Use camera instead of gallery',
                        ),
                        _FeatureItem(
                          icon: Icons.photo_library_rounded,
                          title: 'Batch Processing',
                          description: 'Edit multiple images at once',
                        ),
                        _FeatureItem(
                          icon: Icons.upload_file_rounded,
                          title: 'Export/Import',
                          description: 'Save metadata as JSON',
                        ),
                        _FeatureItem(
                          icon: Icons.search_rounded,
                          title: 'Search',
                          description: 'Filter images by metadata',
                        ),
                        _FeatureItem(
                          icon: Icons.bar_chart_rounded,
                          title: 'Statistics',
                          description: 'Track images with/without metadata',
                        ),
                        _FeatureItem(
                          icon: Icons.extension_rounded,
                          title: 'XMP/IPTC Support',
                          description: 'Add other metadata formats',
                        ),
                        _FeatureItem(
                          icon: Icons.mark_as_unread_rounded,
                          title: 'Auto Watermark',
                          description: 'Add visible watermark',
                        ),
                      ]),

                      const SizedBox(height: 32),

                      // ℹ️ App Info Section
                      _AppInfoCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
  }) {
    final themeColor = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
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
}

// 🎨 Gradient Action Card
class _GradientActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _GradientActionCard({
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ⚠️ Warning Card
class _WarningCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _WarningCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.amber[700], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.4,
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

// 🎯 Features Grid
class _FeatureGrid extends StatelessWidget {
  final List<_FeatureItem> features;

  const _FeatureGrid(this.features);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return features[index];
      },
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.green[700], size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ℹ️ App Info Card
class _AppInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceVariant,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.apps_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MetaEdit Pro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Metadata Editor',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildInfoRow('📦 Version', '1.0.0'),
          const SizedBox(height: 8),
          _buildInfoRow('🔧 EXIF', 'native_exif ^0.7.0'),
          const SizedBox(height: 8),
          _buildInfoRow('🤖 AI', 'Google Gemini 1.5 Flash'),
          const SizedBox(height: 8),
          _buildInfoRow('📱 Platform', 'Android & iOS'),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '© 2026 - All rights reserved',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}