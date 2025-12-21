import 'package:flutter/material.dart';
import '../../../core/services/theme_service.dart';

class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool showShadow;
  final Color? customColor;
  
  const ThemedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.showShadow = true,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;
    
    Widget cardContent = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customColor ?? themeService.getCardColor(context),
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: Border.all(
          color: themeService.getBorderColor(context),
          width: 0.5,
        ),
        boxShadow: showShadow ? [
          BoxShadow(
            color: themeService.getShadowColor(context),
            blurRadius: themeService.isDarkMode(context) ? 15 : 10,
            offset: const Offset(0, 5),
          ),
        ] : null,
      ),
      child: child,
    );
    
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          child: cardContent,
        ),
      );
    }
    
    return cardContent;
  }
}