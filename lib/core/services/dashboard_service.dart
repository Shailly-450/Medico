import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import '../config.dart';
import '../../models/dashboard.dart';
import 'auth_service.dart';

class DashboardService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  // Get main dashboard data
  static Future<Dashboard?> getDashboardData() async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        developer.log('❌ DashboardService: No auth token available');
        return null;
      }

      final url = Uri.parse('$_baseUrl/dashboard');
      developer.log('📡 DashboardService: Fetching dashboard data from $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      developer
          .log('📡 DashboardService: Response status: ${response.statusCode}');
      developer.log('📡 DashboardService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          developer.log(
              '📡 DashboardService: Response data type: ${responseData.runtimeType}');

          if (responseData['success'] == true && responseData['data'] != null) {
            try {
              final dashboard = Dashboard.fromJson(responseData['data']);
              developer.log(
                  '✅ DashboardService: Successfully parsed dashboard data');
              return dashboard;
            } catch (parseError) {
              developer.log(
                  '❌ DashboardService: Error parsing dashboard data: $parseError');
              developer
                  .log('❌ DashboardService: Raw data: ${responseData['data']}');
              return null;
            }
          } else {
            developer.log(
                '❌ DashboardService: API returned success: false or no data');
            developer.log('❌ DashboardService: Response data: $responseData');
            return null;
          }
        } catch (jsonError) {
          developer.log('❌ DashboardService: Error decoding JSON: $jsonError');
          developer
              .log('❌ DashboardService: Raw response body: ${response.body}');
          return null;
        }
      } else {
        developer.log('❌ DashboardService: HTTP error ${response.statusCode}');
        return null;
      }
    } catch (e) {
      developer.log('❌ DashboardService: Exception occurred: $e');
      return null;
    }
  }

  // Get dashboard overview
  static Future<Map<String, dynamic>?> getDashboardOverview() async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        developer
            .log('❌ DashboardService: No auth token available for overview');
        return null;
      }

      final url = Uri.parse('$_baseUrl/dashboard/overview');
      developer
          .log('📡 DashboardService: Fetching dashboard overview from $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      developer.log(
          '📡 DashboardService: Overview response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer.log('✅ DashboardService: Successfully fetched overview');
          return responseData['data'];
        }
      }

      developer.log('❌ DashboardService: Failed to fetch overview');
      return null;
    } catch (e) {
      developer.log('❌ DashboardService: Exception in overview: $e');
      return null;
    }
  }

  // Get health overview
  static Future<Map<String, dynamic>?> getHealthOverview() async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        developer.log(
            '❌ DashboardService: No auth token available for health overview');
        return null;
      }

      final url = Uri.parse('$_baseUrl/dashboard/health-overview');
      developer.log('📡 DashboardService: Fetching health overview from $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      developer.log(
          '📡 DashboardService: Health overview response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer
              .log('✅ DashboardService: Successfully fetched health overview');
          return responseData['data'];
        }
      }

      developer.log('❌ DashboardService: Failed to fetch health overview');
      return null;
    } catch (e) {
      developer.log('❌ DashboardService: Exception in health overview: $e');
      return null;
    }
  }

  // Get active care
  static Future<Map<String, dynamic>?> getActiveCare() async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        developer
            .log('❌ DashboardService: No auth token available for active care');
        return null;
      }

      final url = Uri.parse('$_baseUrl/dashboard/active-care');
      developer.log('📡 DashboardService: Fetching active care from $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      developer.log(
          '📡 DashboardService: Active care response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer.log('✅ DashboardService: Successfully fetched active care');
          return responseData['data'];
        }
      }

      developer.log('❌ DashboardService: Failed to fetch active care');
      return null;
    } catch (e) {
      developer.log('❌ DashboardService: Exception in active care: $e');
      return null;
    }
  }

  // Get test checkups
  static Future<Map<String, dynamic>?> getTestCheckups() async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        developer.log(
            '❌ DashboardService: No auth token available for test checkups');
        return null;
      }

      final url = Uri.parse('$_baseUrl/dashboard/test-checkups');
      developer.log('📡 DashboardService: Fetching test checkups from $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      developer.log(
          '📡 DashboardService: Test checkups response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer
              .log('✅ DashboardService: Successfully fetched test checkups');
          return responseData['data'];
        }
      }

      developer.log('❌ DashboardService: Failed to fetch test checkups');
      return null;
    } catch (e) {
      developer.log('❌ DashboardService: Exception in test checkups: $e');
      return null;
    }
  }

  // Get recent medical history
  static Future<Map<String, dynamic>?> getRecentMedicalHistory() async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        developer.log(
            '❌ DashboardService: No auth token available for recent medical history');
        return null;
      }

      final url = Uri.parse('$_baseUrl/dashboard/recent-medical-history');
      developer.log(
          '📡 DashboardService: Fetching recent medical history from $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      developer.log(
          '📡 DashboardService: Recent medical history response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer.log(
              '✅ DashboardService: Successfully fetched recent medical history');
          return responseData['data'];
        }
      }

      developer
          .log('❌ DashboardService: Failed to fetch recent medical history');
      return null;
    } catch (e) {
      developer
          .log('❌ DashboardService: Exception in recent medical history: $e');
      return null;
    }
  }

  // Test backend connection
  static Future<bool> testBackendConnection() async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        developer.log('❌ DashboardService: No auth token for connection test');
        return false;
      }

      final url = Uri.parse('$_baseUrl/dashboard');
      developer.log('🔍 DashboardService: Testing connection to $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      developer.log(
          '🔍 DashboardService: Connection test status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      developer.log('❌ DashboardService: Connection test failed: $e');
      return false;
    }
  }
}
