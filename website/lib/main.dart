import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets/catalog_section.dart';
import 'widgets/dev_guide_section.dart';
import 'widgets/faq_section.dart';
import 'widgets/footer.dart';
import 'widgets/hero_section.dart';
import 'widgets/interactive_demo.dart';
import 'widgets/navbar.dart';

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

  void _onNavigate(String section) {
    switch (section) {
      case 'hero':
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
        break;
      case 'catalog':
        _scrollToKey(_catalogKey);
        break;
      case 'demo':
        _scrollToKey(_demoKey);
        break;
      case 'dev':
        _scrollToKey(_devKey);
        break;
      case 'faq':
        _scrollToKey(_faqKey);
        break;
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

          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Sticky Navbar
              SliverToBoxAdapter(
                child: Navbar(
                  locale: widget.locale,
                  isDark: widget.isDark,
                  onToggleTheme: widget.onToggleTheme,
                  onToggleLocale: widget.onToggleLocale,
                  onNavigate: _onNavigate,
                ),
              ),

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
                child: Footer(locale: widget.locale),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
