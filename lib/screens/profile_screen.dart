import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/profile_avatar.dart';
import 'welcome_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'landlord/my_apartments_screen.dart';
import 'landlord/booking_requests_screen.dart';
import 'tenant/my_bookings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _user = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (route) => false);
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: themeProvider.isDarkMode ? AppTheme.getDarkGradient() : AppTheme.getLightGradient(),
          ),
          child: Stack(
            children: [
              _buildAnimatedBackground(themeProvider.isDarkMode),
              SafeArea(
                child: _buildContent(themeProvider.isDarkMode),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d)));
    }

    if (_user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFff6f2d).withOpacity(0.3), Color(0xFF4a90e2).withOpacity(0.3)],
                ),
              ),
              child: const Icon(Icons.person_off, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
              ).createShader(bounds),
              child: const Text(
                'Not Logged In',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please login to view your profile',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: 200,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFff6f2d).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'Go to Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ProfileAvatar(
            user: _user,
            size: 140,
            showBorder: true,
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
            ).createShader(bounds),
            child: Text(
              '${_user?['first_name']} ${_user?['last_name']}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _user?['phone'] ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          if (_user?['email'] != null) ...[
            const SizedBox(height: 8),
            Text(
              _user?['email'] ?? '',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFff6f2d).withOpacity(0.2),
                  const Color(0xFF4a90e2).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _user?['role'] == 'landlord' ? Icons.home_work : Icons.person,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _user?['role']?.toUpperCase() ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_user?['role'] == 'landlord')
            _buildMenuItem(Icons.home_work, 'My Apartments', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyApartmentsScreen()));
            }),
          if (_user?['role'] == 'landlord')
            _buildMenuItem(Icons.book_online, 'Booking Requests', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingRequestsScreen()));
            }),
          if (_user?['role'] == 'tenant')
            _buildMenuItem(Icons.book, 'My Bookings', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
            }),
          if (_user?['role'] == 'tenant')
            _buildMenuItem(Icons.favorite, 'My Favorites', () {
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
            }),
          _buildMenuItem(Icons.person, 'Edit Profile', () async {
            if (_user != null) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!)),
              );
              if (result == true) {
                _loadUser(); // Reload user data if profile was updated
              }
            }
          }),
          _buildMenuItem(Icons.lock, 'Change Password', () {
            // TODO: Implement change password screen
          }),
          _buildThemeToggle(),
          _buildMenuItem(Icons.settings, 'Settings', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
          _buildMenuItem(Icons.help, 'Help & Support', () {}),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(themeProvider.isDarkMode),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.getBorderColor(themeProvider.isDarkMode)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Theme Mode',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.getTextColor(themeProvider.isDarkMode),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                activeColor: const Color(0xFFff6f2d),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(themeProvider.isDarkMode),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.getBorderColor(themeProvider.isDarkMode)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.getTextColor(themeProvider.isDarkMode),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.getSubtextColor(themeProvider.isDarkMode),
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return Stack(
      children: [
        Positioned(
          right: -50,
          top: 100,
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
        Positioned(
          left: -30,
          bottom: 200,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4a90e2).withOpacity(isDark ? 0.4 : 0.08),
                  const Color(0xFFff6f2d).withOpacity(isDark ? 0.3 : 0.06),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
