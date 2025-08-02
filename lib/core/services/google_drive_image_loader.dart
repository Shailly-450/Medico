import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'api_service.dart';

class GoogleDriveImageLoader {
  static const String _userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';
  
  /// Get authenticated URL from backend API
  static Future<String?> getAuthenticatedUrl(String fileId) async {
    try {
      debugPrint('🔐 Getting authenticated URL for file ID: $fileId');
      
      final result = await ApiService.getAuthenticatedDriveUrl(fileId);
      
      if (result['success'] == true) {
        debugPrint('✅ Got authenticated URL: ${result['url']}');
        return result['url'];
      } else {
        debugPrint('❌ Failed to get authenticated URL: ${result['message']}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error getting authenticated URL: $e');
      return null;
    }
  }
  
  /// Load image bytes from Google Drive URL with proper handling of redirects
  static Future<Uint8List?> loadImageBytes(String url) async {
    try {
      debugPrint('🔄 Loading image bytes from: $url');
      
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      
      // Set headers to mimic a browser with authentication
      request.headers.addAll({
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
        // Add authorization if available
        'Authorization': 'Bearer ${await ApiService.getAuthToken()}',
      });
      
      final streamedResponse = await client.send(request);
      debugPrint('📊 Response status: ${streamedResponse.statusCode}');
      debugPrint('📊 Content-Type: ${streamedResponse.headers['content-type']}');
      debugPrint('📊 Content-Length: ${streamedResponse.headers['content-length']}');
      
      if (streamedResponse.statusCode == 200) {
        final bytes = await streamedResponse.stream.toBytes();
        final contentType = streamedResponse.headers['content-type'] ?? '';
        
        debugPrint('📊 Received ${bytes.length} bytes');
        
        // Check if we got actual image data
        if (contentType.startsWith('image/') && bytes.length > 1000) {
          debugPrint('✅ Successfully loaded image bytes');
          return bytes;
        } else {
          debugPrint('❌ Invalid image data: Content-Type=$contentType, Size=${bytes.length} bytes');
          return null;
        }
      } else {
        debugPrint('❌ HTTP error: ${streamedResponse.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error loading image bytes: $e');
      return null;
    }
  }
  
  /// Try to load image with authentication
  static Future<Uint8List?> loadImageWithAuth(String originalUrl) async {
    try {
      // Extract file ID from URL
      final fileId = _extractFileId(originalUrl);
      if (fileId == null) {
        debugPrint('❌ Could not extract file ID from URL: $originalUrl');
        return null;
      }
      
      // Try to get authenticated URL from backend
      final authenticatedUrl = await getAuthenticatedUrl(fileId);
      if (authenticatedUrl != null) {
        debugPrint('🔐 Using authenticated URL: $authenticatedUrl');
        return await loadImageBytes(authenticatedUrl);
      }
      
      // Fallback to original URL
      debugPrint('⚠️ No authenticated URL available, trying original URL');
      return await loadImageBytes(originalUrl);
    } catch (e) {
      debugPrint('❌ Error loading image with auth: $e');
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
  
  /// Create a memory image from bytes
  static Image? createImageFromBytes(Uint8List? bytes) {
    if (bytes == null) return null;
    
    try {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error creating image from bytes: $error');
          return Container(); // Return empty container instead of null
        },
      );
    } catch (e) {
      debugPrint('❌ Exception creating image from bytes: $e');
      return null;
    }
  }
  
  /// Get headers for Google Drive requests
  static Future<Map<String, String>> getHeaders() async {
    return {
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
      'Authorization': 'Bearer ${await ApiService.getAuthToken()}',
    };
  }
} 