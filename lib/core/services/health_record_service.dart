import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config.dart';
import '../../models/health_record.dart';

class HealthRecordService {
  final String authToken;

  HealthRecordService(this.authToken);

  Future<List<HealthRecord>> getHealthRecords(String? familyMemberId) async {
    final url = familyMemberId != null
        ? '${AppConfig.apiBaseUrl}/health-records?familyMemberId=$familyMemberId'
        : '${AppConfig.apiBaseUrl}/health-records';

    developer.log('🔍 HealthRecordService: Making GET request to $url',
        name: 'HealthRecordService');
    developer.log(
        '🔍 HealthRecordService: Auth token: ${authToken.substring(0, 10)}...',
        name: 'HealthRecordService');
    developer.log('🔍 HealthRecordService: Family member ID: $familyMemberId',
        name: 'HealthRecordService');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      developer.log(
          '🔍 HealthRecordService: Response status: ${response.statusCode}',
          name: 'HealthRecordService');
      developer.log(
          '🔍 HealthRecordService: Response headers: ${response.headers}',
          name: 'HealthRecordService');
      developer.log('🔍 HealthRecordService: Response body: ${response.body}',
          name: 'HealthRecordService');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        developer.log(
            '🔍 HealthRecordService: Parsed data length: ${data.length}',
            name: 'HealthRecordService');
        developer.log('🔍 HealthRecordService: Parsed data: $data',
            name: 'HealthRecordService');

        final records =
            data.map((json) => HealthRecord.fromJson(json)).toList();
        developer.log(
            '🔍 HealthRecordService: Created ${records.length} HealthRecord objects',
            name: 'HealthRecordService');
        return records;
      } else {
        developer.log(
            '❌ HealthRecordService: API error - Status: ${response.statusCode}, Body: ${response.body}',
            name: 'HealthRecordService');
        throw Exception(
            'Failed to load health records: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('❌ HealthRecordService: Exception occurred: $e',
          name: 'HealthRecordService');
      rethrow;
    }
  }

  Future<HealthRecord> addHealthRecord(HealthRecord record) async {
    final url = '${AppConfig.apiBaseUrl}/health-records';
    final requestBody = record.toJson();

    developer.log('🔍 HealthRecordService: ===== POST REQUEST START =====',
        name: 'HealthRecordService');
    developer.log('🔍 HealthRecordService: URL: $url',
        name: 'HealthRecordService');
    developer.log('🔍 HealthRecordService: Method: POST',
        name: 'HealthRecordService');
    developer.log(
        '🔍 HealthRecordService: Auth Token: ${authToken.substring(0, 20)}...',
        name: 'HealthRecordService');
    developer.log(
        '🔍 HealthRecordService: Request Headers: {"Authorization": "Bearer ***", "Content-Type": "application/json"}',
        name: 'HealthRecordService');
    developer.log(
        '🔍 HealthRecordService: Request Body: ${json.encode(requestBody)}',
        name: 'HealthRecordService');
    developer.log('🔍 HealthRecordService: Record Type: ${record.recordType}',
        name: 'HealthRecordService');
    developer.log('🔍 HealthRecordService: Patient ID: ${record.patientId}',
        name: 'HealthRecordService');
    developer.log('🔍 HealthRecordService: Title: ${record.title}',
        name: 'HealthRecordService');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      developer.log(
          '🔍 HealthRecordService: ===== POST RESPONSE RECEIVED =====',
          name: 'HealthRecordService');
      developer.log(
          '🔍 HealthRecordService: Response Status Code: ${response.statusCode}',
          name: 'HealthRecordService');
      developer.log(
          '🔍 HealthRecordService: Response Headers: ${response.headers}',
          name: 'HealthRecordService');
      developer.log('🔍 HealthRecordService: Response Body: ${response.body}',
          name: 'HealthRecordService');
      developer.log(
          '🔍 HealthRecordService: Response Body Length: ${response.body.length}',
          name: 'HealthRecordService');

      if (response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          developer.log('🔍 HealthRecordService: ✅ SUCCESS - Record created!',
              name: 'HealthRecordService');
          developer.log(
              '🔍 HealthRecordService: Created Record ID: ${responseData['_id']}',
              name: 'HealthRecordService');
          developer.log(
              '🔍 HealthRecordService: Created Record Data: $responseData',
              name: 'HealthRecordService');

          final createdRecord = HealthRecord.fromJson(responseData);
          developer.log(
              '🔍 HealthRecordService: Parsed HealthRecord object: ${createdRecord.title} (${createdRecord.id})',
              name: 'HealthRecordService');
          developer.log('🔍 HealthRecordService: ===== POST REQUEST END =====',
              name: 'HealthRecordService');

          return createdRecord;
        } catch (parseError) {
          developer.log('❌ HealthRecordService: JSON Parse Error: $parseError',
              name: 'HealthRecordService');
          developer.log(
              '❌ HealthRecordService: Raw Response Body: ${response.body}',
              name: 'HealthRecordService');
          throw Exception('Failed to parse response: $parseError');
        }
      } else {
        developer.log('❌ HealthRecordService: ===== POST REQUEST FAILED =====',
            name: 'HealthRecordService');
        developer.log(
            '❌ HealthRecordService: Error Status: ${response.statusCode}',
            name: 'HealthRecordService');
        developer.log('❌ HealthRecordService: Error Body: ${response.body}',
            name: 'HealthRecordService');

        // Try to parse error response
        try {
          final errorData = json.decode(response.body);
          developer.log('❌ HealthRecordService: Parsed Error: $errorData',
              name: 'HealthRecordService');
        } catch (e) {
          developer.log('❌ HealthRecordService: Could not parse error response',
              name: 'HealthRecordService');
        }

        throw Exception(
            'Failed to add health record: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('❌ HealthRecordService: ===== POST REQUEST EXCEPTION =====',
          name: 'HealthRecordService');
      developer.log('❌ HealthRecordService: Exception Type: ${e.runtimeType}',
          name: 'HealthRecordService');
      developer.log('❌ HealthRecordService: Exception Message: $e',
          name: 'HealthRecordService');
      developer.log('❌ HealthRecordService: ===== POST REQUEST END =====',
          name: 'HealthRecordService');
      rethrow;
    }
  }

  Future<void> deleteHealthRecord(String id) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.apiBaseUrl}/health-records/$id'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete health record');
    }
  }

  Future<void> updateHealthRecord(HealthRecord record) async {
    final response = await http.put(
      Uri.parse('${AppConfig.apiBaseUrl}/health-records/${record.id}'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(record.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update health record');
    }
  }

  Future<List<VitalSigns>> getVitalSigns(String familyMemberId) async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.apiBaseUrl}/health-records?familyMemberId=$familyMemberId&recordType=medical_history'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .where((record) => record['medicalHistory'] != null)
          .map((json) => VitalSigns.fromJson(json['medicalHistory']))
          .toList();
    } else {
      throw Exception('Failed to load vital signs');
    }
  }

  Future<List<LabResult>> getLabResults(String familyMemberId) async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.apiBaseUrl}/health-records?familyMemberId=$familyMemberId&recordType=lab_results'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .where((record) => record['labResults'] != null)
          .map((json) => LabResult.fromJson(json['labResults']))
          .toList();
    } else {
      throw Exception('Failed to load lab results');
    }
  }

  Future<List<HealthRecord>> getRecordsByType(
      String familyMemberId, String recordType) async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.apiBaseUrl}/health-records?familyMemberId=$familyMemberId&recordType=$recordType'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => HealthRecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load records by type');
    }
  }
}
