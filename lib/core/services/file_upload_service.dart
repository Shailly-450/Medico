import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'api_service.dart';

class FileUploadService {
  static const String _baseUrl = 'http://localhost:3000/api';
  
  /// Upload any file to Google Drive via backend API
  static Future<Map<String, dynamic>> uploadFileToDrive({
    required File file,
    required String fileName,
    String? description,
    String? folderId,
  }) async {
    try {
      debugPrint('🌐 Uploading file to Google Drive via API...');
      
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer ${await _getAuthToken()}';
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('image', file.path),
      );
      
      // Add optional parameters
      if (description != null) {
        request.fields['description'] = description;
      }
      if (folderId != null) {
        request.fields['folderId'] = folderId;
      }
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('📡 API Response [${response.statusCode}]: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          return {
            'success': true,
            'fileId': responseData['fileId'],
            'fileName': responseData['fileName'],
            'webViewLink': responseData['webViewLink'],
            'webContentLink': responseData['webContentLink'],
            'message': responseData['message'],
          };
        } else {
          throw Exception('Upload failed: ${responseData['message']}');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error uploading file to Google Drive: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Delete file from Google Drive via backend API
  static Future<Map<String, dynamic>> deleteFileFromDrive(String fileId) async {
    try {
      debugPrint('🗑️ Deleting file from Google Drive: $fileId');
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/upload/$fileId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );
      
      debugPrint('📡 Delete Response [${response.statusCode}]: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'success': responseData['success'] == true,
          'message': responseData['message'],
        };
      } else {
        throw Exception('Delete failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error deleting file from Google Drive: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Get file information from Google Drive via backend API
  static Future<Map<String, dynamic>> getFileInfo(String fileId) async {
    try {
      debugPrint('📋 Getting file info from Google Drive: $fileId');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/upload/$fileId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );
      
      debugPrint('📡 File Info Response [${response.statusCode}]: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'success': responseData['success'] == true,
          'fileInfo': responseData['fileInfo'],
        };
      } else {
        throw Exception('Get file info failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting file info from Google Drive: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Upload profile avatar to Google Drive
  static Future<Map<String, dynamic>> uploadProfileAvatar(File file) async {
    try {
      debugPrint('👤 Uploading profile avatar to Google Drive...');
      
      // Check if backend server is available
      final isBackendAvailable = await _checkBackendAvailability();
      
      if (!isBackendAvailable) {
        debugPrint('🔄 Backend not available, using mock profile avatar upload');
        return _mockProfileAvatarUpload(file);
      }
      
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      
      final result = await uploadFileToDrive(
        file: file,
        fileName: fileName,
        description: 'User profile avatar',
      );
      
      if (result['success'] == true) {
        // Update user profile with Google Drive file ID
        final updateResult = await ApiService.updateProfile({
          'profilePictureId': result['fileId'],
          'profilePictureUrl': result['webContentLink'],
        });
        
        if (updateResult['success'] == true) {
          return {
            'success': true,
            'fileId': result['fileId'],
            'webContentLink': result['webContentLink'],
            'message': 'Profile avatar uploaded successfully',
          };
        } else {
          throw Exception('Failed to update profile: ${updateResult['message']}');
        }
      } else {
        throw Exception('Failed to upload avatar: ${result['error']}');
      }
    } catch (e) {
      debugPrint('❌ Error uploading profile avatar: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Mock profile avatar upload for when backend is not available
  static Future<Map<String, dynamic>> _mockProfileAvatarUpload(File file) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate a mock file ID and use the actual file path as the URL
      final mockFileId = 'mock_profile_${DateTime.now().millisecondsSinceEpoch}';
      
      // Use the actual file path as the image URL so the selected image is displayed
      final mockWebContentLink = 'file://${file.absolute.path}';
      
      // Update user profile with mock data
      final updateResult = await ApiService.updateProfile({
        'profilePictureId': mockFileId,
        'profilePictureUrl': mockWebContentLink,
      });
      
      if (updateResult['success'] == true) {
        debugPrint('✅ Mock profile avatar upload successful - using actual image: ${file.path}');
        return {
          'success': true,
          'fileId': mockFileId,
          'webContentLink': mockWebContentLink,
          'message': 'Profile avatar uploaded successfully (Mock)',
        };
      } else {
        throw Exception('Failed to update profile: ${updateResult['message']}');
      }
    } catch (e) {
      debugPrint('❌ Error in mock profile avatar upload: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Check if backend server is available
  static Future<bool> _checkBackendAvailability() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/health'),
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ Backend server not available: $e');
      return false;
    }
  }
  
  /// Upload doctor profile image to Google Drive
  static Future<Map<String, dynamic>> uploadDoctorProfileImage(File file, String doctorId) async {
    try {
      debugPrint('👨‍⚕️ Uploading doctor profile image to Google Drive...');
      
      final fileName = 'doctor_profile_${doctorId}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      
      final result = await uploadFileToDrive(
        file: file,
        fileName: fileName,
        description: 'Doctor profile image for doctor ID: $doctorId',
      );
      
      if (result['success'] == true) {
        return {
          'success': true,
          'fileId': result['fileId'],
          'webContentLink': result['webContentLink'],
          'message': 'Doctor profile image uploaded successfully',
        };
      } else {
        throw Exception('Failed to upload doctor profile image: ${result['error']}');
      }
    } catch (e) {
      debugPrint('❌ Error uploading doctor profile image: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Upload insurance card to Google Drive
  static Future<Map<String, dynamic>> uploadInsuranceCard(File file) async {
    try {
      debugPrint('🏥 Uploading insurance card to Google Drive...');
      
      final fileName = 'insurance_card_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      
      final result = await uploadFileToDrive(
        file: file,
        fileName: fileName,
        description: 'Insurance card image',
      );
      
      if (result['success'] == true) {
        return {
          'success': true,
          'fileId': result['fileId'],
          'webContentLink': result['webContentLink'],
          'message': 'Insurance card uploaded successfully',
        };
      } else {
        throw Exception('Failed to upload insurance card: ${result['error']}');
      }
    } catch (e) {
      debugPrint('❌ Error uploading insurance card: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Upload document to Google Drive
  static Future<Map<String, dynamic>> uploadDocument(File file, String documentType) async {
    try {
      debugPrint('📄 Uploading document to Google Drive...');
      
      final fileName = 'document_${documentType}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      
      final result = await uploadFileToDrive(
        file: file,
        fileName: fileName,
        description: 'Document upload: $documentType',
      );
      
      if (result['success'] == true) {
        return {
          'success': true,
          'fileId': result['fileId'],
          'webContentLink': result['webContentLink'],
          'message': 'Document uploaded successfully',
        };
      } else {
        throw Exception('Failed to upload document: ${result['error']}');
      }
    } catch (e) {
      debugPrint('❌ Error uploading document: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Upload prescription to Google Drive
  static Future<Map<String, dynamic>> uploadPrescription(File file, String prescriptionId) async {
    try {
      debugPrint('💊 Uploading prescription to Google Drive...');
      
      final fileName = 'prescription_${prescriptionId}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      
      final result = await uploadFileToDrive(
        file: file,
        fileName: fileName,
        description: 'Prescription file for prescription ID: $prescriptionId',
      );
      
      if (result['success'] == true) {
        return {
          'success': true,
          'fileId': result['fileId'],
          'webContentLink': result['webContentLink'],
          'message': 'Prescription uploaded successfully',
        };
      } else {
        throw Exception('Failed to upload prescription: ${result['error']}');
      }
    } catch (e) {
      debugPrint('❌ Error uploading prescription: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error picking image from gallery: $e');
      return null;
    }
  }
  
  /// Take photo with camera
  static Future<File?> takePhotoWithCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error taking photo: $e');
      return null;
    }
  }
  
  /// Pick file from device
  static Future<File?> pickFile({
    List<String>? allowedExtensions,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (await file.exists()) {
          return file;
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error picking file: $e');
      return null;
    }
  }
  
  /// Get authentication token
  static Future<String?> _getAuthToken() async {
    return ApiService.accessToken;
  }
  
  /// Validate file size (max 10MB)
  static bool isValidFileSize(File file) {
    const int maxSizeBytes = 10 * 1024 * 1024; // 10MB
    return file.lengthSync() <= maxSizeBytes;
  }
  
  /// Get file size in MB
  static double getFileSizeInMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }
  
  /// Get file extension
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }
  
  /// Check if file is an image
  static bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }
  
  /// Check if file is a PDF
  static bool isPdfFile(String filePath) {
    return getFileExtension(filePath) == 'pdf';
  }
} 