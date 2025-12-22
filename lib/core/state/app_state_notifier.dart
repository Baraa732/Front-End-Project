import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_state.dart';

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void setTheme(bool isDark) {
    state = state.copyWith(isDarkMode: isDark);
  }

  void setNavIndex(int index) {
    state = state.copyWith(currentNavIndex: index);
  }

  void setUser(Map<String, dynamic>? user) {
    state = state.copyWith(currentUser: user);
  }

  void setConnected(bool connected) {
    state = state.copyWith(isConnected: connected);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});