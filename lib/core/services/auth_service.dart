import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../config.dart';

enum UserRole { patient, doctor, admin }

class AuthService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 10);

  static UserRole? _currentUserRole;
  static String? _currentUserId;
  static String? _currentUserName;
  static String? _accessToken;
  static String? _refreshToken;

  // Getters for current user info
  static UserRole? get currentUserRole => _currentUserRole;
  static String? get currentUserId => _currentUserId;
  static String? get currentUserName => _currentUserName;
  static bool get isLoggedIn => _accessToken != null;
  static String? get accessToken => _accessToken;

  // Initialize tokens from storage
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    
    // If we have a token, try to get user profile
    if (_accessToken != null) {
      await getProfile();
    }
  }

  // Save tokens to storage
  static Future<void> _saveTokens(String accessToken, String refreshToken) async {
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
    _currentUserRole = null;
    _currentUserId = null;
    _currentUserName = null;
  }

  // Login method using real API
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        // Save tokens
        await _saveTokens(
          data['data']['token'], 
          data['data']['refreshToken'] ?? 'dummy-refresh-token'
        );
        
        // Set user info
        final user = data['data']['user'];
        _currentUserId = user['id'];
        _currentUserName = user['profile']['name'];
        _currentUserRole = _parseUserRole(user['role']);
        
        return {
          'success': true,
          'message': 'Login successful',
          'role': _currentUserRole,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      if (_accessToken == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        final user = data['data'];
        _currentUserId = user['_id'];
        _currentUserName = user['profile']['name'];
        _currentUserRole = _parseUserRole(user['role']);
        
        return {
          'success': true,
          'message': 'Profile retrieved successfully',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Profile retrieval failed: ${e.toString()}',
      };
    }
  }

  // Logout method
  static Future<Map<String, dynamic>> logout() async {
    try {
      if (_accessToken != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
        ).timeout(timeout);
      }
      
      await clearTokens();
      return {
        'success': true,
        'message': 'Logout successful',
      };
    } catch (e) {
      await clearTokens();
      return {
        'success': false,
        'message': 'Logout failed: ${e.toString()}',
      };
    }
  }

  // Helper method to parse user role
  static UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return UserRole.doctor;
      case 'admin':
        return UserRole.admin;
      case 'patient':
      default:
        return UserRole.patient;
    }
  }

  // Check if user is doctor
  static bool get isDoctor => _currentUserRole == UserRole.doctor;
  
  // Check if user is admin
  static bool get isAdmin => _currentUserRole == UserRole.admin;
  
  // Check if user is patient
  static bool get isPatient => _currentUserRole == UserRole.patient;

  // Forgot password method
  static Future<Map<String, dynamic>> forgotPassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Failed to reset password',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to reset password: ${e.toString()}',
      };
    }
  }

  // Reset password method
  static Future<Map<String, dynamic>> resetPassword(String token, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'password': password,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Failed to reset password',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to reset password: ${e.toString()}',
      };
    }
  }
} 