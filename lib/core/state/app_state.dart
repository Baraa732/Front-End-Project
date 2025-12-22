class AppState {
  final bool isDarkMode;
  final int currentNavIndex;
  final Map<String, dynamic>? currentUser;
  final bool isConnected;
  final bool isLoading;
  final String? error;

  const AppState({
    this.isDarkMode = false,
    this.currentNavIndex = 0,
    this.currentUser,
    this.isConnected = true,
    this.isLoading = false,
    this.error,
  });

  AppState copyWith({
    bool? isDarkMode,
    int? currentNavIndex,
    Map<String, dynamic>? currentUser,
    bool? isConnected,
    bool? isLoading,
    String? error,
  }) {
    return AppState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentNavIndex: currentNavIndex ?? this.currentNavIndex,
      currentUser: currentUser ?? this.currentUser,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}