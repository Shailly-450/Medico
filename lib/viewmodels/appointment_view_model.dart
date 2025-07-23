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
  String? _errorMessage;
  Map<String, dynamic>? _pagination;

  // Getters
  List<Appointment> get appointments => _appointments;
  List<Appointment> get upcomingAppointments => _upcomingAppointments;
  List<Appointment> get completedAppointments => _completedAppointments;
  List<Appointment> get cancelledAppointments => _cancelledAppointments;
  Appointment? get selectedAppointment => _selectedAppointment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get pagination => _pagination;

  // Initialize the view model
  Future<void> initialize() async {
    await AuthService.initialize();
    await loadAppointments();
  }

  // Load all appointments with API filters
  Future<void> loadAppointments({
    int page = 1,
    int limit = 10,
    String? status,
    String? sortBy,
    String? sortOrder,
    String? doctorId,
    String? hospitalId,
    String? search,
  }) async {
    setBusy(true);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AppointmentService.getAppointments(
        page: page,
        limit: limit,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
        doctorId: doctorId,
        hospitalId: hospitalId,
        search: search,
      );
      if (result['success'] == true) {
        _appointments = (result['data'] as List<Appointment>?) ?? [];
        _pagination = result['pagination'];
        _categorizeAppointments();
      } else {
        _errorMessage = result['message'] ?? 'Failed to load appointments';
        _appointments = [];
        _pagination = null;
        _upcomingAppointments = [];
        _completedAppointments = [];
        _cancelledAppointments = [];
      }
    } catch (e) {
      _errorMessage = 'Error loading appointments: $e';
      _appointments = [];
      _pagination = null;
      _upcomingAppointments = [];
      _completedAppointments = [];
      _cancelledAppointments = [];
    } finally {
      setBusy(false);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Categorize appointments by status
  void _categorizeAppointments() {
    // Debug: print all appointments
    print('All appointments:');
    for (final a in _appointments) {
      print('UI: ${a.doctorName} on ${a.date} status: ${a.status}');
    }
    _upcomingAppointments = _appointments.where((appointment) {
      final status = appointment.status.toLowerCase();
      return status == 'upcoming' || status == 'scheduled';
    }).toList();
    _completedAppointments = _appointments.where((appointment) {
      return appointment.status.toLowerCase() == 'completed';
    }).toList();
    _cancelledAppointments = _appointments.where((appointment) {
      return appointment.status.toLowerCase() == 'cancelled';
    }).toList();
    print('Filtered (upcoming): ${_upcomingAppointments.length}');
    print('Filtered (completed): ${_completedAppointments.length}');
    print('Filtered (cancelled): ${_cancelledAppointments.length}');
  }

  // Parse appointment date and time
  DateTime _parseAppointmentDateTime(Appointment appointment) {
    try {
      return DateTime.parse(appointment.date);
    } catch (e) {
      return DateTime.now();
    }
  }

  // Create new appointment
  Future<bool> createAppointment({
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
        await loadAppointments();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to create appointment';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error creating appointment: $e';
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
        _selectedAppointment = result['data'] as Appointment;
        notifyListeners();
        return _selectedAppointment;
      } else {
        _errorMessage = result['message'] ?? 'Failed to get appointment';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error getting appointment: $e';
      return null;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Update appointment
  Future<bool> updateAppointment({
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
    setBusy(true);
    notifyListeners();
    try {
      final result = await AppointmentService.updateAppointment(
        appointmentId: appointmentId,
        appointmentDate: appointmentDate,
        appointmentType: appointmentType,
        reason: reason,
        symptoms: symptoms,
        insuranceProvider: insuranceProvider,
        insuranceNumber: insuranceNumber,
        preferredTimeSlot: preferredTimeSlot,
        notes: notes,
        status: status,
      );
      if (result['success'] == true) {
        await loadAppointments();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update appointment';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating appointment: $e';
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
        await loadAppointments();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to cancel appointment';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error cancelling appointment: $e';
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Submit pre-approval
  Future<bool> submitPreApproval({
    required String appointmentId,
    required String insuranceProvider,
    required String insuranceNumber,
    required String diagnosis,
    required String treatmentPlan,
    required num estimatedCost,
    required List<Map<String, dynamic>> documents,
  }) async {
    setBusy(true);
    notifyListeners();
    try {
      final result = await AppointmentService.submitPreApproval(
        appointmentId: appointmentId,
        insuranceProvider: insuranceProvider,
        insuranceNumber: insuranceNumber,
        diagnosis: diagnosis,
        treatmentPlan: treatmentPlan,
        estimatedCost: estimatedCost,
        documents: documents,
      );
      if (result['success'] == true) {
        await loadAppointments();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to submit pre-approval';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error submitting pre-approval: $e';
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
    return appointmentDateTime.isAfter(now) && appointment.status != 'cancelled';
  }

  // Check if appointment is completed
  bool isAppointmentCompleted(Appointment appointment) {
    final now = DateTime.now();
    final appointmentDateTime = _parseAppointmentDateTime(appointment);
    return appointmentDateTime.isBefore(now) && appointment.status != 'cancelled';
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