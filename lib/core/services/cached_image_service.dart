import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CachedImageService {
  static final Map<String, String> _urlCache = {};
  static final Map<String, bool> _failedUrls = {};
  
  /// Get a cached URL or find a working URL for Google Drive images
  static Future<String?> getWorkingUrl(String originalUrl) async {
    if (originalUrl.isEmpty) return null;
    
    debugPrint('🔍 CachedImageService: Processing URL: $originalUrl');
    
    // Check if we already have a working URL cached
    if (_urlCache.containsKey(originalUrl)) {
      debugPrint('📋 Using cached URL for: $originalUrl -> ${_urlCache[originalUrl]}');
      return _urlCache[originalUrl];
    }
    
    // Check if this URL has previously failed
    if (_failedUrls.containsKey(originalUrl) && _failedUrls[originalUrl] == true) {
      debugPrint('❌ URL previously failed: $originalUrl');
      return null;
    }
    
    // For Google Drive URLs, try to find a working URL
    if (originalUrl.contains('drive.google.com')) {
      debugPrint('🌐 Processing Google Drive URL: $originalUrl');
      try {
        final workingUrl = await _findWorkingGoogleDriveUrl(originalUrl);
        if (workingUrl != null) {
          _urlCache[originalUrl] = workingUrl;
          debugPrint('✅ Cached working URL: $originalUrl -> $workingUrl');
          return workingUrl;
        } else {
          _failedUrls[originalUrl] = true;
          debugPrint('❌ No working URL found for: $originalUrl');
          return null;
        }
      } catch (e) {
        debugPrint('❌ Error finding working Google Drive URL: $e');
        _failedUrls[originalUrl] = true;
        return null;
      }
    }
    
    // For non-Google Drive URLs, just return the original
    debugPrint('📋 Using original URL (non-Google Drive): $originalUrl');
    return originalUrl;
  }
  
  /// Try to get a working URL with different authentication approaches
  static Future<String?> getWorkingUrlWithAuth(String originalUrl) async {
    if (originalUrl.isEmpty) return null;
    
    debugPrint('🔍 CachedImageService: Processing URL with auth: $originalUrl');
    
    // Check if we already have a working URL cached
    if (_urlCache.containsKey(originalUrl)) {
      debugPrint('📋 Using cached URL for: $originalUrl -> ${_urlCache[originalUrl]}');
      return _urlCache[originalUrl];
    }
    
    // Check if this URL has previously failed
    if (_failedUrls.containsKey(originalUrl) && _failedUrls[originalUrl] == true) {
      debugPrint('❌ URL previously failed: $originalUrl');
      return null;
    }
    
    // For Google Drive URLs, try multiple approaches
    if (originalUrl.contains('drive.google.com')) {
      debugPrint('🌐 Processing Google Drive URL with auth: $originalUrl');
      try {
        // Try to get authenticated URL from backend
        final fileId = _extractFileId(originalUrl);
        if (fileId != null) {
          final authenticatedUrl = await _getAuthenticatedUrl(fileId);
          if (authenticatedUrl != null) {
            _urlCache[originalUrl] = authenticatedUrl;
            debugPrint('✅ Cached authenticated URL: $originalUrl -> $authenticatedUrl');
            return authenticatedUrl;
          }
        }
        
        // Fallback to finding working URL without auth
        final workingUrl = await _findWorkingGoogleDriveUrl(originalUrl);
        if (workingUrl != null) {
          _urlCache[originalUrl] = workingUrl;
          debugPrint('✅ Cached working URL: $originalUrl -> $workingUrl');
          return workingUrl;
        } else {
          _failedUrls[originalUrl] = true;
          debugPrint('❌ No working URL found for: $originalUrl');
          return null;
        }
      } catch (e) {
        debugPrint('❌ Error finding working Google Drive URL: $e');
        _failedUrls[originalUrl] = true;
        return null;
      }
    }
    
    // For non-Google Drive URLs, just return the original
    debugPrint('📋 Using original URL (non-Google Drive): $originalUrl');
    return originalUrl;
  }
  
  /// Find a working Google Drive URL by trying multiple formats
  static Future<String?> _findWorkingGoogleDriveUrl(String originalUrl) async {
    final fileId = _extractFileId(originalUrl);
    if (fileId == null) {
      debugPrint('⚠️ Could not extract file ID from URL: $originalUrl');
      return null;
    }
    
    debugPrint('🔍 Extracted file ID: $fileId');
    
    final possibleUrls = [
      // Try direct download with different parameters
      'https://drive.google.com/uc?export=download&id=$fileId',
      'https://drive.google.com/uc?export=view&id=$fileId',
      'https://drive.google.com/uc?id=$fileId&export=download',
      'https://drive.google.com/uc?id=$fileId&export=view',
      // Try thumbnail URLs
      'https://drive.google.com/thumbnail?id=$fileId&sz=w400',
      'https://drive.google.com/thumbnail?id=$fileId&sz=w800',
      'https://drive.google.com/thumbnail?id=$fileId&sz=w1200',
      // Try file view URLs
      'https://drive.google.com/file/d/$fileId/view',
      'https://drive.google.com/file/d/$fileId/preview',
    ];
    
    debugPrint('🔄 Testing ${possibleUrls.length} possible URLs for file ID: $fileId');
    
    for (int i = 0; i < possibleUrls.length; i++) {
      final url = possibleUrls[i];
      debugPrint('🧪 Testing URL ${i + 1}/${possibleUrls.length}: $url');
      
      if (await _testImageUrl(url)) {
        debugPrint('✅ Found working URL: $url');
        return url;
      } else {
        debugPrint('❌ URL failed: $url');
      }
    }
    
    debugPrint('❌ No working URL found for file ID: $fileId');
    return null;
  }
  
  /// Try to get authenticated URL from backend
  static Future<String?> _getAuthenticatedUrl(String fileId) async {
    try {
      debugPrint('🔐 Trying to get authenticated URL for file ID: $fileId');
      
      // This would call your backend API to get an authenticated URL
      // For now, we'll return null to fall back to other methods
      return null;
    } catch (e) {
      debugPrint('❌ Error getting authenticated URL: $e');
      return null;
    }
  }
  
  /// Extract file ID from Google Drive URL
  static String? _extractFileId(String url) {
    try {
      if (url.contains('/file/d/')) {
        return url.split('/file/d/')[1].split('/')[0];
      } else if (url.contains('id=')) {
        return url.split('id=')[1].split('&')[0];
      }
    } catch (e) {
      debugPrint('❌ Error extracting file ID from URL: $url - $e');
    }
    return null;
  }
  
  /// Test if a URL returns valid image data with better authentication handling
  static Future<bool> _testImageUrl(String url) async {
    try {
      debugPrint('🔍 Testing URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate, br',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
          'Referer': 'https://drive.google.com/',
          'Sec-Fetch-Dest': 'image',
          'Sec-Fetch-Mode': 'no-cors',
          'Sec-Fetch-Site': 'cross-site',
          'Sec-Ch-Ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
          'Sec-Ch-Ua-Mobile': '?0',
          'Sec-Ch-Ua-Platform': '"Windows"',
          'DNT': '1',
        },
      );
      
      debugPrint('📊 Response status: ${response.statusCode}');
      debugPrint('📊 Content-Type: ${response.headers['content-type']}');
      debugPrint('📊 Content-Length: ${response.headers['content-length']}');
      
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        final contentLength = int.tryParse(response.headers['content-length'] ?? '0') ?? 0;
        
        // For Google Drive URLs, check if we got actual image data
        if (url.contains('drive.google.com')) {
          // Google Drive often returns small HTML redirects instead of images
          // We need to check if the response is actually an image
          final bytes = response.bodyBytes;
          final isValidImage = contentType.startsWith('image/') && 
                             contentLength > 1000 && // Must be larger than a small HTML redirect
                             bytes.length > 1000;    // Double-check the actual bytes
          
          debugPrint('✅ URL test result: $isValidImage (Content-Type: $contentType, Size: $contentLength bytes, Actual bytes: ${bytes.length})');
          return isValidImage;
        } else {
          // For non-Google Drive URLs, be more lenient
          final isValidImage = contentType.startsWith('image/') && 
                             (contentLength > 100 || !url.contains('drive.google.com'));
          
          debugPrint('✅ URL test result: $isValidImage (Content-Type: $contentType, Size: $contentLength bytes)');
          return isValidImage;
        }
      } else {
        debugPrint('❌ URL test failed: HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error testing URL $url: $e');
      return false;
    }
  }
  
  /// Clear the URL cache
  static void clearCache() {
    _urlCache.clear();
    _failedUrls.clear();
    debugPrint('🗑️ Cleared image URL cache');
  }
  
  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cachedUrls': _urlCache.length,
      'failedUrls': _failedUrls.length,
      'totalUrls': _urlCache.length + _failedUrls.length,
    };
  }
  
  /// Print cache statistics
  static void printCacheStats() {
    final stats = getCacheStats();
    debugPrint('📊 Cache Statistics:');
    debugPrint('  - Cached URLs: ${stats['cachedUrls']}');
    debugPrint('  - Failed URLs: ${stats['failedUrls']}');
    debugPrint('  - Total URLs: ${stats['totalUrls']}');
  }

  /// Get a user-friendly message for Google Drive access issues
  static String getGoogleDriveErrorMessage(String fileId) {
    return 'Google Drive file is not publicly accessible. Please make the file public or contact support.';
  }
  
  /// Check if a Google Drive file is likely to be accessible
  static bool isGoogleDriveFileAccessible(String url) {
    // This is a simple heuristic - in a real app, you'd check file permissions
    return url.contains('drive.google.com') && 
           (url.contains('export=download') || url.contains('export=view'));
  }
} 