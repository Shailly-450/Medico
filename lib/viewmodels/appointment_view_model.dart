import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../core/services/appointment_service.dart';
import '../core/services/auth_service.dart';
import '../core/viewmodels/base_view_model.dart';

class AppointmentViewModel extends BaseViewModel {
  List<Appointment> _appointments = [];
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _completedAppointments = [];
  List<Appointment> _cancelledAppointments = [];
  Appointment? _selectedAppointment;
  bool _isLoading = false;

  // Getters
  List<Appointment> get appointments => _appointments;
  List<Appointment> get upcomingAppointments => _upcomingAppointments;
  List<Appointment> get completedAppointments => _completedAppointments;
  List<Appointment> get cancelledAppointments => _cancelledAppointments;
  Appointment? get selectedAppointment => _selectedAppointment;
  bool get isLoading => _isLoading;

  // Initialize the view model
  Future<void> initialize() async {
    await AuthService.initialize();
    await loadAppointments();
  }

  // Load all appointments
  Future<void> loadAppointments({bool includeCancelled = false}) async {
    setBusy(true);
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AppointmentService.getAppointments(
          includeCancelled: includeCancelled);

      if (result['success'] == true) {
        final List<dynamic> appointmentsData = result['data'] ?? [];
        _appointments =
            appointmentsData.map((json) => Appointment.fromJson(json)).toList();

        _categorizeAppointments();
      } else {
        // Handle error - could show snackbar or dialog
        print('Failed to load appointments: ${result['message']}');
      }
    } catch (e) {
      print('Error loading appointments: $e');
    } finally {
      setBusy(false);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Categorize appointments by status
  void _categorizeAppointments() {
    final now = DateTime.now();

    _upcomingAppointments = _appointments.where((appointment) {
      final appointmentDateTime = _parseAppointmentDateTime(appointment);
      return appointmentDateTime.isAfter(now) &&
          appointment.status != 'cancelled';
    }).toList();

    _completedAppointments = _appointments.where((appointment) {
      final appointmentDateTime = _parseAppointmentDateTime(appointment);
      return appointmentDateTime.isBefore(now) &&
          appointment.status != 'cancelled';
    }).toList();

    _cancelledAppointments = _appointments.where((appointment) {
      return appointment.status == 'cancelled';
    }).toList();
  }

  // Parse appointment date and time
  DateTime _parseAppointmentDateTime(Appointment appointment) {
    try {
      final dateParts = appointment.date.split('-');
      final timeParts = appointment.time.split(':');

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      // Handle AM/PM if present
      if (appointment.time.toLowerCase().contains('pm') && hour != 12) {
        hour += 12;
      } else if (appointment.time.toLowerCase().contains('am') && hour == 12) {
        hour = 0;
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return DateTime.now();
    }
  }

  // Create new appointment
  Future<bool> createAppointment({
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
    setBusy(true);
    notifyListeners();

    try {
      final result = await AppointmentService.createAppointment(
        doctorId: doctorId,
        hospitalId: hospitalId,
        appointmentDate: appointmentDate,
        appointmentType: appointmentType,
        reason: reason,
        symptoms: symptoms,
        insuranceProvider: insuranceProvider,
        insuranceNumber: insuranceNumber,
        preferredTimeSlot: preferredTimeSlot,
        notes: notes,
      );

      if (result['success'] == true) {
        // Reload appointments to get the updated list
        await loadAppointments();
        return true;
      } else {
        print('Failed to create appointment: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('Error creating appointment: $e');
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Get appointment by ID
  Future<Appointment?> getAppointmentById(String appointmentId) async {
    setBusy(true);
    notifyListeners();

    try {
      final result = await AppointmentService.getAppointmentById(appointmentId);

      if (result['success'] == true && result['data'] != null) {
        _selectedAppointment = Appointment.fromJson(result['data']);
        notifyListeners();
        return _selectedAppointment;
      } else {
        print('Failed to get appointment: ${result['message']}');
        return null;
      }
    } catch (e) {
      print('Error getting appointment: $e');
      return null;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Update appointment
  Future<bool> updateAppointment({
    required String appointmentId,
    DateTime? date,
    String? time,
    String? reason,
    String? status,
  }) async {
    setBusy(true);
    notifyListeners();

    try {
      final result = await AppointmentService.updateAppointment(
        appointmentId: appointmentId,
        date: date,
        time: time,
        reason: reason,
        status: status,
      );

      if (result['success'] == true) {
        // Reload appointments to get the updated list
        await loadAppointments();
        return true;
      } else {
        print('Failed to update appointment: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('Error updating appointment: $e');
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Cancel appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    setBusy(true);
    notifyListeners();

    try {
      final result = await AppointmentService.cancelAppointment(appointmentId);

      if (result['success'] == true) {
        // Reload appointments to get the updated list
        await loadAppointments();
        return true;
      } else {
        print('Failed to cancel appointment: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('Error cancelling appointment: $e');
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Delete appointment
  Future<bool> deleteAppointment(String appointmentId) async {
    setBusy(true);
    notifyListeners();

    try {
      final result = await AppointmentService.deleteAppointment(appointmentId);

      if (result['success'] == true) {
        // Reload appointments to get the updated list
        await loadAppointments();
        return true;
      } else {
        print('Failed to delete appointment: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('Error deleting appointment: $e');
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Submit pre-approval
  Future<bool> submitPreApproval({
    required String appointmentId,
    required List<String> symptoms,
    String? medicalHistory,
  }) async {
    setBusy(true);
    notifyListeners();

    try {
      final result = await AppointmentService.submitPreApproval(
        appointmentId: appointmentId,
        symptoms: symptoms,
        medicalHistory: medicalHistory,
      );

      if (result['success'] == true) {
        // Reload appointments to get the updated list
        await loadAppointments();
        return true;
      } else {
        print('Failed to submit pre-approval: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('Error submitting pre-approval: $e');
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Set selected appointment
  void setSelectedAppointment(Appointment appointment) {
    _selectedAppointment = appointment;
    notifyListeners();
  }

  // Clear selected appointment
  void clearSelectedAppointment() {
    _selectedAppointment = null;
    notifyListeners();
  }

  // Get appointments by status
  List<Appointment> getAppointmentsByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return _upcomingAppointments;
      case 'completed':
        return _completedAppointments;
      case 'cancelled':
        return _cancelledAppointments;
      default:
        return _appointments;
    }
  }

  // Check if appointment is today
  bool isAppointmentToday(Appointment appointment) {
    final today = DateTime.now();
    final appointmentDate = _parseAppointmentDateTime(appointment);
    return appointmentDate.year == today.year &&
        appointmentDate.month == today.month &&
        appointmentDate.day == today.day;
  }

  // Check if appointment is upcoming
  bool isAppointmentUpcoming(Appointment appointment) {
    final now = DateTime.now();
    final appointmentDateTime = _parseAppointmentDateTime(appointment);
    return appointmentDateTime.isAfter(now) &&
        appointment.status != 'cancelled';
  }

  // Check if appointment is completed
  bool isAppointmentCompleted(Appointment appointment) {
    final now = DateTime.now();
    final appointmentDateTime = _parseAppointmentDateTime(appointment);
    return appointmentDateTime.isBefore(now) &&
        appointment.status != 'cancelled';
  }

  // Get appointment status display text
  String getAppointmentStatusDisplay(Appointment appointment) {
    switch (appointment.status.toLowerCase()) {
      case 'scheduled':
        return 'Scheduled';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no-show':
        return 'No Show';
      default:
        return appointment.status;
    }
  }

  // Get appointment status color
  Color getAppointmentStatusColor(Appointment appointment) {
    switch (appointment.status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      case 'no-show':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
