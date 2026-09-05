import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';
import 'acrylic_box.dart';

class InteractiveDemoSection extends StatefulWidget {
  final String locale;

  const InteractiveDemoSection({super.key, required this.locale});

  @override
  State<InteractiveDemoSection> createState() => _InteractiveDemoSectionState();
}

class _InteractiveDemoSectionState extends State<InteractiveDemoSection>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: 3D Model, 1: Spreadsheet, 2: Font
  late AnimationController _rotationController;
  bool _wireframe = false;
  double _fontSize = 24.0;
  final String _pangramText = 'Съешь же ещё этих мягких французских булок, да выпей чаю.';

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: 48,
      ),
      child: Column(
        children: [
          // Header
          Text(
            WebsiteI18n.get('demo_title', widget.locale),
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
            WebsiteI18n.get('demo_subtitle', widget.locale),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),

          const SizedBox(height: 36),

          // Main Interactive Box
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: AcrylicBox(
              borderRadius: 24,
              padding: const EdgeInsets.all(28),
              blur: 24,
              enableHover: false,
              child: Column(
                children: [
                  // Tab Switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _tabButton(0, Icons.view_in_ar_rounded, '3D Model (STL/OBJ)', isDark),
                      const SizedBox(width: 8),
                      _tabButton(1, Icons.table_chart_rounded, 'Spreadsheet (XLSX)', isDark),
                      const SizedBox(width: 8),
                      _tabButton(2, Icons.text_fields_rounded, 'Font (WOFF2)', isDark),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Interactive Viewport
                  Container(
                    height: 380,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF07090E) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _buildActiveDemo(isDark),
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

  Widget _tabButton(int index, IconData icon, String title, bool isDark) {
    final isSelected = _activeTab == index;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primary.withValues(alpha: 0.15) : Colors.transparent,
        foregroundColor: isSelected ? AppTheme.primary : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : (isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => setState(() => _activeTab = index),
      icon: Icon(icon, size: 18),
      label: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildActiveDemo(bool isDark) {
    switch (_activeTab) {
      case 0:
        return _build3dDemo(isDark);
      case 1:
        return _buildSpreadsheetDemo(isDark);
      case 2:
        return _buildFontDemo(isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _build3dDemo(bool isDark) {
    return Stack(
      children: [
        // 3D Canvas
        Center(
          child: AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              final angle = _rotationController.value * 2 * math.pi;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(0.5)
                  ..rotateY(angle),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: _wireframe
                        ? Colors.transparent
                        : AppTheme.primary.withValues(alpha: 0.25),
                    border: Border.all(
                      color: AppTheme.primary,
                      width: _wireframe ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.view_in_ar_rounded,
                      size: 64,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Controls overlay
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Wireframe Mode'),
                selected: _wireframe,
                onSelected: (val) => setState(() => _wireframe = val),
                selectedColor: AppTheme.primary,
                checkmarkColor: Colors.white,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Three.js WebGL • 60 FPS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpreadsheetDemo(bool isDark) {
    final rows = [
      ['A1', 'Revenue Q1', '\$124,500', '12%'],
      ['A2', 'Operating Costs', '-\$45,200', '-3%'],
      ['A3', 'Gross Profit', '\$79,300', '18%'],
      ['A4', 'R&D Investment', '-\$22,100', '5%'],
      ['A5', 'Net Income', '\$57,200', '24%'],
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart_rounded, color: AppTheme.accentEmerald, size: 18),
              const SizedBox(width: 8),
              const Text('financial_summary.xlsx (Sheet: Dashboard)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('SheetJS Powered', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accentEmerald)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(
                  color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSubtle : AppTheme.lightSubtle,
                    ),
                    children: const [
                      Padding(padding: EdgeInsets.all(8), child: Text('Cell', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Metric', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Amount (USD)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Growth', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                    ],
                  ),
                  ...rows.map((row) {
                    return TableRow(
                      children: row.map((cell) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            cell,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontDemo(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.text_fields_rounded, color: AppTheme.accentPurple, size: 18),
              const SizedBox(width: 8),
              const Text('Inter-Variable.woff2', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const Spacer(),
              Text('${_fontSize.round()}px', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              SizedBox(
                width: 140,
                child: Slider(
                  value: _fontSize,
                  min: 14,
                  max: 48,
                  activeColor: AppTheme.accentPurple,
                  onChanged: (val) => setState(() => _fontSize = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  _pangramText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 1.4,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
