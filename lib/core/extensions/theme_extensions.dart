import 'package:flutter/material.dart';
import '../services/theme_service.dart';

extension ThemeExtensions on BuildContext {
  /// Get the ThemeService instance
  ThemeService get themeService => ThemeService.instance;
  
  /// Check if current theme is dark
  bool get isDarkMode => themeService.isDarkMode(this);
  
  /// Get theme-aware text color
  Color get textColor => themeService.getTextColor(this);
  
  /// Get theme-aware subtitle color
  Color get subtitleColor => themeService.getSubtitleColor(this);
  
  /// Get theme-aware card color
  Color get cardColor => themeService.getCardColor(this);
  
  /// Get theme-aware surface color
  Color get surfaceColor => themeService.getSurfaceColor(this);
  
  /// Get theme-aware border color
  Color get borderColor => themeService.getBorderColor(this);
  
  /// Get theme-aware icon color
  Color get iconColor => themeService.getIconColor(this);
  
  /// Get theme-aware shadow color
  Color get shadowColor => themeService.getShadowColor(this);
  
  /// Get background gradient
  LinearGradient get backgroundGradient => themeService.getBackgroundGradient(this);
  
  /// Get card decoration
  BoxDecoration get cardDecoration => themeService.getCardDecoration(this);
  
  /// Get themed color based on light/dark mode
  Color themedColor(Color lightColor, Color darkColor) => 
      themeService.getThemedColor(this, lightColor, darkColor);
}