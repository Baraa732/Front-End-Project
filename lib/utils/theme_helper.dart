import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ThemeHelper {
  static BoxDecoration getBackgroundDecoration(bool isDark) {
    return BoxDecoration(
      gradient: isDark ? AppTheme.getDarkGradient() : AppTheme.getLightGradient(),
    );
  }
  
  static BoxDecoration getCardDecoration(bool isDark) {
    return BoxDecoration(
      color: AppTheme.getCardColor(isDark),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.getBorderColor(isDark)),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}