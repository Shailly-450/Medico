import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class TestCheckupResponse {
  final List<dynamic> upcoming;
  final List<dynamic> overdue;
  final List<dynamic> checkups;
  final Map<String, int> counts;

  TestCheckupResponse({
    required this.upcoming,
    required this.overdue,
    required this.checkups,
    required this.counts,
  });

  factory TestCheckupResponse.fromJson(Map<String, dynamic> json) {
    return TestCheckupResponse(
      upcoming: json['today']['upcoming'] as List<dynamic>,
      overdue: json['today']['overdue'] as List<dynamic>,
      checkups: json['checkups'] as List<dynamic>,
      counts: Map<String, int>.from(json['counts']),
    );
  }
}

class TestCheckupService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 10);
  static const String checkupsEndpoint = '/checkups';

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

  Future<TestCheckupResponse> getCheckups() async {
    final response = await http
        .get(Uri.parse('$baseUrl$checkupsEndpoint'), headers: _authHeaders)
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TestCheckupResponse.fromJson(data);
    } else {
      throw Exception('Failed to load checkups: ${response.statusCode}');
    }
  }

  // Create a new test checkup
  Future<Map<String, dynamic>> createCheckup({
    required String name,
    required String type,
    required String priority,
    required String description,
    required DateTime scheduledAt,
    required Map<String, String> provider,
    required double cost,
    required String userId,
  }) async {
    final requestBody = {
      'name': name,
      'type': type,
      'status': 'upcoming',
      'priority': priority,
      'description': description,
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'provider': provider,
      'cost': cost,
      'user': userId,
    };

    print('Creating checkup with body: $requestBody');

    final response = await http
        .post(
          Uri.parse('$baseUrl$checkupsEndpoint'),
          headers: _authHeaders,
          body: jsonEncode(requestBody),
        )
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to create checkup: ${response.statusCode}');
    }
  }
}
