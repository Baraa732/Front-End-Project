import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';

// Navigation provider
final navIndexProvider = StateProvider<int>((ref) => 0);

// User provider
final currentUserProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Connection provider
final isConnectedProvider = StateProvider<bool>((ref) => true);

// Loading states
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Error provider
final errorProvider = StateProvider<String?>((ref) => null);