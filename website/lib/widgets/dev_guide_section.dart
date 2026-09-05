import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';
import 'acrylic_box.dart';

class DevGuideSection extends StatelessWidget {
  final String locale;

  const DevGuideSection({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: 48,
      ),
      child: Column(
        children: [
          // Title
          Text(
            WebsiteI18n.get('dev_title', locale),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 28 : 38,
              fontWeight: FontWeight.w900,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Text(
              WebsiteI18n.get('dev_subtitle', locale),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Cards & Terminal Row
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: isMobile
                ? Column(
                    children: [
                      _buildSteps(isDark, locale),
                      const SizedBox(height: 24),
                      _buildTerminal(isDark),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _buildSteps(isDark, locale)),
                      const SizedBox(width: 24),
                      Expanded(flex: 6, child: _buildTerminal(isDark)),
                    ],
                  ),
          ),

          const SizedBox(height: 36),

          // CTA Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: () => launchUrl(Uri.parse(AppConstants.devGuideUrl)),
            icon: const Icon(Icons.menu_book_rounded, size: 20),
            label: Text(
              WebsiteI18n.get('dev_btn_guide', locale),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSteps(bool isDark, String locale) {
    return Column(
      children: [
        _stepCard(
          icon: Icons.copy_rounded,
          color: AppTheme.primary,
          title: WebsiteI18n.get('dev_step1_title', locale),
          desc: WebsiteI18n.get('dev_step1_desc', locale),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _stepCard(
          icon: Icons.archive_rounded,
          color: AppTheme.accentEmerald,
          title: WebsiteI18n.get('dev_step2_title', locale),
          desc: WebsiteI18n.get('dev_step2_desc', locale),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _stepCard(
          icon: Icons.publish_rounded,
          color: AppTheme.accentPurple,
          title: WebsiteI18n.get('dev_step3_title', locale),
          desc: WebsiteI18n.get('dev_step3_desc', locale),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _stepCard({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return AcrylicBox(
      borderRadius: 16,
      padding: const EdgeInsets.all(20),
      blur: 20,
      enableHover: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminal(bool isDark) {
    const code = '''# 1. Скопируйте заготовку плагина
cp -r template plugins/peekit-plugin-myformat

# 2. Упакуйте плагин в формат .pkit
node pack_plugin.cjs plugins/peekit-plugin-myformat

# Вывод сборщика:
✓ Packed: My Format Viewer (com.peekit.myformat)
  File: com.peekit.myformat-1.0.0.pkit [124.5 KB]
  SHA256: 4f89d02c... Verified!''';

    return AcrylicBox(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      blur: 24,
      customBgColor: const Color(0xFF030712).withValues(alpha: 0.9),
      enableHover: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mac/Window buttons header
          Row(
            children: [
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
              const SizedBox(width: 14),
              const Text(
                'bash - PeekIt Packager CLI',
                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.5,
              height: 1.55,
              color: Color(0xFF38BDF8),
            ),
          ),
        ],
      ),
    );
  }
}
