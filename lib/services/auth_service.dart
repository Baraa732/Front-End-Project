import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'error_handler.dart';
import '../config/app_config.dart';

class AuthService {
  final storage = const FlutterSecureStorage();
  
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      final url = await AppConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$url/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }



  Future<Map<String, dynamic>> register(
    String firstName,
    String lastName,
    String phone,
    String password,
    String role,
    String city,
    String governorate, {
    DateTime? birthDate,
    File? profileImage,
    File? idImage,
  }) async {
    try {
      if (!await _hasInternetConnection()) {
        return {
          'success': false,
          'message': 'No internet connection. Please check your network and try again.'
        };
      }
      final url = await AppConfig.baseUrl;
      var request = http.MultipartRequest('POST', Uri.parse('$url/register'));
      
      request.headers['Accept'] = 'application/json';
      
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['phone'] = phone;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = password;
      request.fields['role'] = role;
      request.fields['city'] = city;
      request.fields['governorate'] = governorate;
      if (birthDate != null) {
        request.fields['birth_date'] = '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
      }
      
      print('📦 Request fields: ${request.fields}');
      
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            profileImage.path,
          ),
        );
      }
      
      if (idImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'id_image',
            idImage.path,
          ),
        );
      }
      
      print('🚀 Sending registration request...');
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await streamedResponse.stream.bytesToString();
      
      print('📊 Response status: ${streamedResponse.statusCode}');
      print('📝 Response body: $responseBody');
      
      final data = json.decode(responseBody);

      if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
        if (data['success'] == true && data['data'] != null) {
          final token = data['data']['token'];
          final user = data['data']['user'];

          await storage.write(key: 'token', value: token);
          await storage.write(key: 'user', value: json.encode(user));

          return {
            'success': true,
            'user': user,
            'token': token,
            'message': data['message'] ?? 'Registration successful'
          };
        }
      }
      
      String errorMessage = data['message'] ?? 'Registration failed';
      if (errorMessage.contains('SQLSTATE') || errorMessage.contains('Connection refused') || errorMessage.contains('database')) {
        errorMessage = 'Database connection failed. Please check server connection and try again later.';
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'data': data,
        'status_code': streamedResponse.statusCode,
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('register', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Registration');
    }
  }



  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      if (!await _hasInternetConnection()) {
        return {
          'success': false,
          'message': 'No internet connection. Please check your network and try again.'
        };
      }
      final url = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$url/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'phone': phone,
          'password': password,
          'device_name': '${Platform.operatingSystem} Device'
        }),
      ).timeout(const Duration(seconds: 30));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true && data['data'] != null) {
          final token = data['data']['token'];
          final user = data['data']['user'];

          await storage.write(key: 'token', value: token);
          await storage.write(key: 'user', value: json.encode(user));

          return {
            'success': true,
            'user': user,
            'token': token,
            'message': data['message'] ?? 'Login successful'
          };
        }
      }
      
      String errorMessage = data['message'] ?? 'Invalid credentials';
      if (errorMessage.contains('SQLSTATE') || errorMessage.contains('Connection refused') || errorMessage.contains('database')) {
        errorMessage = 'Database connection failed. Please check server connection and try again later.';
      }
      
      return {
        'success': false,
        'message': errorMessage
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('login', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Login');
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await storage.read(key: 'token');
      
      if (token != null) {
        try {
          final url = await AppConfig.baseUrl;
          await http.post(
            Uri.parse('$url/logout'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json'
            },
          ).timeout(const Duration(seconds: 5));
        } catch (e) {
          // Ignore server logout errors
        }
      }

      await storage.deleteAll();
      return {'success': true, 'message': 'Logged out successfully'};
    } catch (e, stackTrace) {
      ErrorHandler.logError('logout', e, stackTrace);
      await storage.deleteAll();
      return ErrorHandler.handleApiError(e, operation: 'Logout');
    }
  }

  Future<String?> getToken() async {
    try {
      return await storage.read(key: 'token');
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final userStr = await storage.read(key: 'user');
      if (userStr != null) {
        return json.decode(userStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }



  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    File? profileImage,
  }) async {
    try {
      final url = await AppConfig.baseUrl;
      var request = http.MultipartRequest('PUT', Uri.parse('$url/profile'));
      
      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['phone'] = phone;
      
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            profileImage.path,
          )
        );
      }
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = json.decode(responseBody);
      
      if (streamedResponse.statusCode == 200) {
        if (data['data'] != null && data['data']['user'] != null) {
          await storage.write(key: 'user', value: json.encode(data['data']['user']));
        }
        
        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated successfully',
          'data': data['data']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile'
        };
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('updateProfile', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Profile update');
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final url = await AppConfig.baseUrl;
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$url/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to change password'
        };
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('changePassword', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Password change');
    }
  }


}
