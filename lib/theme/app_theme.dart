import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF6366F1);
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color primaryOrange = Color(0xFFF59E0B);
  static const Color primaryGreen = Color(0xFF10B981);
  
  static const Color darkPrimary = Color(0xFF0F0F23);
  static const Color darkSecondary = Color(0xFF1A1A2E);
  static const Color darkTertiary = Color(0xFF16213E);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPink, primaryOrange],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkPrimary, darkSecondary, darkTertiary],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
  );
  
  static const TextStyle heroTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );
  
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: Color(0xB3FFFFFF),
    fontWeight: FontWeight.w500,
  );
  
  static BoxDecoration get cardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.2)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );
  
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