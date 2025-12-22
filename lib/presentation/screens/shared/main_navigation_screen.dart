import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/animated_bottom_nav.dart';
import '../../../core/core.dart';
import '../../../core/state/state.dart';
import '../tenant/tenant_home_screen.dart';
import '../landlord/landlord_home_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import '../landlord/my_apartments_screen.dart';
import '../tenant/my_bookings_screen.dart';
import 'notifications_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with RealTimeRefreshMixin {
  final PageController _pageController = PageController();

  List<BottomNavItem> _navItems = [];
  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    startRealTimeRefresh();
  }

  @override
  void refreshData() {
    // Refresh data logic here
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _setupNavigation() {
    final user = ref.watch(currentUserProvider);
    final currentIndex = ref.watch(navIndexProvider);

    if (user != null && user['role'] == 'landlord') {
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
        const LandlordHomeScreen(),
        const MyApartmentsScreen(),
        const NotificationsScreen(),
        const ProfileScreen(),
      ];
    } else {
      // Tenant navigation (default for both tenant and guest)
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
        const TenantHomeScreen(),
        const FavoritesScreen(),
        const MyBookingsScreen(),
        const ProfileScreen(),
      ];
    }

    // Ensure current index is within bounds
    if (currentIndex >= _screens.length) {
      ref.read(navIndexProvider.notifier).state = 0;
    }
  }

  void _onNavTap(int index) {
    ref.read(navIndexProvider.notifier).state = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    ref.read(navIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    // Watch for user changes to rebuild navigation
    ref.watch(currentUserProvider);
    final currentIndex = ref.watch(navIndexProvider);
    final isConnected = ref.watch(isConnectedProvider);

    _setupNavigation();

    if (_navItems.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFff6f2d)),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _screens,
          ),
          // Network status indicator
          if (!isConnected)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.red,
                child: const Text(
                  'No internet connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: ref.watch(themeProvider) ? const Color(0xFF17173a) : Colors.white,
        selectedItemColor: const Color(0xFFff6f2d),
        unselectedItemColor: ref.watch(themeProvider) ? Colors.white54 : Colors.grey,
        items: _navItems.map((item) => BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: item.badge != null,
            label: item.badge != null ? Text(item.badge!) : null,
            child: Icon(item.icon),
          ),
          activeIcon: Badge(
            isLabelVisible: item.badge != null,
            label: item.badge != null ? Text(item.badge!) : null,
            child: Icon(item.activeIcon),
          ),
          label: item.label,
        )).toList(),
      ),
    );
  }
}
