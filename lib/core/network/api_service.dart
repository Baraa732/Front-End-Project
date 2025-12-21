import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'image_cache_service.dart';
import 'error_handler.dart';
import '../constants/app_config.dart';

class ApiService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getApartments({String? search}) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final url = search != null ? '$apiUrl/apartments/public?search=$search' : '$apiUrl/apartments/public';
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 30));
      final data = json.decode(response.body);
      
      // Cache apartment images
      if (data['success'] == true && data['data'] != null) {
        final apartments = data['data'] is List ? data['data'] : data['data']['data'];
        if (apartments is List) {
          for (var apartment in apartments) {
            if (apartment['images'] != null) {
              for (String imageUrl in List<String>.from(apartment['images'])) {
                AppConfig.getImageUrl(imageUrl).then((fullUrl) => 
                  ImageCacheService().cacheImage(fullUrl)).catchError((e) => null);
              }
            }
          }
        }
      }
      
      return data;
    } catch (e, stackTrace) {
      ErrorHandler.logError('getApartments', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading apartments');
    }
  }

  Future<Map<String, dynamic>> getApartmentDetails(String id) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/apartments/$id/public'), headers: headers).timeout(const Duration(seconds: 30));
      final data = json.decode(response.body);

      if (data['success'] == true && data['data'] != null && data['data']['images'] != null) {
        for (String imageUrl in List<String>.from(data['data']['images'])) {
          AppConfig.getImageUrl(imageUrl).then((fullUrl) => 
            ImageCacheService().cacheImage(fullUrl)).catchError((e) => null);
        }
      }
      
      return data;
    } catch (e, stackTrace) {
      ErrorHandler.logError('getApartmentDetails', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading apartment details');
    }
  }

  Future<Map<String, dynamic>> getFavorites() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/favorites'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getFavorites', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading favorites');
    }
  }

  Future<Map<String, dynamic>> addToFavorites(String apartmentId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/favorites'),
        headers: headers,
        body: json.encode({'apartment_id': apartmentId}),
      ).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('addToFavorites', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Adding to favorites');
    }
  }

  Future<Map<String, dynamic>> removeFromFavorites(String favoriteId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.delete(
        Uri.parse('$apiUrl/favorites/$favoriteId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('removeFromFavorites', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Removing from favorites');
    }
  }

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/notifications'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getNotifications', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading notifications');
    }
  }

  Future<Map<String, dynamic>> markNotificationRead(String id) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(Uri.parse('$apiUrl/notifications/$id/read'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('markNotificationRead', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Marking notification as read');
    }
  }

  Future<Map<String, dynamic>> getMyApartments() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/my-apartments'), headers: headers).timeout(const Duration(seconds: 30));
      final data = json.decode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final apartments = data['data'] is List ? data['data'] : data['data']['data'];
        if (apartments is List) {
          for (var apartment in apartments) {
            if (apartment['images'] != null) {
              for (String imageUrl in List<String>.from(apartment['images'])) {
                AppConfig.getImageUrl(imageUrl).then((fullUrl) => 
                  ImageCacheService().cacheImage(fullUrl)).catchError((e) => null);
              }
            }
          }
        }
      }
      
      return {
        'success': response.statusCode == 200,
        'data': data['data'] ?? data,
        'message': data['message'] ?? 'My apartments retrieved successfully'
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('getMyApartments', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading my apartments');
    }
  }

  Future<Map<String, dynamic>> createApartment({
    required Map<String, dynamic> apartmentData,
    required List<File> images,
  }) async {
    try {
      final apiUrl = await AppConfig.baseUrl;
      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/apartments'));
      final headers = await _getHeaders();
      request.headers.addAll(headers);

      apartmentData.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            for (int i = 0; i < value.length; i++) {
              request.fields['${key}[$i]'] = value[i].toString();
            }
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      for (int i = 0; i < images.length; i++) {
        final file = await http.MultipartFile.fromPath(
          'images[$i]',
          images[i].path,
          filename: 'apartment_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        request.files.add(file);
      }
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = json.decode(responseBody);
      
      return {
        'success': streamedResponse.statusCode == 201,
        'message': data['message'] ?? (streamedResponse.statusCode == 201 ? 'Apartment created successfully' : 'Failed to create apartment'),
        'data': data['data'],
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('createApartment', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Creating apartment');
    }
  }

  Future<Map<String, dynamic>> updateApartment({
    required String apartmentId,
    required Map<String, dynamic> apartmentData,
    required List<File> images,
  }) async {
    try {
      final apiUrl = await AppConfig.baseUrl;
      var request = http.MultipartRequest('PUT', Uri.parse('$apiUrl/apartments/$apartmentId'));
      final headers = await _getHeaders();
      request.headers.addAll(headers);
      
      apartmentData.forEach((key, value) {
        if (value is List) {
          request.fields[key] = json.encode(value);
        } else {
          request.fields[key] = value.toString();
        }
      });
      
      for (int i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images[]',
            images[i].path,
            filename: 'apartment_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          )
        );
      }
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = json.decode(responseBody);
      
      return {
        'success': streamedResponse.statusCode == 200,
        'message': data['message'] ?? (streamedResponse.statusCode == 200 ? 'Apartment updated successfully' : 'Failed to update apartment'),
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('updateApartment', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Updating apartment');
    }
  }

  Future<Map<String, dynamic>> deleteApartment(String apartmentId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.delete(
        Uri.parse('$apiUrl/apartments/$apartmentId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? (response.statusCode == 200 ? 'Apartment deleted successfully' : 'Failed to delete apartment')
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('deleteApartment', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Deleting apartment');
    }
  }

  Future<Map<String, dynamic>> toggleApartmentAvailability(String apartmentId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/apartments/$apartmentId/toggle-availability'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Availability updated'
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('toggleApartmentAvailability', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Updating availability');
    }
  }

  Future<Map<String, dynamic>> createBookingRequest({
    required String apartmentId,
    required String checkIn,
    required String checkOut,
    required int guests,
    String? message,
  }) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/booking-requests'),
        headers: headers,
        body: json.encode({
          'apartment_id': apartmentId,
          'check_in': checkIn,
          'check_out': checkOut,
          'guests': guests,
          if (message != null) 'message': message,
        }),
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': data['message'] ?? 'Booking request sent successfully',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('createBookingRequest', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Creating booking request');
    }
  }

  Future<Map<String, dynamic>> getMyBookingRequests() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/my-booking-requests'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getMyBookingRequests', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading booking requests');
    }
  }

  Future<Map<String, dynamic>> getMyBookings() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/bookings'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getMyBookings', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading bookings');
    }
  }

  Future<Map<String, dynamic>> getLandlordBookingRequests() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/landlord/booking-requests'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getLandlordBookingRequests', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading landlord booking requests');
    }
  }

  Future<Map<String, dynamic>> approveBookingRequest(String requestId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/booking-requests/$requestId/approve'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Booking request approved',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('approveBookingRequest', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Approving booking request');
    }
  }

  Future<Map<String, dynamic>> rejectBookingRequest(String requestId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/booking-requests/$requestId/reject'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Booking request rejected',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('rejectBookingRequest', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Rejecting booking request');
    }
  }

  Future<Map<String, dynamic>> checkAvailability({
    required String apartmentId,
    required String checkIn,
    required String checkOut,
  }) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/bookings/check-availability/$apartmentId?check_in=$checkIn&check_out=$checkOut'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('checkAvailability', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Checking availability');
    }
  }
}
