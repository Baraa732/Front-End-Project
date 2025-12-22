// State management actions
enum AppAction {
  toggleTheme,
  setTheme,
  setNavIndex,
  setUser,
  setConnected,
  setLoading,
  setError,
  clearError,
}

class StateAction {
  final AppAction type;
  final dynamic payload;

  const StateAction(this.type, [this.payload]);
}