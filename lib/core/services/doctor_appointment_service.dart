import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';
import '../../models/appointment.dart';

class DoctorAppointmentService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 30);

  // Get appointments for the current doctor
  static Future<Map<String, dynamic>> getDoctorAppointments({
    int page = 1,
    int limit = 10,
    String? status,
    String? preApprovalStatus,
  }) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'doctorId': AuthService.currentUserId ?? '',
      };

      if (status != null) queryParams['status'] = status;
      if (preApprovalStatus != null)
        queryParams['preApprovalStatus'] = preApprovalStatus;

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint =
          '/appointments${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      // Debug: Print API response
      print(
          '🔍 DoctorAppointmentService.getDoctorAppointments - API Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Parsed Data: $data');

      if (data['success'] == true && data['data'] != null) {
        final appointments = (data['data'] as List)
            .map((json) => Appointment.fromJson(json))
            .toList();

        print('✅ Parsed ${appointments.length} appointments successfully');

        return {
          'success': true,
          'message': data['message'] ?? 'Appointments fetched successfully',
          'data': appointments,
          'total': data['total'] ?? appointments.length,
          'page': data['page'] ?? page,
          'limit': data['limit'] ?? limit,
        };
      }

      print('❌ API returned success: false or no data');
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch appointments',
        'data': [],
      };
    } catch (e) {
      print(
          '❌ DoctorAppointmentService.getDoctorAppointments - Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Failed to fetch appointments: ${e.toString()}',
        'data': [],
      };
    }
  }

  // Update appointment status (approve/reject)
  static Future<Map<String, dynamic>> updateAppointmentStatus(
      String appointmentId, String status, // 'approved' or 'rejected'
      {String? notes}) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final updateData = {
        'preApprovalStatus': status,
        if (notes != null) 'notes': notes,
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/appointments/$appointmentId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(updateData),
          )
          .timeout(timeout);

      final data = jsonDecode(response.body);

      // Debug: Print API response
      print(
          '🔍 DoctorAppointmentService.updateAppointmentStatus - API Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Parsed Data: $data');

      if (data['success'] == true && data['data'] != null) {
        final appointment = Appointment.fromJson(data['data']);
        print('✅ Appointment status updated successfully');
        return {
          'success': true,
          'message':
              data['message'] ?? 'Appointment status updated successfully',
          'data': appointment,
        };
      }

      print('❌ Failed to update appointment status');
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update appointment status',
      };
    } catch (e) {
      print(
          '❌ DoctorAppointmentService.updateAppointmentStatus - Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Failed to update appointment status: ${e.toString()}',
      };
    }
  }

  // Get appointment by ID
  static Future<Map<String, dynamic>> getAppointmentById(
      String appointmentId) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/appointments/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      // Debug: Print API response
      print('🔍 DoctorAppointmentService.getAppointmentById - API Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Parsed Data: $data');

      if (data['success'] == true && data['data'] != null) {
        final appointment = Appointment.fromJson(data['data']);
        print('✅ Appointment fetched successfully');
        return {
          'success': true,
          'message': data['message'] ?? 'Appointment fetched successfully',
          'data': appointment,
        };
      }

      print('❌ Failed to fetch appointment');
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch appointment',
      };
    } catch (e) {
      print(
          '❌ DoctorAppointmentService.getAppointmentById - Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Failed to fetch appointment: ${e.toString()}',
      };
    }
  }

  // Get today's appointments for the doctor
  static Future<Map<String, dynamic>> getTodayAppointments() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      return await getDoctorAppointments(
        status: 'scheduled',
        preApprovalStatus: 'approved',
      );
    } catch (e) {
      print(
          '❌ DoctorAppointmentService.getTodayAppointments - Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Failed to fetch today\'s appointments: ${e.toString()}',
        'data': [],
      };
    }
  }

  // Get pending approval appointments
  static Future<Map<String, dynamic>> getPendingApprovalAppointments() async {
    try {
      return await getDoctorAppointments(
        preApprovalStatus: 'pending',
      );
    } catch (e) {
      print(
          '❌ DoctorAppointmentService.getPendingApprovalAppointments - Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Failed to fetch pending appointments: ${e.toString()}',
        'data': [],
      };
    }
  }
}
