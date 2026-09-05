import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';
import 'acrylic_box.dart';

class HeroSection extends StatefulWidget {
  final String locale;
  final VoidCallback onExplore;

  const HeroSection({
    super.key,
    required this.locale,
    required this.onExplore,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  int _activeDemoIndex = 0;
  bool _isSpacePressed = false;

  final List<Map<String, dynamic>> _demoFiles = [
    {
      'name': 'spacex_dragon.stl',
      'type': '3D CAD Model',
      'icon': Icons.view_in_ar_rounded,
      'color': AppTheme.primary,
      'preview': 'Three.js 60 FPS Viewport\n52,400 Triangles',
    },
    {
      'name': 'quarterly_report.docx',
      'type': 'Word Document',
      'icon': Icons.description_rounded,
      'color': Color(0xFF2563EB),
      'preview': 'Page 1 of 14 (A4 Print Layout)\nTables, Vector Charts & Images',
    },
    {
      'name': 'financial_model.xlsx',
      'type': 'Excel Sheet',
      'icon': Icons.table_chart_rounded,
      'color': Color(0xFF10B981),
      'preview': 'Sheet: Summary Q3\nFormulas Calculated Real-Time',
    },
    {
      'name': 'inter_variable.woff2',
      'type': 'Vector Font',
      'icon': Icons.text_fields_rounded,
      'color': Color(0xFFA855F7),
      'preview': 'Sphinx of black quartz, judge my vow.\nUnicode Glyphs: 1,842',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: isMobile ? 32 : 64,
      ),
      child: Column(
        children: [
          // Tag Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  WebsiteI18n.get('hero_tag', widget.locale),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Main Title
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Text(
              WebsiteI18n.get('hero_title', widget.locale),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 32 : 54,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                height: 1.15,
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Subtitle
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              WebsiteI18n.get('hero_subtitle', widget.locale),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 15 : 18,
                height: 1.6,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // CTA Buttons
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: AppTheme.primary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: widget.onExplore,
                icon: const Icon(Icons.grid_view_rounded, size: 20),
                label: Text(
                  WebsiteI18n.get('hero_btn_explore', widget.locale),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppTheme.darkText : AppTheme.lightText,
                  side: BorderSide(
                    color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => launchUrl(Uri.parse(AppConstants.peekitDownloadUrl)),
                icon: const Icon(Icons.desktop_windows_rounded, size: 20),
                label: Text(
                  WebsiteI18n.get('hero_btn_peekit', widget.locale),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Metrics / Feature Badges
          Wrap(
            spacing: 24,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _FeatureBadge(
                icon: Icons.wifi_off_rounded,
                text: WebsiteI18n.get('hero_badge_offline', widget.locale),
                color: AppTheme.accentEmerald,
              ),
              _FeatureBadge(
                icon: Icons.security_rounded,
                text: WebsiteI18n.get('hero_badge_sandbox', widget.locale),
                color: AppTheme.accentIndigo,
              ),
              _FeatureBadge(
                icon: Icons.speed_rounded,
                text: WebsiteI18n.get('hero_badge_speed', widget.locale),
                color: AppTheme.primary,
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Spacebar Interaction Simulator Card
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: AcrylicBox(
              borderRadius: 24,
              padding: const EdgeInsets.all(28),
              blur: 32,
              child: Column(
                children: [
                  // File Selector Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_demoFiles.length, (index) {
                        final file = _demoFiles[index];
                        final isSelected = index == _activeDemoIndex;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ChoiceChip(
                            avatar: Icon(
                              file['icon'] as IconData,
                              size: 16,
                              color: isSelected ? Colors.white : file['color'] as Color,
                            ),
                            label: Text(file['name'] as String),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryDark,
                            backgroundColor: isDark ? AppTheme.darkSubtle : AppTheme.lightSubtle,
                            labelStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppTheme.darkText : AppTheme.lightText),
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _activeDemoIndex = index);
                            },
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Spacebar Tap Button
                  GestureDetector(
                    onTapDown: (_) => setState(() => _isSpacePressed = true),
                    onTapUp: (_) => setState(() => _isSpacePressed = false),
                    onTapCancel: () => setState(() => _isSpacePressed = false),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: isMobile ? double.infinity : 320,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        transform: _isSpacePressed
                            ? Matrix4.translationValues(0.0, 3.0, 0.0)
                            : Matrix4.identity(),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isSpacePressed
                                ? [AppTheme.primaryDark, AppTheme.primary]
                                : [
                                    isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                    isDark ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isSpacePressed
                                ? AppTheme.primary
                                : (isDark ? Colors.white24 : Colors.black12),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isSpacePressed
                                  ? AppTheme.primary.withValues(alpha: 0.5)
                                  : Colors.black26,
                              blurRadius: _isSpacePressed ? 16 : 6,
                              offset: Offset(0, _isSpacePressed ? 2 : 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.keyboard_rounded,
                                size: 18,
                                color: _isSpacePressed ? Colors.white : AppTheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${WebsiteI18n.get('demo_spacebar_label', widget.locale)} (TAP TO PREVIEW)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  fontSize: 12,
                                  color: _isSpacePressed
                                      ? Colors.white
                                      : (isDark ? AppTheme.darkText : AppTheme.lightText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Simulated Preview Window
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF07090E) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (_demoFiles[_activeDemoIndex]['color'] as Color).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _demoFiles[_activeDemoIndex]['icon'] as IconData,
                              color: _demoFiles[_activeDemoIndex]['color'] as Color,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _demoFiles[_activeDemoIndex]['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (_demoFiles[_activeDemoIndex]['color'] as Color).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _demoFiles[_activeDemoIndex]['type'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _demoFiles[_activeDemoIndex]['color'] as Color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _demoFiles[_activeDemoIndex]['preview'] as String,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            height: 1.5,
                            color: isDark ? AppTheme.darkText : AppTheme.lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _FeatureBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
