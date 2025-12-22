import 'package:flutter/material.dart';

class AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<AnimatedBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationController.forward(from: 0);
    }
  }

  void _onItemTap(int index) {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF17173a), Color(0xFF0e1330)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated indicator
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Positioned(
                top: 0,
                left: (MediaQuery.of(context).size.width / widget.items.length) * widget.currentIndex,
                child: Container(
                  width: MediaQuery.of(context).size.width / widget.items.length,
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFff6f2d), Color(0xFFff9b57)],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
                  ),
                ),
              );
            },
          ),
          // Navigation items
          Row(
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == widget.currentIndex;
              
              return Expanded(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isActive ? _scaleAnimation.value : 1.0,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onItemTap(index),
                          borderRadius: BorderRadius.circular(12),
                          splashColor: const Color(0xFFff6f2d).withOpacity(0.2),
                          highlightColor: const Color(0xFFff6f2d).withOpacity(0.1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isActive 
                                      ? const Color(0xFFff6f2d).withOpacity(0.2)
                                      : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          isActive ? item.activeIcon : item.icon,
                                          key: ValueKey(isActive),
                                          color: isActive 
                                            ? const Color(0xFFff6f2d)
                                            : Colors.white.withOpacity(0.6),
                                          size: 24,
                                        ),
                                      ),
                                      if (item.badge != null)
                                        Positioned(
                                          right: -6,
                                          top: -6,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFff6f2d),
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 16,
                                              minHeight: 16,
                                            ),
                                            child: Text(
                                              item.badge!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: isActive ? 12 : 11,
                                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                    color: isActive 
                                      ? const Color(0xFFff6f2d)
                                      : Colors.white.withOpacity(0.6),
                                  ),
                                  child: Text(item.label),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? badge;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}
