import '../core/viewmodels/base_view_model.dart';
import '../models/appointment.dart';
import '../core/services/pre_approval_service.dart';
import '../core/services/appointment_service.dart';
import '../core/services/auth_service.dart';

class ScheduleViewModel extends BaseViewModel {
  String _selectedTab = 'My Booking';
  List<Appointment> _appointments = [];
  List<Appointment> _historyAppointments = [];
  final PreApprovalService _preApprovalService = PreApprovalService();

  String get selectedTab => _selectedTab;
  List<Appointment> get appointments =>
      _selectedTab == 'My Booking' ? _appointments : _historyAppointments;

  void setTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  Future<void> loadAppointments() async {
    print('ScheduleViewModel.loadAppointments() called');
    setBusy(true);

    try {
      // Initialize auth service
      await AuthService.initialize();

      // Fetch appointments from API
      final result =
          await AppointmentService.getAppointments(includeCancelled: false);

      if (result['success'] == true) {
        final List<dynamic> appointmentsData = result['data'] ?? [];
        _appointments =
            appointmentsData.map((json) => Appointment.fromJson(json)).toList();

        print(
            '✅ Successfully loaded ${_appointments.length} appointments from API');
      } else {
        print('❌ Failed to load appointments: ${result['message']}');
        // Fallback to empty list if API fails
        _appointments = [];
      }
    } catch (e) {
      print('❌ Error loading appointments: $e');
      // Fallback to empty list if there's an error
      _appointments = [];
    }

    setBusy(false);
    print('ScheduleViewModel.loadAppointments() completed');
  }

  Future<void> cancelAppointment(String appointmentTime) async {
    setBusy(true);
    // Remove by time for dummy data
    _appointments
        .removeWhere((appointment) => appointment.time == appointmentTime);
    notifyListeners();
    setBusy(false);
  }

  Future<void> rescheduleAppointment(String appointmentTime) async {
    setBusy(true);
    // Dummy implementation
    setBusy(false);
  }

  Future<void> scheduleAppointment(DateTime dateTime) async {
    setBusy(true);
    // Dummy appointment data for scheduling
    final newAppointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      doctorName: 'Dr. New Appointment',
      doctorImage: 'https://randomuser.me/api/portraits/men/14.jpg',
      specialty: 'General',
      isVideoCall: false,
      date:
          '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}',
      time:
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
      appointmentType: "consultation",
      preApprovalStatus: _preApprovalService.isPreApprovalRequired('General')
          ? 'pending'
          : 'notRequired',
    );
    _appointments.add(newAppointment);
    notifyListeners();
    setBusy(false);
  }
}
