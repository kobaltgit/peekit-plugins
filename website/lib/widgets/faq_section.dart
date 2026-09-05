import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';
import 'acrylic_box.dart';

class FaqSection extends StatelessWidget {
  final String locale;

  const FaqSection({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final faqs = [
      {'q': 'faq_q1', 'a': 'faq_a1'},
      {'q': 'faq_q2', 'a': 'faq_a2'},
      {'q': 'faq_q3', 'a': 'faq_a3'},
      {'q': 'faq_q4', 'a': 'faq_a4'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: 48,
      ),
      child: Column(
        children: [
          // Title
          Text(
            WebsiteI18n.get('faq_title', locale),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 28 : 38,
              fontWeight: FontWeight.w900,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            WebsiteI18n.get('faq_subtitle', locale),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),

          const SizedBox(height: 36),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: faqs.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AcrylicBox(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    blur: 16,
                    enableHover: false,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: AppTheme.primary,
                        collapsedIconColor: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(bottom: 12),
                        title: Text(
                          WebsiteI18n.get(item['q']!, locale),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.darkText : AppTheme.lightText,
                          ),
                        ),
                        children: [
                          Text(
                            WebsiteI18n.get(item['a']!, locale),
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.55,
                              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
