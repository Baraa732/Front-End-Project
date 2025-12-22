import 'package:flutter/material.dart';

class ThemeHelper {
  static const Color primaryBlue = Color(0xFF4a90e2);
  static const Color primaryPink = Color(0xFFff6f2d);
  static const Color primaryOrange = Color(0xFFff6f2d);
  static const Color primaryGreen = Color(0xFF10B981);

  static Color getTextColor(bool isDark) {
    return isDark ? Colors.white : Colors.black87;
  }

  static Color getSubtextColor(bool isDark) {
    return isDark ? Colors.white70 : Colors.black54;
  }

  static Color getCardColor(bool isDark) {
    return isDark ? Colors.white.withOpacity(0.1) : Colors.white;
  }

  static Color getBorderColor(bool isDark) {
    return isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3);
  }

  static LinearGradient getBackgroundGradient(bool isDark) {
    return isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0e1330), Color(0xFF17173a)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          );
  }
}