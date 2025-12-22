import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/apartment.dart';
import '../../core/network/api_service.dart';

class ApartmentState {
  final List<Apartment> apartments;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final String? searchQuery;

  const ApartmentState({
    this.apartments = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.searchQuery,
  });

  ApartmentState copyWith({
    List<Apartment>? apartments,
    bool? isLoading,
    String? error,
    bool? hasMore,
    String? searchQuery,
  }) {
    return ApartmentState(
      apartments: apartments ?? this.apartments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ApartmentNotifier extends StateNotifier<ApartmentState> {
  final ApiService _apiService;

  ApartmentNotifier(this._apiService) : super(const ApartmentState());

  Future<void> loadApartments({String? search, bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(apartments: [], hasMore: true);
    }
    
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null, searchQuery: search);
    
    try {
      final result = await _apiService.getApartments(search: search);
      
      if (result['success'] == true) {
        final apartmentList = (result['data'] as List?)
            ?.map((json) => Apartment.fromJson(json))
            .toList() ?? [];
        
        state = state.copyWith(
          apartments: refresh ? apartmentList : [...state.apartments, ...apartmentList],
          isLoading: false,
          hasMore: apartmentList.isNotEmpty,
        );
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to load apartments',
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

  Future<void> searchApartments(String query) async {
    await loadApartments(search: query, refresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final apartmentProvider = StateNotifierProvider<ApartmentNotifier, ApartmentState>((ref) {
  return ApartmentNotifier(ApiService());
});

final apartmentDetailsProvider = FutureProvider.family<Apartment?, String>((ref, apartmentId) async {
  final apiService = ApiService();
  final result = await apiService.getApartmentDetails(apartmentId);
  
  if (result['success'] == true && result['data'] != null) {
    return Apartment.fromJson(result['data']);
  }
  return null;
});