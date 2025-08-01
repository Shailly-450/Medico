import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../core/services/doctor_appointment_service.dart';
import '../core/viewmodels/base_view_model.dart';

class DoctorAppointmentViewModel extends BaseViewModel {
  List<Appointment> _appointments = [];
  String _selectedFilter = 'all';
  String _errorMessage = '';

  List<Appointment> get appointments => _appointments;
  String get selectedFilter => _selectedFilter;
  String get errorMessage => _errorMessage;

  // Get today's date in YYYY-MM-DD format
  String get todayDate => DateTime.now().toIso8601String().split('T')[0];

  // Computed properties for statistics
  int get todayAppointmentsCount => _appointments
      .where((a) => a.date == todayDate && a.preApprovalStatus == 'approved')
      .length;

  int get pendingAppointmentsCount =>
      _appointments.where((a) => a.preApprovalStatus == 'pending').length;

  int get totalAppointmentsCount => _appointments.length;

  List<Appointment> get todayAppointments => _appointments
      .where((a) => a.date == todayDate && a.preApprovalStatus == 'approved')
      .toList();

  List<Appointment> get pendingAppointments =>
      _appointments.where((a) => a.preApprovalStatus == 'pending').toList();

  // Load appointments based on current filter
  Future<void> loadAppointments() async {
    print(
        '🔄 DoctorAppointmentViewModel.loadAppointments - Starting with filter: $_selectedFilter');
    setBusy(true);
    _errorMessage = '';

    try {
      Map<String, dynamic> result;

      switch (_selectedFilter) {
        case 'pending':
          print('📋 Loading pending appointments...');
          result =
              await DoctorAppointmentService.getPendingApprovalAppointments();
          break;
        case 'today':
          print('📅 Loading today\'s appointments...');
          result = await DoctorAppointmentService.getTodayAppointments();
          break;
        default:
          print('📋 Loading all appointments...');
          result = await DoctorAppointmentService.getDoctorAppointments();
      }

      print('📊 API Result: ${result['success']} - ${result['message']}');
      print('📊 Appointments count: ${result['data']?.length ?? 0}');

      if (result['success'] == true) {
        _appointments = List<Appointment>.from(result['data'] ?? []);
        print('✅ Loaded ${_appointments.length} appointments successfully');
        notifyListeners();
      } else {
        _errorMessage = result['message'] ?? 'Failed to load appointments';
        print('❌ Failed to load appointments: $_errorMessage');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error loading appointments: ${e.toString()}';
      print('❌ Exception in loadAppointments: $_errorMessage');
      notifyListeners();
    } finally {
      setBusy(false);
      print('🔄 DoctorAppointmentViewModel.loadAppointments - Completed');
    }
  }

  // Update filter and reload appointments
  Future<void> setFilter(String filter) async {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      await loadAppointments();
    }
  }

  // Update appointment status (approve/reject)
  Future<bool> updateAppointmentStatus(
      String appointmentId, String status) async {
    print(
        '🔄 DoctorAppointmentViewModel.updateAppointmentStatus - Updating appointment $appointmentId to $status');
    setBusy(true);

    try {
      final result = await DoctorAppointmentService.updateAppointmentStatus(
        appointmentId,
        status,
      );

      print('📊 Update Result: ${result['success']} - ${result['message']}');

      if (result['success'] == true) {
        print('✅ Appointment updated successfully, refreshing list...');
        // Refresh the appointments list
        await loadAppointments();
        setBusy(false);
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update appointment';
        print('❌ Failed to update appointment: $_errorMessage');
        setBusy(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating appointment: ${e.toString()}';
      print('❌ Exception in updateAppointmentStatus: $_errorMessage');
      setBusy(false);
      notifyListeners();
      return false;
    }
  }

  // Get appointment by ID
  Future<Appointment?> getAppointmentById(String appointmentId) async {
    try {
      final result =
          await DoctorAppointmentService.getAppointmentById(appointmentId);

      if (result['success'] == true) {
        return result['data'] as Appointment;
      } else {
        _errorMessage = result['message'] ?? 'Failed to fetch appointment';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error fetching appointment: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Get status color for UI
  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Get status text for UI
  String getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending Approval';
      default:
        return 'Unknown';
    }
  }
}
