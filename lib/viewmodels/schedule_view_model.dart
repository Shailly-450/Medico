import '../core/viewmodels/base_view_model.dart';
import '../models/appointment.dart';

class ScheduleViewModel extends BaseViewModel {
  String _selectedTab = 'My Booking';
  List<Appointment> _appointments = [];
  List<Appointment> _historyAppointments = [];

  String get selectedTab => _selectedTab;
  List<Appointment> get appointments => _selectedTab == 'My Booking' ? _appointments : _historyAppointments;

  void setTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  Future<void> loadAppointments() async {
    setBusy(true);
    // Using dummy data for UI/UX testing
    _appointments = [
      Appointment(
        doctorName: 'Dr. John Doe',
        doctorImage: 'https://randomuser.me/api/portraits/men/11.jpg',
        specialty: 'Cardiologist',
        isVideoCall: true,
        date: 'Today, 09:00 AM',
        time: '09:00 AM',
      ),
      Appointment(
        doctorName: 'Dr. Sara Doe',
        doctorImage: 'https://randomuser.me/api/portraits/women/12.jpg',
        specialty: 'Dermatologist',
        isVideoCall: false,
        date: 'Today, 10:00 AM',
        time: '10:00 AM',
      ),
    ];

    _historyAppointments = [
      Appointment(
        doctorName: 'Dr. Mike Johnson',
        doctorImage: 'https://randomuser.me/api/portraits/men/13.jpg',
        specialty: 'Neurologist',
        isVideoCall: true,
        date: 'Yesterday, 02:00 PM',
        time: '02:00 PM',
      ),
    ];
    setBusy(false);
  }

  Future<void> cancelAppointment(String appointmentTime) async {
    setBusy(true);
    // Remove by time for dummy data
    _appointments.removeWhere((appointment) => appointment.time == appointmentTime);
    notifyListeners();
    setBusy(false);
  }

  Future<void> rescheduleAppointment(String appointmentTime) async {
    setBusy(true);
    // Dummy implementation
    setBusy(false);
  }
} 