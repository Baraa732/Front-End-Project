import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_state.dart';
import 'providers.dart';
import '../../presentation/theme_provider.dart';

extension StateExtensions on WidgetRef {
  bool get isDarkMode => watch(themeProvider);
  int get navIndex => watch(navIndexProvider);
  Map<String, dynamic>? get currentUser => watch(currentUserProvider);
  bool get isConnected => watch(isConnectedProvider);
  bool get isLoading => watch(isLoadingProvider);
  String? get error => watch(errorProvider);
}
