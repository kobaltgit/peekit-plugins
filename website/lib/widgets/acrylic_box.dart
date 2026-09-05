import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class AcrylicBox extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final bool enableHover;
  final Color? customBgColor;
  final VoidCallback? onTap;

  const AcrylicBox({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.blur = 16.0,
    this.enableHover = true,
    this.customBgColor,
    this.onTap,
  });

  @override
  State<AcrylicBox> createState() => _AcrylicBoxState();
}

class _AcrylicBoxState extends State<AcrylicBox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = isDark
        ? AppTheme.darkCard.withValues(alpha: _isHovered && widget.enableHover ? 0.85 : 0.65)
        : AppTheme.lightCard.withValues(alpha: _isHovered && widget.enableHover ? 0.95 : 0.8);

    final borderColor = isDark
        ? (_isHovered && widget.enableHover
            ? AppTheme.primary.withValues(alpha: 0.5)
            : AppTheme.darkCardBorder.withValues(alpha: 0.7))
        : (_isHovered && widget.enableHover
            ? AppTheme.primary.withValues(alpha: 0.6)
            : AppTheme.lightCardBorder.withValues(alpha: 0.9));

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: widget.margin,
      transform: _isHovered && widget.enableHover
          ? Matrix4.translationValues(0.0, -3.0, 0.0)
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: widget.customBgColor ?? defaultBg,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: _isHovered && widget.enableHover ? 0.45 : 0.25)
                : Colors.blueGrey.withValues(alpha: _isHovered && widget.enableHover ? 0.15 : 0.08),
            blurRadius: _isHovered && widget.enableHover ? 24 : 14,
            offset: Offset(0, _isHovered && widget.enableHover ? 8 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
          child: Padding(
            padding: widget.padding,
            child: Material(
              type: MaterialType.transparency,
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.onTap != null || widget.enableHover) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: widget.onTap != null
            ? GestureDetector(onTap: widget.onTap, child: content)
            : content,
      );
    }

    return content;
  }
}
