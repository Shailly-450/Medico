import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/prescription.dart';
import '../config.dart';
import 'auth_service.dart';

class PrescriptionService {
  static const String _endpoint = '/prescriptions';
  String get baseUrl => '${AppConfig.apiBaseUrl}$_endpoint';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${AuthService.accessToken}',
      };

  Future<List<Prescription>> getPrescriptions() async {
    try {
      debugPrint('🌐 Fetching prescriptions from: $baseUrl');

      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _headers,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('📦 Response structure: $responseData');

        // Check if response has success field and data field
        if (responseData.containsKey('success') &&
            responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'];
          final prescriptions =
              data.map((json) => Prescription.fromJson(json)).toList();
          debugPrint(
              '✅ Successfully fetched ${prescriptions.length} prescriptions');
          return prescriptions;
        } else {
          // If response doesn't have the expected structure, throw an error
          throw Exception(
              'Unexpected response format: missing success or data fields');
        }
      }

      debugPrint(
          '❌ Failed to load prescriptions: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load prescriptions: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error getting prescriptions: $e');
      throw Exception('Error getting prescriptions: $e');
    }
  }

  Future<Prescription> getPrescription(String id) async {
    try {
      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return Prescription.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to load prescription');
    } catch (e) {
      throw Exception('Error getting prescription: $e');
    }
  }

  Future<String> generatePrescriptionPdf(String prescriptionId) async {
    try {
      final url = '$baseUrl/$prescriptionId/pdf';
      debugPrint('🌐 Generating PDF from: $url');

      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final pdfUrl = jsonData['pdfUrl'] as String;
        debugPrint('✅ PDF generated successfully: $pdfUrl');
        return pdfUrl;
      }

      debugPrint(
          '❌ Failed to generate PDF: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to generate prescription PDF');
    } catch (e) {
      debugPrint('❌ Error generating PDF: $e');
      throw Exception('Error generating prescription PDF: $e');
    }
  }

  Future<Prescription> createPrescription(
      Map<String, dynamic> prescriptionData) async {
    try {
      debugPrint('🌐 Creating prescription at: $baseUrl');
      debugPrint('📦 Request body: ${json.encode(prescriptionData)}');

      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: json.encode(prescriptionData),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        final prescription = Prescription.fromJson(jsonData);
        debugPrint(
            '✅ Prescription created successfully with ID: ${prescription.id}');
        return prescription;
      }

      debugPrint(
          '❌ Failed to create prescription: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to create prescription');
    } catch (e) {
      debugPrint('❌ Error creating prescription: $e');
      throw Exception('Error creating prescription: $e');
    }
  }

  Future<Prescription> updatePrescription(
      String id, Map<String, dynamic> updates) async {
    try {
      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Prescription.fromJson(jsonData);
      }
      throw Exception('Failed to update prescription');
    } catch (e) {
      throw Exception('Error updating prescription: $e');
    }
  }

  Future<void> deletePrescription(String id) async {
    try {
      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete prescription');
      }
    } catch (e) {
      throw Exception('Error deleting prescription: $e');
    }
  }
}
