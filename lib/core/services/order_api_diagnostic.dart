import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';
import 'auth_service.dart';

class OrderApiDiagnostic {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 10);

  // Test 1: Basic connectivity
  static Future<Map<String, dynamic>> testBasicConnectivity() async {
    try {
      debugPrint('🔍 Testing basic connectivity to $baseUrl');
      
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
      ));

      final response = await dio.get('/health');
      
      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'Basic connectivity successful',
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Basic connectivity failed',
      };
    }
  }

  // Test 2: Authentication status
  static Future<Map<String, dynamic>> testAuthentication() async {
    try {
      final token = AuthService.accessToken;
      
      if (token == null) {
        return {
          'success': false,
          'error': 'No authentication token found',
          'message': 'User is not authenticated',
        };
      }

      debugPrint('🔑 Testing authentication with token: ${token.substring(0, 20)}...');
      
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
      ));

      final response = await dio.get(
        '/auth/verify',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'Authentication successful',
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Authentication failed',
      };
    }
  }

  // Test 3: Orders endpoint availability
  static Future<Map<String, dynamic>> testOrdersEndpoint() async {
    try {
      final token = AuthService.accessToken;
      
      if (token == null) {
        return {
          'success': false,
          'error': 'No authentication token found',
          'message': 'Cannot test orders endpoint without authentication',
        };
      }

      debugPrint('📦 Testing orders endpoint');
      
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
      ));

      final response = await dio.get(
        '/orders',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'Orders endpoint accessible',
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Orders endpoint test failed',
      };
    }
  }

  // Test 4: Create order endpoint
  static Future<Map<String, dynamic>> testCreateOrderEndpoint() async {
    try {
      final token = AuthService.accessToken;
      
      if (token == null) {
        return {
          'success': false,
          'error': 'No authentication token found',
          'message': 'Cannot test create order without authentication',
        };
      }

      debugPrint('➕ Testing create order endpoint');
      
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
      ));

      // Test with minimal order data
      final testOrderData = {
        'serviceProviderId': 'test-provider',
        'serviceProviderName': 'Test Provider',
        'items': [
          {
            'serviceId': 'test-service',
            'serviceName': 'Test Service',
            'quantity': 1,
            'price': 100.0,
          }
        ],
        'subtotal': 100.0,
        'total': 100.0,
        'currency': 'INR',
      };

      final response = await dio.post(
        '/orders',
        data: testOrderData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'Create order endpoint accessible',
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Create order endpoint test failed',
      };
    }
  }

  // Comprehensive diagnostic
  static Future<Map<String, dynamic>> runFullDiagnostic() async {
    debugPrint('🔍 Starting comprehensive order API diagnostic...');
    
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'baseUrl': baseUrl,
      'tests': <String, Map<String, dynamic>>{},
    };

    // Run all tests
    final tests = results['tests'] as Map<String, Map<String, dynamic>>;
    tests['connectivity'] = await testBasicConnectivity();
    tests['authentication'] = await testAuthentication();
    tests['ordersEndpoint'] = await testOrdersEndpoint();
    tests['createOrder'] = await testCreateOrderEndpoint();

    // Determine overall status
    final allTests = tests.values.toList();
    final successfulTests = allTests.where((test) => test['success'] == true).length;
    final totalTests = allTests.length;

    results['overall'] = {
      'success': successfulTests == totalTests,
      'successfulTests': successfulTests,
      'totalTests': totalTests,
      'successRate': '${(successfulTests / totalTests * 100).toStringAsFixed(1)}%',
    };

    // Generate recommendations
    results['recommendations'] = _generateRecommendations(tests);

    debugPrint('📊 Diagnostic complete: ${results['overall']['successRate']} success rate');
    return results;
  }

  static List<String> _generateRecommendations(Map<String, Map<String, dynamic>>? tests) {
    final recommendations = <String>[];

    if (tests == null) {
      recommendations.add('🔴 Unable to run diagnostic tests');
      return recommendations;
    }

    if (tests['connectivity']?['success'] != true) {
      recommendations.add('🔴 Check your internet connection and API server availability');
      recommendations.add('🔴 Verify the API base URL: $baseUrl');
    }

    if (tests['authentication']?['success'] != true) {
      recommendations.add('🔴 User authentication is required - please log in');
      recommendations.add('🔴 Check if the JWT token is valid and not expired');
    }

    if (tests['ordersEndpoint']?['success'] != true && tests['authentication']?['success'] == true) {
      recommendations.add('🔴 Orders endpoint is not accessible - check API permissions');
      recommendations.add('🔴 Verify the orders endpoint exists on the server');
    }

    if (tests['createOrder']?['success'] != true && tests['authentication']?['success'] == true) {
      recommendations.add('🔴 Create order endpoint is not working - check request format');
      recommendations.add('🔴 Verify required fields in order creation payload');
    }

    if (recommendations.isEmpty) {
      recommendations.add('✅ All tests passed! Order API should be working correctly');
    }

    return recommendations;
  }
} 