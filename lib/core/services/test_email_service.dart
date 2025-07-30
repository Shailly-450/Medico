import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class TestEmailService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 10);
  static const String testEmailEndpoint = '/test/email';

  final http.Client _client = http.Client();

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Test email service functionality (development only)
  Future<Map<String, dynamic>> testEmail({
    required String email,
    required String otp,
    required String name,
  }) async {
    final requestBody = {
      'email': email,
      'otp': otp,
      'name': name,
    };

    print('Testing email service with body: $requestBody');

    final response = await http
        .post(
          Uri.parse('$baseUrl$testEmailEndpoint'),
          headers: _headers,
          body: jsonEncode(requestBody),
        )
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to test email service: ${response.statusCode}');
    }
  }

  // Test email with default values for quick testing
  Future<Map<String, dynamic>> testEmailWithDefaults() async {
    return testEmail(
      email: 'test@example.com',
      otp: '123456',
      name: 'Test User',
    );
  }
} 