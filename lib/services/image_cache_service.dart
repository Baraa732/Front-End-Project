import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheExpiry = Duration(days: 7);

  Future<String> getCacheDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  String _generateCacheKey(String url) {
    return url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').substring(0, url.length > 50 ? 50 : url.length);
  }

  Future<File?> getCachedImage(String url) async {
    try {
      final cacheDir = await getCacheDirectory();
      final cacheKey = _generateCacheKey(url);
      final file = File('$cacheDir/$cacheKey');
      
      if (await file.exists()) {
        final stat = await file.stat();
        final age = DateTime.now().difference(stat.modified);
        
        if (age < cacheExpiry) {
          return file;
        } else {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error getting cached image: $e');
    }
    return null;
  }

  Future<File?> cacheImage(String url) async {
    try {
      final cacheDir = await getCacheDirectory();
      final cacheKey = _generateCacheKey(url);
      final file = File('$cacheDir/$cacheKey');
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        await _cleanupCache();
        return file;
      }
    } catch (e) {
      print('Error caching image: $e');
    }
    return null;
  }

  Future<void> _cleanupCache() async {
    try {
      final cacheDir = await getCacheDirectory();
      final dir = Directory(cacheDir);
      final files = await dir.list().toList();
      
      int totalSize = 0;
      final fileStats = <MapEntry<File, FileStat>>[];
      
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
          fileStats.add(MapEntry(entity, stat));
        }
      }
      
      if (totalSize > maxCacheSize) {
        fileStats.sort((a, b) => a.value.accessed.compareTo(b.value.accessed));
        
        for (final entry in fileStats) {
          if (totalSize <= maxCacheSize * 0.8) break;
          
          try {
            totalSize -= entry.value.size;
            await entry.key.delete();
          } catch (e) {
            print('Error deleting cache file: $e');
          }
        }
      }
    } catch (e) {
      print('Error cleaning cache: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final cacheDir = await getCacheDirectory();
      final dir = Directory(cacheDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  Future<int> getCacheSize() async {
    try {
      final cacheDir = await getCacheDirectory();
      final dir = Directory(cacheDir);
      int totalSize = 0;
      
      await for (final entity in dir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }
}