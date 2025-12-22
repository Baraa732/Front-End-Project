import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'error_handler.dart';
import '../constants/app_config.dart';

class ChatService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getChats() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/chats'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getChats', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading chats');
    }
  }

  Future<Map<String, dynamic>> getChatMessages(String chatId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/chats/$chatId/messages'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getChatMessages', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading messages');
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String message,
  }) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/chats/$chatId/messages'),
        headers: headers,
        body: json.encode({'message': message}),
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': data['message'] ?? 'Message sent',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('sendMessage', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Sending message');
    }
  }

  Future<Map<String, dynamic>> createOrGetChat({
    required String apartmentId,
    required String landlordId,
  }) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/chats'),
        headers: headers,
        body: json.encode({
          'apartment_id': apartmentId,
          'landlord_id': landlordId,
        }),
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? 'Chat created',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('createOrGetChat', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Creating chat');
    }
  }
}