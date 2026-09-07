import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets/catalog_section.dart';
import 'widgets/dev_guide_section.dart';
import 'widgets/faq_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/interactive_demo.dart';
import 'package:kobalt_ui/kobalt_ui.dart';

void main() {
  runApp(const PeekItPluginsApp());
}

class PeekItPluginsApp extends StatefulWidget {
  const PeekItPluginsApp({super.key});

  @override
  State<PeekItPluginsApp> createState() => _PeekItPluginsAppState();
}

class _PeekItPluginsAppState extends State<PeekItPluginsApp> {
  bool _isDark = true;
  String _locale = 'ru';

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  void _toggleLocale() {
    setState(() {
      _locale = _locale == 'ru' ? 'en' : 'ru';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeekIt Plugins Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(_isDark),
      home: HomePage(
        isDark: _isDark,
        locale: _locale,
        onToggleTheme: _toggleTheme,
        onToggleLocale: _toggleLocale,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDark;
  final String locale;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLocale;

  const HomePage({
    super.key,
    required this.isDark,
    required this.locale,
    required this.onToggleTheme,
    required this.onToggleLocale,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _catalogKey = GlobalKey();
  final GlobalKey _demoKey = GlobalKey();
  final GlobalKey _devKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background ambient gradient glow orbs
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: widget.isDark ? 0.15 : 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 600,
            right: -100,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentIndigo.withValues(alpha: widget.isDark ? 0.12 : 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main scrollable content with sticky KobaltNavBar
          Column(
            children: [
              KobaltNavBar(
                project: KobaltProjectId.peekItPlugins,
                version: 'v1.0.0',
                isRussian: widget.locale == 'ru',
                onLanguageToggle: widget.onToggleLocale,
                accentColor: AppTheme.primary,
                navLinks: [
                  KobaltNavLink(
                    label: widget.locale == 'ru' ? 'Каталог' : 'Catalog',
                    onTap: () => _scrollToKey(_catalogKey),
                  ),
                  KobaltNavLink(
                    label: widget.locale == 'ru' ? 'Демо' : 'Demo',
                    onTap: () => _scrollToKey(_demoKey),
                  ),
                  KobaltNavLink(
                    label: widget.locale == 'ru' ? 'Разработка' : 'Dev Guide',
                    onTap: () => _scrollToKey(_devKey),
                  ),
                  KobaltNavLink(
                    label: widget.locale == 'ru' ? 'FAQ' : 'FAQ',
                    onTap: () => _scrollToKey(_faqKey),
                  ),
                ],
                onDownloadTap: () => _scrollToKey(_catalogKey),
                extraActions: [
                  IconButton(
                    icon: Icon(
                      widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      size: 18,
                      color: widget.isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                    onPressed: widget.onToggleTheme,
                    tooltip: widget.locale == 'ru' ? 'Переключить тему' : 'Toggle theme',
                  ),
                ],
              ),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Hero Section
                    SliverToBoxAdapter(
                      child: HeroSection(
                        locale: widget.locale,
                        onExplore: () => _scrollToKey(_catalogKey),
                      ),
                    ),

                    // Catalog Section
                    SliverToBoxAdapter(
                      key: _catalogKey,
                      child: CatalogSection(locale: widget.locale),
                    ),

                    // Interactive Demo Section
                    SliverToBoxAdapter(
                      key: _demoKey,
                      child: InteractiveDemoSection(locale: widget.locale),
                    ),

                    // Developer Guide Section
                    SliverToBoxAdapter(
                      key: _devKey,
                      child: DevGuideSection(locale: widget.locale),
                    ),

                    // FAQ Section
                    SliverToBoxAdapter(
                      key: _faqKey,
                      child: FaqSection(locale: widget.locale),
                    ),

                    // Footer
                    SliverToBoxAdapter(
                      child: KobaltFooter(
                        project: KobaltProjectId.peekItPlugins,
                        version: 'v1.0.0',
                        isRussian: widget.locale == 'ru',
                        accentColor: AppTheme.primary,
                        onBackToTop: () {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
