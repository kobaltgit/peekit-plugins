import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n.dart';
import '../models/plugin_item.dart';
import '../theme.dart';
import 'acrylic_box.dart';
import 'plugin_detail_dialog.dart';

class PluginCard extends StatelessWidget {
  final PluginItem plugin;
  final String locale;

  const PluginCard({
    super.key,
    required this.plugin,
    required this.locale,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '3D':
        return Icons.view_in_ar_rounded;
      case 'Documents':
        return Icons.description_rounded;
      case 'Fonts':
        return Icons.text_fields_rounded;
      case 'Spreadsheets':
        return Icons.table_chart_rounded;
      case 'Presentations':
        return Icons.slideshow_rounded;
      case 'Graphics':
        return Icons.draw_rounded;
      default:
        return Icons.extension_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '3D':
        return AppTheme.primary;
      case 'Documents':
        return const Color(0xFF3B82F6);
      case 'Fonts':
        return AppTheme.accentPurple;
      case 'Spreadsheets':
        return AppTheme.accentEmerald;
      case 'Presentations':
        return AppTheme.accentAmber;
      case 'Graphics':
        return const Color(0xFFFF9A00);
      default:
        return AppTheme.accentIndigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = _getCategoryColor(plugin.category);

    return AcrylicBox(
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      blur: 20,
      enableHover: true,
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => PluginDetailDialog(plugin: plugin, locale: locale),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Icon + Category Chip + Version
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getCategoryIcon(plugin.category), color: catColor, size: 24),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: catColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  plugin.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: catColor,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSubtle : AppTheme.lightSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'v${plugin.version}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Name
          Text(
            plugin.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),

          const SizedBox(height: 8),

          // Description (max 3 lines)
          Expanded(
            child: Text(
              plugin.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Supported extensions chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: plugin.extensions.map((ext) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ext,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.primary : AppTheme.primaryDark,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Bottom Action: Download button with size label + details
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => launchUrl(Uri.parse(plugin.downloadUrl)),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: Text(
                    '${WebsiteI18n.get('cat_download_btn', locale)} (${plugin.sizeKb})',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: WebsiteI18n.get('cat_details_btn', locale),
                icon: const Icon(Icons.info_outline_rounded, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => PluginDetailDialog(plugin: plugin, locale: locale),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
