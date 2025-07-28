import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class AppointmentService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 30);

  // Get all appointments for the authenticated user
  static Future<Map<String, dynamic>> getAppointments(
      {bool includeCancelled = false}) async {
    try {
      print('🌐 AppointmentService: Fetching appointments from API');
      final token = AuthService.accessToken;
      if (token == null) {
        print('❌ AppointmentService: Not authenticated');
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final queryParams = includeCancelled ? '?includeCancelled=true' : '';
      final url = '$baseUrl/appointments$queryParams';
      print('🌐 AppointmentService: Making GET request to $url');
      print('🔑 AppointmentService: Auth token: ${token.substring(0, 10)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      print('📥 AppointmentService: Response status: ${response.statusCode}');
      print('📦 AppointmentService: Response body: ${response.body}');

      final data = jsonDecode(response.body);
      final result = {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Failed to fetch appointments',
        'data': data['data'] ?? [],
      };

      print(
          '✅ AppointmentService: Parsed ${result['data'].length} appointments');
      return result;
    } catch (e) {
      print('❌ AppointmentService: Error fetching appointments: $e');
      return {
        'success': false,
        'message': 'Failed to fetch appointments: ${e.toString()}',
      };
    }
  }

  // Create new appointment
  static Future<Map<String, dynamic>> createAppointment({
    required String doctorId,
    String? hospitalId,
    required DateTime appointmentDate,
    required String appointmentType,
    String? reason,
    List<String>? symptoms,
    String? insuranceProvider,
    String? insuranceNumber,
    String? preferredTimeSlot,
    String? notes,
  }) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/appointments'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'doctorId': doctorId,
              'hospitalId': hospitalId,
              'appointmentDate': appointmentDate.toIso8601String(),
              'appointmentType': appointmentType,
              'reason': reason,
              'symptoms': symptoms,
              'insuranceProvider': insuranceProvider,
              'insuranceNumber': insuranceNumber,
              'preferredTimeSlot': preferredTimeSlot,
              'notes': notes,
            }),
          )
          .timeout(timeout);

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Failed to create appointment',
        'data': data['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create appointment: ${e.toString()}',
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
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Failed to fetch appointment',
        'data': data['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch appointment: ${e.toString()}',
      };
    }
  }

  // Update appointment
  static Future<Map<String, dynamic>> updateAppointment({
    required String appointmentId,
    DateTime? date,
    String? time,
    String? reason,
    String? status,
  }) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final updateData = <String, dynamic>{};
      if (date != null) updateData['date'] = date.toIso8601String();
      if (time != null) updateData['time'] = time;
      if (reason != null) updateData['reason'] = reason;
      if (status != null) updateData['status'] = status;

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
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Failed to update appointment',
        'data': data['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update appointment: ${e.toString()}',
      };
    }
  }

  // Cancel appointment
  static Future<Map<String, dynamic>> cancelAppointment(
      String appointmentId) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/appointments/$appointmentId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Failed to cancel appointment',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to cancel appointment: ${e.toString()}',
      };
    }
  }

  // Delete appointment
  static Future<Map<String, dynamic>> deleteAppointment(
      String appointmentId) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/appointments/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Failed to delete appointment',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete appointment: ${e.toString()}',
      };
    }
  }

  // Submit pre-approval
  static Future<Map<String, dynamic>> submitPreApproval({
    required String appointmentId,
    required List<String> symptoms,
    String? medicalHistory,
  }) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/appointments/$appointmentId/pre-approval'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'symptoms': symptoms,
              'medicalHistory': medicalHistory,
            }),
          )
          .timeout(timeout);

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Failed to submit pre-approval',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to submit pre-approval: ${e.toString()}',
      };
    }
  }
}
