import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<bool> {
  static const String _themeKey = 'isDarkMode';
  
  ThemeNotifier() : super(false) {
    _loadTheme();
  }
  
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_themeKey) ?? false;
  }
  
  void toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, state);
  }
  
  void setTheme(bool isDark) async {
    if (state != isDark) {
      state = isDark;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, state);
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});