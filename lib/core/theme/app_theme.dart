import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Brand Colors - Updated to match welcome screen
  static const Color primaryBlue = Color(0xFF4a90e2);
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color primaryOrange = Color(0xFFff6f2d);
  static const Color primaryGreen = Color(0xFF10B981);
  
  // Dark Theme Colors - Updated to match welcome screen
  static const Color darkPrimary = Color(0xFF0F0F23);
  static const Color darkSecondary = Color(0xFF1A1A2E);
  static const Color darkTertiary = Color(0xFF16213E);
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkCard = Color(0xFF2A2A3E);
  
  // Light Theme Colors - Updated to match welcome screen
  static const Color lightPrimary = Color(0xFFF8FAFC);
  static const Color lightSecondary = Color(0xFFE2E8F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  
  // Gradients - Updated to match welcome screen
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, primaryBlue],
  );
  
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkPrimary, darkSecondary, darkTertiary],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightPrimary, lightSecondary],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
  );
  
  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );
  
  // Text Styles
  static const TextStyle heroTitleDark = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );
  
  static const TextStyle heroTitleLight = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1E293B),
    height: 1.2,
  );
  
  static const TextStyle titleDark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle titleLight = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1E293B),
  );
  
  static const TextStyle subtitleDark = TextStyle(
    fontSize: 16,
    color: Color(0xB3FFFFFF),
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle subtitleLight = TextStyle(
    fontSize: 16,
    color: Color(0xFF64748B),
    fontWeight: FontWeight.w500,
  );
  
  // Theme Data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: lightPrimary,
    cardColor: lightCard,
    dividerColor: const Color(0xFFE2E8F0),
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: titleLight,
      iconTheme: IconThemeData(color: Color(0xFF1E293B)),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: titleLight,
      displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF334155)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(color: Color(0xFF64748B)),
    
    // Bottom Navigation Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryPink,
      surface: lightSurface,
      background: lightPrimary,
      error: Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1E293B),
      onBackground: Color(0xFF1E293B),
      onError: Colors.white,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: darkPrimary,
    cardColor: darkCard,
    dividerColor: const Color(0xFF374151),
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: titleDark,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: titleDark,
      displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE2E8F0)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB3FFFFFF)),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(color: Color(0xFFE2E8F0)),
    
    // Bottom Navigation Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF374151)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF374151)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: primaryPink,
      surface: darkSurface,
      background: darkPrimary,
      error: Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),
  );

  // Helper methods for backward compatibility
  static BoxDecoration getCardDecoration(bool isDark) => BoxDecoration(
    gradient: isDark ? darkCardGradient : lightCardGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
      width: 1,
    ),
  );

  // Additional helper methods
  static LinearGradient getBackgroundGradient(bool isDark) => 
    isDark ? darkBackgroundGradient : lightBackgroundGradient;

  static Color getCardColor(bool isDark) => isDark ? darkCard : lightCard;
  static Color getBorderColor(bool isDark) => isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0);
  static Color getTextColor(bool isDark) => isDark ? Colors.white : const Color(0xFF1E293B);
  static Color getSubtextColor(bool isDark) => isDark ? const Color(0xB3FFFFFF) : const Color(0xFF64748B);
  
  // Text style helpers
  static TextStyle getHeroTitle(bool isDark) => isDark ? heroTitleDark : heroTitleLight;
  static TextStyle getTitle(bool isDark) => isDark ? titleDark : titleLight;
  static TextStyle getSubtitle(bool isDark) => isDark ? subtitleDark : subtitleLight;
  
  // Button decoration
  static BoxDecoration get buttonDecoration => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryBlue.withOpacity(0.4),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}