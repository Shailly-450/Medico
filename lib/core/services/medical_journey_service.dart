import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class MedicalJourneyService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 10);
  static const String journeysEndpoint = '/medical-journeys';

  final http.Client _client = http.Client();

  Map<String, String> get _authHeaders {
    final token = AuthService.accessToken;
    if (token == null) {
      throw Exception('User not authenticated');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all medical journeys
  Future<List<dynamic>> getJourneys() async {
    final response = await http
        .get(Uri.parse('$baseUrl$journeysEndpoint'), headers: _authHeaders)
        .timeout(timeout);
    print('API Response [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load journeys: ${response.statusCode}');
    }
  }

  // Create a new medical journey
  Future<Map<String, dynamic>> createJourney(
    Map<String, dynamic> journeyData,
  ) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$journeysEndpoint'),
          headers: _authHeaders,
          body: jsonEncode(journeyData),
        )
        .timeout(timeout);
    print('API Response [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create journey: ${response.statusCode}');
    }
  }
}
