import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GoogleDriveService {
  static const String _userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  /// Extract file ID from various Google Drive URL formats
  static String? extractFileId(String url) {
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

  /// Generate multiple URL formats for a Google Drive file
  static List<String> generatePossibleUrls(String fileId) {
    return [
      // Direct download URLs
      'https://drive.google.com/uc?export=download&id=$fileId',
      'https://drive.google.com/uc?export=view&id=$fileId',
      'https://drive.google.com/uc?id=$fileId&export=download',
      'https://drive.google.com/uc?id=$fileId&export=view',
      
      // Thumbnail URLs (these often work for public files)
      'https://drive.google.com/thumbnail?id=$fileId&sz=w400',
      'https://drive.google.com/thumbnail?id=$fileId&sz=w800',
      'https://drive.google.com/thumbnail?id=$fileId&sz=w1200',
      
      // View URLs
      'https://drive.google.com/file/d/$fileId/view',
      'https://drive.google.com/file/d/$fileId/preview',
      
      // Alternative formats
      'https://docs.google.com/uc?id=$fileId&export=download',
      'https://docs.google.com/uc?id=$fileId&export=view',
    ];
  }

  /// Test if a URL is accessible and returns valid image data
  static Future<bool> testImageUrl(String url) async {
    try {
      debugPrint('🔍 Testing Google Drive URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': _userAgent,
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
        final bytes = response.bodyBytes;
        
        // Check if we got actual image data
        final isValidImage = contentType.startsWith('image/') && 
                           contentLength > 1000 && 
                           bytes.length > 1000;
        
        debugPrint('✅ URL test result: $isValidImage (Content-Type: $contentType, Size: $contentLength bytes, Actual bytes: ${bytes.length})');
        return isValidImage;
      } else {
        debugPrint('❌ URL test failed: HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error testing URL $url: $e');
      return false;
    }
  }

  /// Get the best working URL for a Google Drive image
  static Future<String?> getBestWorkingUrl(String originalUrl) async {
    try {
      debugPrint('🔍 Finding best working URL for: $originalUrl');
      
      final fileId = extractFileId(originalUrl);
      if (fileId == null) {
        debugPrint('❌ Could not extract file ID from URL: $originalUrl');
        return null;
      }
      
      final possibleUrls = generatePossibleUrls(fileId);
      debugPrint('🔄 Testing ${possibleUrls.length} possible URLs for file ID: $fileId');
      
      for (int i = 0; i < possibleUrls.length; i++) {
        final url = possibleUrls[i];
        debugPrint('🧪 Testing URL ${i + 1}/${possibleUrls.length}: $url');
        
        if (await testImageUrl(url)) {
          debugPrint('✅ Found working URL: $url');
          return url;
        } else {
          debugPrint('❌ URL failed: $url');
        }
      }
      
      debugPrint('❌ No working URL found for file ID: $fileId');
      return null;
    } catch (e) {
      debugPrint('❌ Error finding working URL: $e');
      return null;
    }
  }

  /// Convert Google Drive URL to a more reliable format
  static String convertToReliableUrl(String url) {
    final fileId = extractFileId(url);
    if (fileId != null) {
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return url;
  }

  /// Get headers for Google Drive requests
  static Map<String, String> getHeaders() {
    return {
      'User-Agent': _userAgent,
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
    };
  }
} 