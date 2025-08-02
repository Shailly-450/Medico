import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'file_upload_service.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class ApiService {
  // Configuration
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Token management
  static String? _accessToken;
  static String? _refreshToken;

  // Getters
  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static bool get isAuthenticated => _accessToken != null;

  // Initialize tokens from storage
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
  }

  // Save tokens to storage
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  // Clear tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    _accessToken = null;
    _refreshToken = null;
  }

  // Get headers with authentication
  static Map<String, String> get _authHeaders {
    final headers = Map<String, String>.from(defaultHeaders);
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // Generic HTTP methods
  static Future<http.Response> _get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(
        url,
        headers: headers ?? _authHeaders,
      ).timeout(timeout);
      
      _handleResponse(response);
      return response;
    } catch (e) {
      debugPrint('❌ GET request failed for $endpoint: $e');
      throw Exception('Backend server not available: $e');
    }
  }

  static Future<http.Response> _post(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: headers ?? _authHeaders,
        body: jsonEncode(body),
      ).timeout(timeout);
      
      _handleResponse(response);
      return response;
    } catch (e) {
      debugPrint('❌ POST request failed for $endpoint: $e');
      throw Exception('Backend server not available: $e');
    }
  }

  static Future<http.Response> _put(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        url,
        headers: headers ?? _authHeaders,
        body: jsonEncode(body),
      ).timeout(timeout);
      
      _handleResponse(response);
      return response;
    } catch (e) {
      debugPrint('❌ PUT request failed for $endpoint: $e');
      throw Exception('Backend server not available: $e');
    }
  }

  static Future<http.Response> _delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(
        url,
        headers: headers ?? _authHeaders,
      ).timeout(timeout);
      
      _handleResponse(response);
      return response;
    } catch (e) {
      debugPrint('❌ DELETE request failed for $endpoint: $e');
      throw Exception('Backend server not available: $e');
    }
  }

  // Handle response and token refresh
  static void _handleResponse(http.Response response) {
    if (response.statusCode == 401 && _refreshToken != null) {
      // Token expired, try to refresh
      _refreshAccessToken();
    }
  }

  // Refresh access token
  static Future<bool> _refreshAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: defaultHeaders,
        body: jsonEncode({'refreshToken': _refreshToken}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await saveTokens(data['data']['accessToken'], data['data']['refreshToken']);
          return true;
        }
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }
    
    // Refresh failed, clear tokens
    await clearTokens();
    return false;
  }

  // Parse response
  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid JSON response',
        'error': e.toString(),
      };
    }
  }

  // Public method to parse response
  static Map<String, dynamic> parseResponse(http.Response response) {
    return _parseResponse(response);
  }

  // Authentication endpoints
  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _post('/auth/register', userData);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      final data = _parseResponse(response);
      if (data['success'] == true) {
        await saveTokens(data['data']['accessToken'], data['data']['refreshToken']);
      }
      
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _post('/auth/logout', {});
      await clearTokens();
      return _parseResponse(response);
    } catch (e) {
      await clearTokens();
      return {
        'success': false,
        'message': 'Logout failed: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    if (_accessToken == null) {
      return {
        'success': false,
        'message': 'Access token required',
      };
    }
    try {
      final response = await _get('/auth/me');
      final data = _parseResponse(response);
      
      if (data['success'] == true) {
        debugPrint('✅ Successfully fetched profile from backend');
        return data;
      } else {
        debugPrint('❌ Backend returned error: ${data['message']}');
        // Only use mock if backend returns an error
        debugPrint('🔄 Using mock profile data due to backend error');
        return await getMockProfile();
      }
    } catch (e) {
      debugPrint('❌ Backend connection failed: $e');
      // Only use mock if backend is unreachable
      debugPrint('🔄 Using mock profile data due to backend unavailability');
      return await getMockProfile();
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    // Always use mock for local testing
    debugPrint('🔄 Forcing mock profile update');
    return await _mockUpdateProfile(profileData);
  }
  
  /// Mock profile data for when backend is not available
  static Future<Map<String, dynamic>> getMockProfile() async {
    final imageUrl = await _getPersistedImageUrl() ?? 'https://via.placeholder.com/150/007AFF/FFFFFF?text=JD';
    final profilePictureId = await _getPersistedProfilePictureId() ?? 'mock_profile_123';
    
    return {
      'success': true,
      'data': {
        'id': 'mock_user_123',
        'name': 'Shailly Yadav',
        'email': 'shaillyy861@gmail.com',
        'phone': '7007051309',
        'address': 'Infocity, Gandhinagar, Gujarat, 382010, India',
        'imageUrl': imageUrl, // This is what the UI expects
        'profilePicture': imageUrl, // Keep for backward compatibility
        'profilePictureId': profilePictureId,
        'profilePictureUrl': imageUrl,
        'dateOfBirth': '1990-01-01',
        'gender': 'Female',
        'bloodGroup': 'O+',
        'emergencyContact': {
          'name': 'Jane Doe',
          'phone': '+1234567891',
          'relationship': 'Spouse'
        }
      }
    };
  }
  
  /// Get persisted image URL from SharedPreferences
  static Future<String?> _getPersistedImageUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('mock_profile_image_url');
    } catch (e) {
      return null;
    }
  }
  
  /// Get persisted profile picture ID from SharedPreferences
  static Future<String?> _getPersistedProfilePictureId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('mock_profile_picture_id');
    } catch (e) {
      return null;
    }
  }
  
  /// Save image URL to SharedPreferences
  static Future<void> _saveImageUrl(String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mock_profile_image_url', imageUrl);
    } catch (e) {
      debugPrint('Failed to save image URL: $e');
    }
  }
  
  /// Save profile picture ID to SharedPreferences
  static Future<void> _saveProfilePictureId(String profilePictureId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mock_profile_picture_id', profilePictureId);
    } catch (e) {
      debugPrint('Failed to save profile picture ID: $e');
    }
  }
  
  /// Mock profile update for when backend is not available
  static Future<Map<String, dynamic>> _mockUpdateProfile(Map<String, dynamic> profileData) async {
    // Save image URL and profile picture ID if provided
    if (profileData['profilePictureUrl'] != null) {
      await _saveImageUrl(profileData['profilePictureUrl']);
    }
    if (profileData['profilePictureId'] != null) {
      await _saveProfilePictureId(profileData['profilePictureId']);
    }
    
    // Get the updated image URL (either from input or persisted)
    final imageUrl = profileData['profilePictureUrl'] ?? await _getPersistedImageUrl() ?? 'https://via.placeholder.com/150/007AFF/FFFFFF?text=JD';
    final profilePictureId = profileData['profilePictureId'] ?? await _getPersistedProfilePictureId() ?? 'mock_profile_123';
    
    // Simulate successful update
    return {
      'success': true,
      'data': {
        'id': 'mock_user_123',
        'name': profileData['name'] ?? 'Shailly Yadav',
        'email': profileData['email'] ?? 'shaillyy861@gmail.com',
        'phone': profileData['phone'] ?? '7007051309',
        'address': profileData['address'] ?? 'Infocity, Gandhinagar, Gujarat, 382010, India',
        'imageUrl': imageUrl, // This is what the UI expects
        'profilePicture': imageUrl, // Keep for backward compatibility
        'profilePictureId': profilePictureId,
        'profilePictureUrl': imageUrl,
        'dateOfBirth': profileData['dateOfBirth'] ?? '1990-01-01',
        'gender': profileData['gender'] ?? 'Female',
        'bloodGroup': profileData['bloodGroup'] ?? 'O+',
        'emergencyContact': profileData['emergencyContact'] ?? {
          'name': 'Jane Doe',
          'phone': '+1234567891',
          'relationship': 'Spouse'
        }
      },
      'message': 'Profile updated successfully (Mock)'
    };
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: _authHeaders,
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      ).timeout(timeout);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to change password:  ${e.toString()}',
      };
    }
  }

  // Upload/Update profile avatar
  static Future<Map<String, dynamic>> uploadProfileAvatar(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {
          'success': false,
          'message': 'File does not exist',
        };
      }
      
      // Use the new FileUploadService for Google Drive upload
      final result = await FileUploadService.uploadProfileAvatar(file);
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload avatar: ${e.toString()}',
      };
    }
  }

  // Add family member
  static Future<Map<String, dynamic>> addFamilyMember(Map<String, dynamic> memberData) async {
    try {
      final response = await _post('/family-members', memberData);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to add family member:  ${e.toString()}',
      };
    }
  }

  // List family members
  static Future<Map<String, dynamic>> getFamilyMembers() async {
    try {
      final response = await _get('/family-members');
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch family members: ${e.toString()}',
      };
    }
  }

  // Edit family member
  static Future<Map<String, dynamic>> updateFamilyMember(String familyMemberId, Map<String, dynamic> data) async {
    try {
      final response = await _put('/family-members/$familyMemberId', data);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update family member: ${e.toString()}',
      };
    }
  }

  // Delete family member
  static Future<Map<String, dynamic>> deleteFamilyMember(String familyMemberId) async {
    try {
      final response = await _delete('/family-members/$familyMemberId');
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete family member: ${e.toString()}',
      };
    }
  }

  // Hospital endpoints
  static Future<Map<String, dynamic>> getHospitals({
    int page = 1,
    int limit = 10,
    String? search,
    String? specialty,
    String? city,
    bool? emergencyServices,
    bool? verified,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (search != null) queryParams['search'] = search;
      if (specialty != null) queryParams['specialty'] = specialty;
      if (city != null) queryParams['city'] = city;
      if (emergencyServices != null) queryParams['emergencyServices'] = emergencyServices.toString();
      if (verified != null) queryParams['verified'] = verified.toString();
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/hospitals${queryString.isNotEmpty ? '?$queryString' : ''}';
      
      final response = await _get(endpoint);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get hospitals: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getHospitalById(String hospitalId) async {
    try {
      final response = await _get('/hospitals/$hospitalId');
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get hospital: ${e.toString()}',
      };
    }
  }

  // Search nearby hospitals
  static Future<Map<String, dynamic>> searchNearbyHospitals({
    required double latitude,
    required double longitude,
    double maxDistance = 10000,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'maxDistance': maxDistance.toString(),
        'limit': limit.toString(),
      };

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/hospitals/search/nearby${queryString.isNotEmpty ? '?$queryString' : ''}';
      
      final response = await _get(endpoint);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to search nearby hospitals: ${e.toString()}',
      };
    }
  }

  // Get hospital reviews
  static Future<Map<String, dynamic>> getHospitalReviews(
    String hospitalId, {
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/hospitals/$hospitalId/reviews${queryString.isNotEmpty ? '?$queryString' : ''}';
      
      final response = await _get(endpoint);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get hospital reviews: ${e.toString()}',
      };
    }
  }

  // Get hospital statistics
  static Future<Map<String, dynamic>> getHospitalStats(String hospitalId) async {
    try {
      final response = await _get('/hospitals/$hospitalId/stats');
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get hospital stats: ${e.toString()}',
      };
    }
  }

  // Get general hospital statistics
  static Future<Map<String, dynamic>> getGeneralHospitalStats() async {
    try {
      final response = await _get('/hospitals/stats');
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get general hospital stats: ${e.toString()}',
      };
    }
  }

  // Doctor endpoints
  static Future<Map<String, dynamic>> getDoctors({
    int page = 1,
    int limit = 10,
    String? specialty,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (specialty != null) queryParams['specialty'] = specialty;
      if (search != null) queryParams['search'] = search;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/users/doctors${queryString.isNotEmpty ? '?$queryString' : ''}';
      
      final response = await _get(endpoint);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get doctors: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getDoctorById(String doctorId) async {
    try {
      final response = await _get('/users/doctors/$doctorId');
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get doctor: ${e.toString()}',
      };
    }
  }

  // Appointment endpoints
  static Future<Map<String, dynamic>> getAppointments({
    int page = 1,
    int limit = 10,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null) queryParams['status'] = status;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/appointments${queryString.isNotEmpty ? '?$queryString' : ''}';
      
      final response = await _get(endpoint);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get appointments: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final response = await _post('/appointments', appointmentData);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create appointment: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> updateAppointment(String appointmentId, Map<String, dynamic> appointmentData) async {
    try {
      final response = await _put('/appointments/$appointmentId', appointmentData);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update appointment: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> cancelAppointment(String appointmentId) async {
    try {
      final response = await _delete('/appointments/$appointmentId');
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to cancel appointment: ${e.toString()}',
      };
    }
  }

  // Chat endpoints
  static Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null) queryParams['status'] = status;

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/chat/conversations${queryString.isNotEmpty ? '?$queryString' : ''}';
      
      final response = await _get(endpoint);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get conversations: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> createConversation(Map<String, dynamic> conversationData) async {
    try {
      final response = await _post('/chat/conversations', conversationData);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create conversation: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getMessages(String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/chat/conversations/$conversationId/messages${queryString.isNotEmpty ? '?$queryString' : ''}';
      
      final response = await _get(endpoint);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get messages: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> sendMessage(String conversationId, Map<String, dynamic> messageData) async {
    try {
      final response = await _post('/chat/conversations/$conversationId/messages', messageData);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send message: ${e.toString()}',
      };
    }
  }

  // Prescription endpoints
  static Future<Map<String, dynamic>> getPrescriptions({
    int page = 1,
    int limit = 10,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null) queryParams['status'] = status;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/prescriptions${queryString.isNotEmpty ? '?$queryString' : ''}';
      
      final response = await _get(endpoint);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get prescriptions: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> createPrescription(Map<String, dynamic> prescriptionData) async {
    try {
      final response = await _post('/prescriptions', prescriptionData);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create prescription: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> updatePrescription(String prescriptionId, Map<String, dynamic> prescriptionData) async {
    try {
      final response = await _put('/prescriptions/$prescriptionId', prescriptionData);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update prescription: ${e.toString()}',
      };
    }
  }

  // Give or update consent
  static Future<Map<String, dynamic>> giveOrUpdateConsent(Map<String, dynamic> consentData) async {
    try {
      final response = await _post('/consent', consentData);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to give or update consent: ${e.toString()}',
      };
    }
  }

  // Get all consents
  static Future<Map<String, dynamic>> getConsents() async {
    try {
      final response = await _get('/consent');
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch consents: ${e.toString()}',
      };
    }
  }

  // Health check
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: defaultHeaders,
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getAllBlogs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/blogs'),
      headers: _authHeaders,
    );
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> toggleBlogLike(String blogId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/blogs/$blogId/like'),
      headers: _authHeaders,
    );
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> toggleBlogBookmark(String blogId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/blogs/$blogId/bookmark'),
      headers: _authHeaders,
    );
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> getBookmarkedBlogs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/blogs/user/bookmarks'),
      headers: _authHeaders,
    );
    return _parseResponse(response);
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    return _accessToken;
  }

  /// Get authenticated Google Drive URL
  static Future<Map<String, dynamic>> getAuthenticatedDriveUrl(String fileId) async {
    try {
      debugPrint('🔐 Getting authenticated Drive URL for file ID: $fileId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/drive/authenticated-url/$fileId'),
        headers: _authHeaders,
      );
      
      debugPrint('📡 Authenticated URL Response [${response.statusCode}]: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': data['success'] == true,
          'url': data['url'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get authenticated URL: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('❌ Error getting authenticated Drive URL: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
} 