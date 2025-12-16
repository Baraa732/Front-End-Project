import 'dart:io';
import 'package:http/http.dart' as http;
import 'error_handler.dart';

class ConnectionManager {
  static const List<String> possibleUrls = [
    'http://192.168.137.216:8000/api',    // Your Ethernet IP (primary)
    'http://192.168.137.216:8000/api', // Your USB tethering IP
    'http://192.168.43.1:8000/api',  // Mobile hotspot
    'http://172.20.10.1:8000/api',   // iPhone hotspot
    'http://10.0.2.2:8000/api',      // Android Emulator
    'http://127.0.0.1:8000/api',     // Local development
  ];

  static String? _workingUrl;
  static bool _isSearching = false;

  // Get the working URL or find one
  static Future<String> getWorkingUrl() async {
    if (_workingUrl != null) {
      return _workingUrl!;
    }

    if (_isSearching) {
      // Prevent multiple simultaneous searches
      await Future.delayed(const Duration(milliseconds: 100));
      return _workingUrl ?? possibleUrls.first;
    }

    _isSearching = true;
    try {
      for (String url in possibleUrls) {
        if (await _testUrl(url)) {
          _workingUrl = url;
          return url;
        }
      }
      // Return first URL as fallback
      _workingUrl = possibleUrls.first;
      return _workingUrl!;
    } finally {
      _isSearching = false;
    }
  }

  // Test if a URL is reachable
  static Future<bool> _testUrl(String url) async {
    try {
      final response = await http.get(
        Uri.parse('$url/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Check connection status
  static Future<bool> isConnected() async {
    try {
      await getWorkingUrl();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Reset and retry connection
  static Future<void> resetConnection() async {
    _workingUrl = null;
    await getWorkingUrl();
  }

  // Handle connection errors
  static Map<String, dynamic> handleConnectionError(dynamic error) {
    return ErrorHandler.handleApiError(
      error,
      operation: 'Backend connection'
    );
  }
}
