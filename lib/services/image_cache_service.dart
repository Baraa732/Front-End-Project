import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  final Map<String, Uint8List> _cache = {};

  Future<void> cacheImage(String url) async {
    if (_cache.containsKey(url)) return;
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _cache[url] = response.bodyBytes;
      }
    } catch (e) {
      // Ignore cache errors
    }
  }

  Uint8List? getCachedImage(String url) {
    return _cache[url];
  }

  void clearCache() {
    _cache.clear();
  }
}