import 'package:flutter/material.dart';
import '../widgets/animated_bottom_nav.dart';
import '../services/auth_service.dart';
import 'modern_home_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'landlord/my_apartments_screen.dart';
import 'tenant/my_bookings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController();
  
  int _currentIndex = 0;
  Map<String, dynamic>? _user;
  List<BottomNavItem> _navItems = [];
  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getUser();
    if (mounted) {
      setState(() {
        _user = user;
        _setupNavigation();
      });
    }
  }

  void _setupNavigation() {
    if (_user == null) {
      // Guest user navigation
      _navItems = [
        const BottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        const BottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
      ];
      _screens = [
        const ModernHomeScreen(),
        const ProfileScreen(),
      ];
    } else if (_user!['role'] == 'landlord') {
      // Landlord navigation
      _navItems = [
        const BottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        const BottomNavItem(
          icon: Icons.apartment_outlined,
          activeIcon: Icons.apartment,
          label: 'Properties',
        ),
        const BottomNavItem(
          icon: Icons.notifications_outlined,
          activeIcon: Icons.notifications,
          label: 'Requests',
        ),
        const BottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
      ];
      _screens = [
        const ModernHomeScreen(),
        const MyApartmentsScreen(),
        const NotificationsPlaceholder(title: 'Booking Requests'),
        const ProfileScreen(),
      ];
    } else {
      // Tenant navigation
      _navItems = [
        const BottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        const BottomNavItem(
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          label: 'Favorites',
        ),
        const BottomNavItem(
          icon: Icons.book_outlined,
          activeIcon: Icons.book,
          label: 'Bookings',
        ),
        const BottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
      ];
      _screens = [
        const ModernHomeScreen(),
        const FavoritesScreen(),
        const MyBookingsScreen(),
        const ProfileScreen(),
      ];
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_navItems.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d))),
      );
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: _navItems,
      ),
    );
  }
}

// Placeholder widget for screens not yet implemented
class NotificationsPlaceholder extends StatelessWidget {
  final String title;
  
  const NotificationsPlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0e1330), Color(0xFF17173a)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.notifications_outlined,
                size: 80,
                color: Color(0xFFff6f2d),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}