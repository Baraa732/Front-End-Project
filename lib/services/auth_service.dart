import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'error_handler.dart';
import '../config/app_config.dart';

class AuthService {
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
      final url = await AppConfig.baseUrl;
      
      var request = http.MultipartRequest('POST', Uri.parse('$url/register'));
      request.headers['Accept'] = 'application/json';
      
      // Add form fields
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
      
      // Add image files
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
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await streamedResponse.stream.bytesToString();
      
      Map<String, dynamic> data;
      try {
        data = json.decode(responseBody);
      } catch (e) {
        return {
          'success': false,
          'message': 'Server connection failed. Make sure your AUTOHIVE backend is running on http://10.0.2.2:8000',
        };
      }

      if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'data': data
        };
      }
      
      // Handle specific error cases
      String errorMessage = data['message'] ?? 'Registration failed';
      
      if (streamedResponse.statusCode == 422) {
        // Validation errors
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors['phone'] != null) {
            errorMessage = errors['phone'][0] ?? errorMessage;
          }
        }
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'data': data,
        'errors': data['errors'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server. Please check your internet connection.',
      };
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
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
          'device_name': 'Android Device'
        }),
      ).timeout(const Duration(seconds: 30));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true && data['data'] != null) {
          final token = data['data']['token'];
          final user = data['data']['user'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('user', json.encode(user));

          return {
            'success': true,
            'user': user,
            'token': token,
            'message': data['message'] ?? 'Login successful'
          };
        }
      }
      
      // Handle specific error cases
      String errorMessage = data['message'] ?? 'Login failed';
      
      if (response.statusCode == 401) {
        errorMessage = 'Invalid phone number or password';
      } else if (response.statusCode == 403) {
        // Account status issues (pending, rejected, not approved)
        errorMessage = data['message'] ?? 'Account access denied';
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'errors': data['errors'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed. Make sure AUTOHIVE backend is running.'
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();
      
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return {'success': true, 'message': 'Logged out successfully'};
    } catch (e, stackTrace) {
      ErrorHandler.logError('logout', e, stackTrace);
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return ErrorHandler.handleApiError(e, operation: 'Logout');
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        return json.decode(userStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String? getProfileImageUrl(Map<String, dynamic>? user) {
    if (user == null) return null;
    return user['profile_image_url'] as String?;
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
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(data['data']['user']));
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
