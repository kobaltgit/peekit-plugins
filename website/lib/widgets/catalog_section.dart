import 'package:flutter/material.dart';
import '../i18n.dart';
import '../models/plugin_item.dart';
import '../services/registry_service.dart';
import '../theme.dart';
import 'acrylic_box.dart';
import 'plugin_card.dart';

class CatalogSection extends StatefulWidget {
  final String locale;

  const CatalogSection({super.key, required this.locale});

  @override
  State<CatalogSection> createState() => _CatalogSectionState();
}

class _CatalogSectionState extends State<CatalogSection> {
  final TextEditingController _searchController = TextEditingController();
  List<PluginItem> _allPlugins = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    '3D',
    'Documents',
    'Spreadsheets',
    'Fonts',
    'Presentations',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _loadData() async {
    final plugins = await RegistryService.loadPlugins();
    if (mounted) {
      setState(() {
        _allPlugins = plugins;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getCategoryLabel(String cat) {
    switch (cat) {
      case 'All':
        return WebsiteI18n.get('cat_all', widget.locale);
      case '3D':
        return WebsiteI18n.get('cat_3d', widget.locale);
      case 'Documents':
        return WebsiteI18n.get('cat_docs', widget.locale);
      case 'Spreadsheets':
        return WebsiteI18n.get('cat_sheets', widget.locale);
      case 'Fonts':
        return WebsiteI18n.get('cat_fonts', widget.locale);
      case 'Presentations':
        return WebsiteI18n.get('cat_slides', widget.locale);
      default:
        return cat;
    }
  }

  List<PluginItem> get _filteredPlugins {
    final query = _searchController.text.trim().toLowerCase();

    return _allPlugins.where((plugin) {
      // Category filter
      if (_selectedCategory != 'All' && plugin.category != _selectedCategory) {
        return false;
      }

      // Search filter
      if (query.isEmpty) return true;

      final matchName = plugin.name.toLowerCase().contains(query);
      final matchDesc = plugin.description.toLowerCase().contains(query);
      final matchId = plugin.id.toLowerCase().contains(query);
      final matchExt = plugin.extensions.any((ext) => ext.toLowerCase().contains(query));

      return matchName || matchDesc || matchId || matchExt;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final isTablet = screenWidth >= 700 && screenWidth < 1150;

    int crossAxisCount = 3;
    if (isMobile) {
      crossAxisCount = 1;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section Title
          Text(
            WebsiteI18n.get('cat_title', widget.locale),
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
            WebsiteI18n.get('cat_subtitle', widget.locale),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),

          const SizedBox(height: 36),

          // Search Bar
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: AcrylicBox(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              blur: 20,
              enableHover: false,
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                  hintText: WebsiteI18n.get('cat_search_hint', widget.locale),
                  hintStyle: TextStyle(
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(_getCategoryLabel(cat)),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: AppTheme.primary,
                    backgroundColor: isDark ? AppTheme.darkSubtle : AppTheme.lightSubtle,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppTheme.darkText : AppTheme.lightText),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primary
                            : (isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 36),

          // Catalog Grid
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_filteredPlugins.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.darkTextMuted),
                  const SizedBox(height: 16),
                  Text(
                    WebsiteI18n.get('cat_no_results', widget.locale),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredPlugins.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 310,
                ),
                itemBuilder: (context, index) {
                  return PluginCard(
                    plugin: _filteredPlugins[index],
                    locale: widget.locale,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
