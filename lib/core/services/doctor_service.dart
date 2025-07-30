import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/doctor.dart';
import '../config.dart';

class DoctorService {
  static const String _endpoint = '/api/doctors';
  String get baseUrl => '${AppConfig.apiBaseUrl}$_endpoint';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Get all doctors with optional filtering, sorting, and pagination
  Future<Map<String, dynamic>> getDoctors({
    String? specialty,
    int? limit,
    int? page,
    String? sort,
    String? search,
  }) async {
    try {
      debugPrint('🌐 Fetching doctors from: $baseUrl');

      // Build query parameters
      final queryParams = <String, String>{};
      if (specialty != null) queryParams['specialty'] = specialty;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (sort != null) queryParams['sort'] = sort;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      debugPrint('🔗 Request URL: $uri');

      final response = await http.get(
        uri,
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('📦 Response structure: $responseData');

        if (responseData.containsKey('success') && responseData['success'] == true) {
          final List<dynamic> doctorsData = responseData['data'] ?? [];
          final List<Doctor> doctors = doctorsData
              .map((json) => Doctor.fromJson(json))
              .toList();

          debugPrint('✅ Successfully fetched ${doctors.length} doctors');
          return {
            'success': true,
            'data': doctors,
            'pagination': responseData['pagination'],
            'filters': responseData['filters'],
          };
        } else {
          debugPrint('❌ API returned success: false');
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch doctors',
            'data': [],
          };
        }
      }

      debugPrint('❌ Failed to fetch doctors: ${response.statusCode} - ${response.body}');
      return {
        'success': false,
        'message': 'Failed to fetch doctors: ${response.statusCode}',
        'data': [],
      };
    } catch (e) {
      debugPrint('❌ Error fetching doctors: $e');
      return {
        'success': false,
        'message': 'Error fetching doctors: $e',
        'data': [],
      };
    }
  }

  // Get single doctor by ID
  Future<Map<String, dynamic>> getDoctorById(String doctorId) async {
    try {
      debugPrint('🌐 Fetching doctor details from: $baseUrl/$doctorId');

      final response = await http.get(
        Uri.parse('$baseUrl/$doctorId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('📦 Response structure: $responseData');

        if (responseData.containsKey('success') && responseData['success'] == true) {
          final doctorData = responseData['data'];
          final doctor = Doctor.fromJson(doctorData);

          debugPrint('✅ Successfully fetched doctor: ${doctor.name}');
          return {
            'success': true,
            'data': doctor,
          };
        } else {
          debugPrint('❌ API returned success: false');
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch doctor',
          };
        }
      }

      debugPrint('❌ Failed to fetch doctor: ${response.statusCode} - ${response.body}');
      return {
        'success': false,
        'message': 'Failed to fetch doctor: ${response.statusCode}',
      };
    } catch (e) {
      debugPrint('❌ Error fetching doctor: $e');
      return {
        'success': false,
        'message': 'Error fetching doctor: $e',
      };
    }
  }

  // Get doctors by specialty
  Future<Map<String, dynamic>> getDoctorsBySpecialty(String specialty) async {
    return await getDoctors(specialty: specialty);
  }

  // Get top-rated doctors
  Future<Map<String, dynamic>> getTopRatedDoctors({int limit = 10}) async {
    return await getDoctors(sort: 'rating', limit: limit);
  }

  // Search doctors
  Future<Map<String, dynamic>> searchDoctors(String searchTerm) async {
    return await getDoctors(search: searchTerm);
  }

  // Get doctors with pagination
  Future<Map<String, dynamic>> getDoctorsWithPagination({
    int page = 1,
    int limit = 20,
  }) async {
    return await getDoctors(page: page, limit: limit);
  }

  // Get doctors sorted by experience
  Future<Map<String, dynamic>> getDoctorsByExperience({int limit = 10}) async {
    return await getDoctors(sort: 'experience', limit: limit);
  }

  // Get doctors sorted by consultation fee (lowest first)
  Future<Map<String, dynamic>> getDoctorsByFeeLow({int limit = 10}) async {
    return await getDoctors(sort: 'fee_low', limit: limit);
  }

  // Get doctors sorted by consultation fee (highest first)
  Future<Map<String, dynamic>> getDoctorsByFeeHigh({int limit = 10}) async {
    return await getDoctors(sort: 'fee_high', limit: limit);
  }

  // Get doctors sorted by name (alphabetical)
  Future<Map<String, dynamic>> getDoctorsByName({int limit = 10}) async {
    return await getDoctors(sort: 'name', limit: limit);
  }
} 