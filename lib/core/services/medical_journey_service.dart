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
      // If the response is a list, return it directly
      if (data is List) {
        return data;
      }
      // If the response is an object with a 'data' key, return data['data']
      if (data is Map && data['data'] is List) {
        return data['data'];
      }
      throw Exception('Unexpected journeys response format');
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
      // If the response has a 'data' key, return data['data']
      if (data is Map && data.containsKey('data')) {
        return Map<String, dynamic>.from(data['data']);
      }
      // If the response is the journey object directly, return it
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      throw Exception('Unexpected create journey response format');
    } else {
      throw Exception('Failed to create journey: ${response.statusCode}');
    }
  }
}
