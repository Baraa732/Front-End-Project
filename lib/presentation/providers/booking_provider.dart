import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking.dart';
import '../../core/network/api_service.dart';

class BookingState {
  final List<Booking> bookings;
  final List<Map<String, dynamic>> bookingRequests;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const BookingState({
    this.bookings = const [],
    this.bookingRequests = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  BookingState copyWith({
    List<Booking>? bookings,
    List<Map<String, dynamic>>? bookingRequests,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      bookingRequests: bookingRequests ?? this.bookingRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final ApiService _apiService;

  BookingNotifier(this._apiService) : super(const BookingState());

  Future<void> loadMyBookings() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _apiService.getMyBookings();
      
      if (result['success'] == true) {
        final bookingList = (result['data'] as List?)
            ?.map((json) => Booking.fromJson(json))
            .toList() ?? [];
        
        state = state.copyWith(
          bookings: bookingList,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to load bookings',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadMyBookingRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _apiService.getMyBookingRequests();
      
      if (result['success'] == true) {
        final requestList = (result['data'] as List?)
            ?.cast<Map<String, dynamic>>() ?? [];
        
        state = state.copyWith(
          bookingRequests: requestList,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to load booking requests',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<bool> createBookingRequest({
    required String apartmentId,
    required String checkIn,
    required String checkOut,
    required int guests,
    String? message,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _apiService.createBookingRequest(
        apartmentId: apartmentId,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        message: message,
      );
      
      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          successMessage: result['message'] ?? 'Booking request sent successfully',
        );
        await loadMyBookingRequests();
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to create booking request',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  Future<Map<String, dynamic>> checkAvailability({
    required String apartmentId,
    required String checkIn,
    required String checkOut,
  }) async {
    try {
      return await _apiService.checkAvailability(
        apartmentId: apartmentId,
        checkIn: checkIn,
        checkOut: checkOut,
      );
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

class LandlordBookingNotifier extends StateNotifier<BookingState> {
  final ApiService _apiService;

  LandlordBookingNotifier(this._apiService) : super(const BookingState());

  Future<void> loadBookingRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _apiService.getLandlordBookingRequests();
      
      if (result['success'] == true) {
        final requestList = (result['data'] as List?)
            ?.cast<Map<String, dynamic>>() ?? [];
        
        state = state.copyWith(
          bookingRequests: requestList,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to load booking requests',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<bool> approveBookingRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _apiService.approveBookingRequest(requestId);
      
      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          successMessage: result['message'] ?? 'Booking request approved',
        );
        await loadBookingRequests();
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to approve booking request',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> rejectBookingRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _apiService.rejectBookingRequest(requestId);
      
      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          successMessage: result['message'] ?? 'Booking request rejected',
        );
        await loadBookingRequests();
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to reject booking request',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ApiService());
});

final landlordBookingProvider = StateNotifierProvider<LandlordBookingNotifier, BookingState>((ref) {
  return LandlordBookingNotifier(ApiService());
});