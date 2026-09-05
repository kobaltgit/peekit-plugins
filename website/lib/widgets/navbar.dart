import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';
import 'acrylic_box.dart';

class Navbar extends StatelessWidget {
  final String locale;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLocale;
  final Function(String) onNavigate;

  const Navbar({
    super.key,
    required this.locale,
    required this.isDark,
    required this.onToggleTheme,
    required this.onToggleLocale,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 16,
      ),
      child: AcrylicBox(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        blur: 24,
        enableHover: false,
        child: Row(
          children: [
            // Logo + Title
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onNavigate('hero'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icon.png',
                      width: 32,
                      height: 32,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.extension,
                        color: AppTheme.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text.rich(
                      TextSpan(
                        text: 'PeekIt ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.darkText : AppTheme.lightText,
                          letterSpacing: -0.5,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Plugins',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Desktop Navigation links
            if (!isMobile) ...[
              _NavLink(
                label: WebsiteI18n.get('nav_catalog', locale),
                onTap: () => onNavigate('catalog'),
              ),
              _NavLink(
                label: WebsiteI18n.get('nav_demo', locale),
                onTap: () => onNavigate('demo'),
              ),
              _NavLink(
                label: WebsiteI18n.get('nav_dev', locale),
                onTap: () => onNavigate('dev'),
              ),
              _NavLink(
                label: WebsiteI18n.get('nav_faq', locale),
                onTap: () => onNavigate('faq'),
              ),
              const SizedBox(width: 8),
            ],

            // Language Toggle
            IconButton(
              tooltip: locale == 'ru' ? 'Switch to English' : 'Переключить на русский',
              icon: Text(
                locale.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              onPressed: onToggleLocale,
            ),

            // Theme Toggle
            IconButton(
              tooltip: isDark ? 'Light mode' : 'Dark mode',
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 20,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
              onPressed: onToggleTheme,
            ),

            // GitHub Button
            IconButton(
              tooltip: 'GitHub Repository',
              icon: const Icon(Icons.code, size: 20),
              onPressed: () => launchUrl(Uri.parse(AppConstants.repoPluginsUrl)),
            ),

            const SizedBox(width: 8),

            // Download PeekIt CTA button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => launchUrl(Uri.parse(AppConstants.peekitDownloadUrl)),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(
                isMobile ? 'PeekIt' : WebsiteI18n.get('nav_download_peekit', locale),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
