import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme_provider.dart';
import '../../../core/core.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: AppTheme.getTextColor(isDarkMode),
        ),
        onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      ),
    );
  }
}
