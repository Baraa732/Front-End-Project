import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../../widgets/common/themed_card.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/theme/app_theme.dart';

class ThemeDemoScreen extends StatefulWidget {
  const ThemeDemoScreen({super.key});

  @override
  State<ThemeDemoScreen> createState() => _ThemeDemoScreenState();
}

class _ThemeDemoScreenState extends State<ThemeDemoScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with theme toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Theme Demo',
                      style: AppTheme.getTitle(context.isDarkMode),
                    ),
                    const ThemeToggleButton(),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Theme status card
                ThemedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            context.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: context.iconColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Current Theme: ${context.isDarkMode ? 'Dark' : 'Light'} Mode',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This card automatically adapts its colors, shadows, and borders based on the current theme.',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Color palette showcase
                ThemedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Color Palette',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildColorSwatch('Primary Blue', AppTheme.primaryBlue),
                          _buildColorSwatch('Primary Pink', AppTheme.primaryPink),
                          _buildColorSwatch('Primary Orange', AppTheme.primaryOrange),
                          _buildColorSwatch('Primary Green', AppTheme.primaryGreen),
                          _buildColorSwatch('Text Color', context.textColor),
                          _buildColorSwatch('Card Color', context.cardColor),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Input showcase
                ThemedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Input Components',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        controller: _textController,
                        label: 'Theme-aware Input',
                        icon: Icons.text_fields,
                        hintText: 'Type something here...',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Button showcase
                ThemedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Button Components',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Primary Button',
                        icon: Icons.star,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Primary button pressed!'),
                              backgroundColor: AppTheme.primaryBlue,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Secondary Button',
                        icon: Icons.favorite_border,
                        isSecondary: true,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Secondary button pressed!'),
                              backgroundColor: context.cardColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Typography showcase
                ThemedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Typography',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hero Title',
                        style: AppTheme.getHeroTitle(context.isDarkMode),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Regular Title',
                        style: AppTheme.getTitle(context.isDarkMode),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Subtitle text that adapts to the current theme',
                        style: AppTheme.getSubtitle(context.isDarkMode),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Body text that changes color based on light or dark mode',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Theme toggle instruction
                ThemedCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryBlue,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Toggle Theme',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use the theme toggle button at the top to switch between light and dark modes. All components will automatically adapt!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.borderColor,
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 10,
            color: context.subtitleColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}