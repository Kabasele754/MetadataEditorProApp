import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/metadata_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MetadataProvider>(
      builder: (context, provider, child) {
        final stats = provider.statistics;
        final totalImages = stats['total'] ?? 0;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 🎨 App Bar with Gradient
              SliverAppBar(
                expandedHeight: 140,
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
                              Icons.analytics_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Statistics',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalImages images analyzed',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
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
                      // 📊 EXIF Metadata Section
                      _buildSectionHeader(
                        context,
                        icon: Icons.tag_rounded,
                        title: 'EXIF Metadata',
                        subtitle: 'Image distribution',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),

                      _MetadataCard(stats: stats),
                      const SizedBox(height: 24),

                      // 🤖 AI Detection Section
                      _buildSectionHeader(
                        context,
                        icon: Icons.psychology_rounded,
                        title: '🤖 AI Detection',
                        subtitle: 'Google Gemini Analysis',
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 12),

                      _AIDetectionCards(stats: stats),
                      const SizedBox(height: 24),

                      // 📈 Progress Section
                      _buildSectionHeader(
                        context,
                        icon: Icons.trending_up_rounded,
                        title: 'Progress',
                        subtitle: 'Your library status',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),

                      _ProgressCards(stats: stats),
                      const SizedBox(height: 24),

                      // ℹ️ Info Section
                      _InfoBanner(),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
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
}

// 📊 Metadata Card with Pie Chart
class _MetadataCard extends StatelessWidget {
  final Map<String, int> stats;

  const _MetadataCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final withMeta = stats['withMetadata'] ?? 0;
    final withoutMeta = stats['withoutMetadata'] ?? 0;
    final percentage = stats['percentage'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: withMeta.toDouble(),
                        title: '',
                        color: Colors.green.shade400,
                        radius: 70,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: withoutMeta.toDouble(),
                        title: '',
                        color: Colors.orange.shade400,
                        radius: 70,
                        showTitle: false,
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    startDegreeOffset: -90,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'with metadata',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(
                color: Colors.green.shade400,
                label: 'With Metadata',
                value: withMeta.toString(),
              ),
              _LegendItem(
                color: Colors.orange.shade400,
                label: 'Without Metadata',
                value: withoutMeta.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 🤖 AI Detection Cards
class _AIDetectionCards extends StatelessWidget {
  final Map<String, int> stats;

  const _AIDetectionCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _GradientStatCard(
                icon: Icons.rocket_rounded,
                label: 'AI Images',
                value: stats['aiGenerated'] ?? 0,
                gradient: const LinearGradient(
                  colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                ),
                subtitle: 'Detected',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _GradientStatCard(
                icon: Icons.verified_user_rounded,
                label: 'Real Images',
                value: stats['realImages'] ?? 0,
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                ),
                subtitle: 'Verified',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _GradientStatCard(
          icon: Icons.question_mark_rounded,
          label: 'Not Analyzed',
          value: stats['unknownAI'] ?? 0,
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          subtitle: 'Pending',
          fullWidth: true,
        ),
      ],
    );
  }
}

// 📈 Progress Cards
class _ProgressCards extends StatelessWidget {
  final Map<String, int> stats;

  const _ProgressCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats['total'] ?? 1;
    final withMeta = stats['withMetadata'] ?? 0;
    final aiGenerated = stats['aiGenerated'] ?? 0;

    return Column(
      children: [
        _ProgressCard(
          title: 'Metadata Coverage',
          value: stats['percentage'] ?? 0,
          total: 100,
          color: Colors.green,
          icon: Icons.tag_rounded,
        ),
        const SizedBox(height: 10),
        _ProgressCard(
          title: 'AI Analyzed Images',
          value: ((stats['aiGenerated'] ?? 0) + (stats['realImages'] ?? 0)),
          total: total,
          color: Colors.purple,
          icon: Icons.psychology_rounded,
        ),
      ],
    );
  }
}

// 🎨 Gradient Stat Card
class _GradientStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Gradient gradient;
  final String subtitle;
  final bool fullWidth;

  const _GradientStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    required this.subtitle,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// 📊 Legend Item
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 📈 Progress Card
class _ProgressCard extends StatelessWidget {
  final String title;
  final int value;
  final int total;
  final Color color;
  final IconData icon;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? ((value / total) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value / $total images',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// ℹ️ Info Banner
class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceVariant,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pro Tip',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Analyze all your images with Gemini for better traceability',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
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