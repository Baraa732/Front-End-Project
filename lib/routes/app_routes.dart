import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/apartment_details_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/landlord/my_apartments_screen.dart';
import '../screens/landlord/add_apartment_screen.dart';
import '../screens/tenant/my_bookings_screen.dart';
import '../screens/tenant/create_booking_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String apartmentDetails = '/apartment-details';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String favorites = '/favorites';
  static const String myApartments = '/my-apartments';
  static const String addApartment = '/add-apartment';
  static const String myBookings = '/my-bookings';
  static const String createBooking = '/create-booking';

  static Map<String, WidgetBuilder> get routes => {
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const MainNavigationScreen(),
    profile: (context) => const ProfileScreen(),
    settings: (context) => const SettingsScreen(),
    notifications: (context) => const NotificationsScreen(),
    favorites: (context) => const FavoritesScreen(),
    myApartments: (context) => const MyApartmentsScreen(),
    addApartment: (context) => const AddApartmentScreen(),
    myBookings: (context) => const MyBookingsScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case apartmentDetails:
        final apartmentId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) =>
              ApartmentDetailsScreen(apartmentId: apartmentId),
        );
      case createBooking:
        final apartment = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => CreateBookingScreen(apartment: apartment),
        );
      default:
        return null;
    }
  }
}
