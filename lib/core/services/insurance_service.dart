import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/insurance.dart';
import '../config.dart';
import 'dart:io';
import 'auth_service.dart';

class InsuranceService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final String insuranceEndpoint = '/insurance';
  final Duration timeout = const Duration(seconds: 10);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${AuthService.accessToken}',
  };

  // Get all insurances for a user
  Future<List<Insurance>> getInsurances() async {
    print('Fetching insurances...');

    if (AuthService.accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http
        .get(Uri.parse('$baseUrl$insuranceEndpoint'), headers: _headers)
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => Insurance.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to fetch insurances: ${response.statusCode}');
    }
  }

  // Create new insurance
  Future<Insurance> createInsurance({
    required String userId,
    required String insuranceProvider,
    required String policyNumber,
    required String policyHolderName,
    required DateTime validFrom,
    required DateTime validTo,
    String? insuranceCard,
  }) async {
    if (AuthService.accessToken == null) {
      throw Exception('Not authenticated');
    }

    final requestBody = {
      'userId': userId,
      'insuranceProvider': insuranceProvider,
      'policyNumber': policyNumber,
      'policyHolderName': policyHolderName,
      'validFrom': validFrom.toIso8601String().split('T')[0],
      'validTo': validTo.toIso8601String().split('T')[0],
      if (insuranceCard != null) 'insuranceCard': insuranceCard,
    };

    print('Creating insurance with body: $requestBody');

    final response = await http
        .post(
          Uri.parse('$baseUrl$insuranceEndpoint'),
          headers: _headers,
          body: jsonEncode(requestBody),
        )
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        return Insurance.fromJson(responseData['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to create insurance: ${response.statusCode}');
    }
  }

  // Upload insurance card image
  Future<String> uploadInsuranceCard(File imageFile) async {
    if (AuthService.accessToken == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$baseUrl$insuranceEndpoint/upload');

    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer ${AuthService.accessToken}';
    request.files.add(
      await http.MultipartFile.fromPath('insuranceCard', imageFile.path),
    );

    print('Uploading insurance card...');

    final streamedResponse = await request.send().timeout(timeout);
    final response = await http.Response.fromStream(streamedResponse);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        return responseData['data']['url'] as String;
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception(
        'Failed to upload insurance card: ${response.statusCode}',
      );
    }
  }

  // Delete insurance
  Future<void> deleteInsurance(String insuranceId) async {
    if (AuthService.accessToken == null) {
      throw Exception('Not authenticated');
    }

    print('Deleting insurance $insuranceId');

    final response = await http
        .delete(
          Uri.parse('$baseUrl$insuranceEndpoint/$insuranceId'),
          headers: _headers,
        )
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['success'] != true) {
        throw Exception('Failed to delete insurance: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to delete insurance: ${response.statusCode}');
    }
  }

  // Update insurance
  Future<Insurance> updateInsurance({
    required String insuranceId,
    String? insuranceProvider,
    String? policyNumber,
    String? policyHolderName,
    DateTime? validFrom,
    DateTime? validTo,
    String? insuranceCard,
  }) async {
    if (AuthService.accessToken == null) {
      throw Exception('Not authenticated');
    }

    final Map<String, dynamic> requestBody = {
      if (insuranceProvider != null) 'insuranceProvider': insuranceProvider,
      if (policyNumber != null) 'policyNumber': policyNumber,
      if (policyHolderName != null) 'policyHolderName': policyHolderName,
      if (validFrom != null)
        'validFrom': validFrom.toIso8601String().split('T')[0],
      if (validTo != null) 'validTo': validTo.toIso8601String().split('T')[0],
      if (insuranceCard != null) 'insuranceCard': insuranceCard,
    };

    print('Updating insurance $insuranceId with body: $requestBody');

    final response = await http
        .patch(
          Uri.parse('$baseUrl$insuranceEndpoint/$insuranceId'),
          headers: _headers,
          body: jsonEncode(requestBody),
        )
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        return Insurance.fromJson(responseData['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to update insurance: ${response.statusCode}');
    }
  }
}
