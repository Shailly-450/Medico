import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';
import '../../models/appointment.dart';

class AppointmentService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 30);

  /// Fetch all appointments with support for pagination, status, sorting, and filtering.
  /// Returns a map with keys: success, message, data (List<Appointment>), pagination (if available).
  static Future<Map<String, dynamic>> getAppointments({
    int page = 1,
    int limit = 10,
    String? status, // e.g., 'upcoming', 'completed', etc.
    String? sortBy, // e.g., 'appointmentDate'
    String? sortOrder, // 'asc' or 'desc'
    String? doctorId,
    String? hospitalId,
    String? search,
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
      };
      if (status != null) queryParams['status'] = status;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
      if (doctorId != null) queryParams['doctorId'] = doctorId;
      if (hospitalId != null) queryParams['hospitalId'] = hospitalId;
      if (search != null) queryParams['search'] = search;
      final uri = Uri.parse('$baseUrl/appointments').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);
      print('Appointments API response: \n${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('data[\'data\'] type:  [33m${data['data']?.runtimeType} [0m');
        print('data[\'data\'] value: ${data['data']}');
        List<Appointment> appointments = [];
        try {
          appointments = (data['data'] as List?)?.map((e) {
            try {
              final appt = Appointment.fromJson(e);
              return appt;
            } catch (err, stack) {
              print('Error mapping appointment: $err\n$stack');
              print('Raw data: $e');
              return null;
            }
          }).whereType<Appointment>().toList() ?? [];
        } catch (e, stack) {
          print('Error in getAppointments: $e\n$stack');
          print('data[\'data\']: ${data['data']}');
        }
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Appointments fetched',
          'data': appointments,
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch appointments: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch appointments: ${e.toString()}',
      };
    }
  }

  /// Create a new appointment. Returns a map with keys: success, message, data (Appointment).
  static Future<Map<String, dynamic>> createAppointment({
    required String doctorId,
    required String hospitalId,
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
      final response = await http.post(
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
      ).timeout(timeout);
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Appointment created',
          'data': data['data'] != null ? Appointment.fromJson(data['data']) : null,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create appointment: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create appointment: ${e.toString()}',
      };
    }
  }

  /// Get appointment by ID. Returns a map with keys: success, message, data (Appointment).
  static Future<Map<String, dynamic>> getAppointmentById(String appointmentId) async {
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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Appointment fetched',
          'data': data['data'] != null ? Appointment.fromJson(data['data']) : null,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch appointment: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch appointment: ${e.toString()}',
      };
    }
  }

  /// Update appointment. Returns a map with keys: success, message, data (Appointment).
  static Future<Map<String, dynamic>> updateAppointment({
    required String appointmentId,
    DateTime? appointmentDate,
    String? appointmentType,
    String? reason,
    List<String>? symptoms,
    String? insuranceProvider,
    String? insuranceNumber,
    String? preferredTimeSlot,
    String? notes,
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
      if (appointmentDate != null) updateData['appointmentDate'] = appointmentDate.toIso8601String();
      if (appointmentType != null) updateData['appointmentType'] = appointmentType;
      if (reason != null) updateData['reason'] = reason;
      if (symptoms != null) updateData['symptoms'] = symptoms;
      if (insuranceProvider != null) updateData['insuranceProvider'] = insuranceProvider;
      if (insuranceNumber != null) updateData['insuranceNumber'] = insuranceNumber;
      if (preferredTimeSlot != null) updateData['preferredTimeSlot'] = preferredTimeSlot;
      if (notes != null) updateData['notes'] = notes;
      if (status != null) updateData['status'] = status;
      final response = await http.put(
        Uri.parse('$baseUrl/appointments/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      ).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Appointment updated',
          'data': data['data'] != null ? Appointment.fromJson(data['data']) : null,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update appointment: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update appointment: ${e.toString()}',
      };
    }
  }

  /// Cancel appointment (DELETE). Returns a map with keys: success, message.
  static Future<Map<String, dynamic>> cancelAppointment(String appointmentId) async {
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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Appointment cancelled',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to cancel appointment: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to cancel appointment: ${e.toString()}',
      };
    }
  }

  /// Submit pre-approval for an appointment. Returns a map with keys: success, message.
  static Future<Map<String, dynamic>> submitPreApproval({
    required String appointmentId,
    required String insuranceProvider,
    required String insuranceNumber,
    required String diagnosis,
    required String treatmentPlan,
    required num estimatedCost,
    required List<Map<String, dynamic>> documents, // [{type, url, name}]
  }) async {
    try {
      final token = AuthService.accessToken;
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }
      final response = await http.post(
        Uri.parse('$baseUrl/appointments/$appointmentId/pre-approval'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'insuranceProvider': insuranceProvider,
          'insuranceNumber': insuranceNumber,
          'diagnosis': diagnosis,
          'treatmentPlan': treatmentPlan,
          'estimatedCost': estimatedCost,
          'documents': documents,
        }),
      ).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Pre-approval submitted',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to submit pre-approval: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to submit pre-approval: ${e.toString()}',
      };
    }
  }
} 