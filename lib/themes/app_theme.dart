import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFff6f2d);
  static const Color secondaryColor = Color(0xFF4a90e2);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0e1330);
  static const Color darkSurface = Color(0xFF17173a);
  static const Color darkCard = Color(0xFF1a1f3a);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkSurface,
      background: darkBackground,
    ),
  );
  
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightSurface,
      background: lightBackground,
    ),
  );
  
  static LinearGradient getDarkGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBackground, darkSurface, darkCard],
    stops: [0.0, 0.6, 1.0],
  );
  
  static LinearGradient getLightGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
    stops: [0.0, 0.6, 1.0],
  );
  
  static Color getTextColor(bool isDark) => isDark ? Colors.white : const Color(0xFF0e1330);
  static Color getSubtextColor(bool isDark) => isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF17173a);
  static Color getCardColor(bool isDark) => isDark ? Colors.white.withOpacity(0.1) : Colors.white;
  static Color getBorderColor(bool isDark) => isDark ? Colors.white.withOpacity(0.2) : const Color(0xFFE2E8F0);
}