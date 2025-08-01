import 'package:flutter_test/flutter_test.dart';
import 'package:medico/core/services/api_service.dart';
import 'package:medico/core/services/file_upload_service.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Profile Avatar Upload Tests', () {
    setUp(() async {
      // Set up mock authentication tokens
      await ApiService.saveTokens('mock_access_token', 'mock_refresh_token');
    });

    test('Mock profile avatar upload should work when backend is not available', () async {
      // Test the mock implementation
      final result = await ApiService.getProfile();
      
      expect(result['success'], true);
      expect(result['data'], isNotNull);
      expect(result['data']['id'], 'mock_user_123');
      expect(result['data']['name'], 'John Doe');
    });

    test('Mock profile update should work when backend is not available', () async {
      final updateData = {
        'name': 'Jane Doe',
        'email': 'jane.doe@example.com',
        'profilePictureUrl': 'https://example.com/avatar.jpg',
      };
      
      final result = await ApiService.updateProfile(updateData);
      
      expect(result['success'], true);
      expect(result['data']['name'], 'Jane Doe');
      expect(result['data']['email'], 'jane.doe@example.com');
      expect(result['data']['profilePictureUrl'], 'https://example.com/avatar.jpg');
    });

    test('Mock profile avatar upload should work', () async {
      // Create a temporary file for testing
      final tempFile = File('test_avatar.jpg');
      await tempFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]); // Minimal JPEG header
      
      try {
        final result = await FileUploadService.uploadProfileAvatar(tempFile);
        
        expect(result['success'], true);
        expect(result['fileId'], isNotNull);
        expect(result['webContentLink'], isNotNull);
        expect(result['message'], contains('Profile avatar uploaded successfully'));
      } finally {
        // Clean up
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    });
  });
} 