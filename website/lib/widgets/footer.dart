import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';
import 'acrylic_box.dart';

class Footer extends StatelessWidget {
  final String locale;

  const Footer({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Padding(
      padding: EdgeInsets.only(
        left: isMobile ? 16 : 48,
        right: isMobile ? 16 : 48,
        bottom: 32,
        top: 24,
      ),
      child: AcrylicBox(
        borderRadius: 20,
        padding: const EdgeInsets.all(32),
        blur: 24,
        enableHover: false,
        child: Column(
          children: [
            // Top row: Brand + Sister projects
            Wrap(
              spacing: 32,
              runSpacing: 24,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Brand
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icon.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.extension,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'PeekIt Plugins',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                    ),
                  ],
                ),

                // Sister Projects
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      WebsiteI18n.get('footer_sister_projects', locale),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                    _textLink('PeekIt', AppConstants.peekitSiteUrl),
                    _textLink('MiniBin', AppConstants.minibinUrl),
                    _textLink('Undoit', AppConstants.undoitUrl),
                    _textLink('PolyShift', AppConstants.polyShiftUrl),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Bottom row: Legal links & Copyright
            Wrap(
              spacing: 20,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  WebsiteI18n.get('footer_rights', locale),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
                _textLink('LICENSE', AppConstants.licenseUrl),
                _textLink('CONTRIBUTING', AppConstants.contributingUrl),
                _textLink('SECURITY', AppConstants.securityUrl),
                _textLink('GitHub', AppConstants.repoPluginsUrl),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _textLink(String label, String url) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => launchUrl(Uri.parse(url)),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
