import '../network/connection_manager.dart';

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
  
  static String getImageUrlSync(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    final baseUrl = ConnectionManager.currentUrl?.replaceAll('/api', '') ?? 'http://10.0.2.2:8000';
    return '$baseUrl/storage/$imagePath';
  }
}
