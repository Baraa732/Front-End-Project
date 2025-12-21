import 'dart:io';
import 'package:http/http.dart' as http;
import 'error_handler.dart';

class ConnectionManager {
  // Simple URLs for Android Emulator
  static const List<String> _urls = [
    'http://10.0.2.2:8000/api',       // Android Emulator (Laravel default)
    'http://127.0.0.1:8000/api',      // Localhost
    'http://localhost:8000/api',      // Alternative localhost
  ];

  static String? _workingUrl;

  static Future<String> getWorkingUrl() async {
    if (_workingUrl != null) {
      return _workingUrl!;
    }

    for (String url in _urls) {
      if (await _testUrl(url)) {
        _workingUrl = url;
        return url;
      }
    }

    _workingUrl = _urls.first;
    return _workingUrl!;
  }

  static Future<bool> _testUrl(String url) async {
    try {
      final response = await http.get(
        Uri.parse('$url/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static void resetConnection() {
    _workingUrl = null;
  }

  static String? get currentUrl => _workingUrl;
}
