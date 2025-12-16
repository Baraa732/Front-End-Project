import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBackground extends StatefulWidget {
  final Widget child;
  final bool showFloatingElements;
  
  const AppBackground({
    super.key,
    required this.child,
    this.showFloatingElements = true,
  });

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.showFloatingElements) {
      _rotationController = AnimationController(
        duration: const Duration(seconds: 20),
        vsync: this,
      )..repeat();
      _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_rotationController);
    }
  }

  @override
  void dispose() {
    if (widget.showFloatingElements) {
      _rotationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Stack(
        children: [
          if (widget.showFloatingElements) _buildFloatingElements(),
          widget.child,
        ],
      ),
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              right: -50,
              top: 100,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.3),
                        AppTheme.primaryPink.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -20,
              top: 300,
              child: Transform.rotate(
                angle: -_rotationAnimation.value * 1.5 * 3.14159,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryOrange.withOpacity(0.4),
                        AppTheme.primaryGreen.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: 200,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 0.8 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryPink.withOpacity(0.5),
                        AppTheme.primaryBlue.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}