import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'app_theme_mode';
  static ThemeService? _instance;
  
  ThemeService._internal();
  
  static ThemeService get instance {
    _instance ??= ThemeService._internal();
    return _instance!;
  }
  
  /// Get saved theme mode from storage
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    return ThemeMode.values[themeIndex];
  }
  
  /// Save theme mode to storage
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
  }
  
  /// Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// Get appropriate color based on theme
  Color getThemedColor(BuildContext context, Color lightColor, Color darkColor) {
    return isDarkMode(context) ? darkColor : lightColor;
  }
  
  /// Get appropriate text color based on theme
  Color getTextColor(BuildContext context) {
    return isDarkMode(context) 
        ? Colors.white 
        : const Color(0xFF1E293B);
  }
  
  /// Get appropriate subtitle color based on theme
  Color getSubtitleColor(BuildContext context) {
    return isDarkMode(context) 
        ? Colors.white.withOpacity(0.7) 
        : const Color(0xFF64748B);
  }
  
  /// Get appropriate card color based on theme
  Color getCardColor(BuildContext context) {
    return isDarkMode(context) 
        ? const Color(0xFF2A2A3E) 
        : const Color(0xFFF1F5F9);
  }
  
  /// Get appropriate surface color based on theme
  Color getSurfaceColor(BuildContext context) {
    return isDarkMode(context) 
        ? const Color(0xFF1E1E2E) 
        : Colors.white;
  }
  
  /// Get appropriate border color based on theme
  Color getBorderColor(BuildContext context) {
    return isDarkMode(context) 
        ? Colors.white.withOpacity(0.2) 
        : Colors.grey.withOpacity(0.3);
  }
  
  /// Get appropriate icon color based on theme
  Color getIconColor(BuildContext context) {
    return isDarkMode(context) 
        ? Colors.white.withOpacity(0.9) 
        : const Color(0xFF64748B);
  }
  
  /// Get appropriate shadow color based on theme
  Color getShadowColor(BuildContext context) {
    return isDarkMode(context) 
        ? Colors.black.withOpacity(0.3) 
        : Colors.black.withOpacity(0.1);
  }
  
  /// Get background gradient based on theme
  LinearGradient getBackgroundGradient(BuildContext context) {
    return isDarkMode(context) 
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF16213E)],
            stops: [0.0, 0.5, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
            stops: [0.0, 1.0],
          );
  }
  
  /// Get card decoration based on theme
  BoxDecoration getCardDecoration(BuildContext context) {
    final isDark = isDarkMode(context);
    return BoxDecoration(
      color: getCardColor(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: getBorderColor(context)),
      boxShadow: [
        BoxShadow(
          color: getShadowColor(context),
          blurRadius: isDark ? 15 : 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}