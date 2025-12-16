import '../services/connection_manager.dart';

class AppConfig {
  static Future<String> get baseUrl async {
    return await ConnectionManager.getWorkingUrl();
  }
  
  static Future<String> getImageUrl(String imagePath) async {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    final url = await baseUrl;
    final cleanBaseUrl = url.replaceAll('/api', '');
    return '$cleanBaseUrl/storage/$imagePath';
  }
}