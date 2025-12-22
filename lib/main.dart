import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/injection.dart';
import 'core/core.dart';
import 'core/state/state.dart';
import 'presentation/screens/auth/welcome_screen.dart';
import 'presentation/screens/shared/main_navigation_screen.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await configureDependencies();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final isAuthenticated = ref.watch(authProvider.select((auth) => auth.isAuthenticated));
    
    return MaterialApp(
      title: 'AUTOHIVE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: isAuthenticated ? const MainNavigationScreen() : const WelcomeScreen(),
      builder: (context, child) {
        return AnnotatedRegion(
          value: isDarkMode 
              ? const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarColor: Color(0xFF0F0F23),
                  systemNavigationBarIconBrightness: Brightness.light,
                )
              : const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarColor: Color(0xFFF8FAFC),
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
          child: child!,
        );
      },
    );
  }
}
