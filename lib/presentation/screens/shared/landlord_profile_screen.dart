import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/state/state.dart';

class LandlordProfileScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> landlord;
  
  const LandlordProfileScreen({super.key, required this.landlord});

  @override
  ConsumerState<LandlordProfileScreen> createState() => _LandlordProfileScreenState();
}

class _LandlordProfileScreenState extends ConsumerState<LandlordProfileScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_backgroundController);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(isDarkMode),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(isDarkMode),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildProfileCard(isDarkMode),
                          const SizedBox(height: 20),
                          _buildInfoCards(isDarkMode),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'Landlord Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.getBorderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: widget.landlord['profile_image_url'] != null
                ? NetworkImage(widget.landlord['profile_image_url'])
                : null,
            child: widget.landlord['profile_image_url'] == null
                ? Text(
                    widget.landlord['first_name']?[0]?.toUpperCase() ?? 'L',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
            backgroundColor: const Color(0xFFff6f2d),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.landlord['first_name'] ?? ''} ${widget.landlord['last_name'] ?? ''}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Landlord',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(bool isDark) {
    return Column(
      children: [
        if (widget.landlord['city'] != null || widget.landlord['governorate'] != null)
          _buildInfoCard(
            isDark,
            Icons.location_on,
            'Location',
            '${widget.landlord['city'] ?? ''}, ${widget.landlord['governorate'] ?? ''}',
          ),
        const SizedBox(height: 16),
        if (widget.landlord['phone'] != null)
          _buildInfoCard(
            isDark,
            Icons.phone,
            'Phone',
            widget.landlord['phone'],
          ),
      ],
    );
  }

  Widget _buildInfoCard(bool isDark, IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFff6f2d).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFff6f2d)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getSubtextColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
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
                        const Color(0xFFff6f2d).withOpacity(isDark ? 0.3 : 0.1),
                        const Color(0xFF4a90e2).withOpacity(isDark ? 0.2 : 0.05),
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
                        const Color(0xFF4a90e2).withOpacity(isDark ? 0.4 : 0.1),
                        const Color(0xFFff6f2d).withOpacity(isDark ? 0.3 : 0.08),
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

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }
}
