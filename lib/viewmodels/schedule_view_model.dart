import '../core/viewmodels/base_view_model.dart';
import '../models/appointment.dart';
import '../core/services/pre_approval_service.dart';

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
    // Using dummy data for UI/UX testing with specific dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    // Specific dates requested by user
    final july2 = DateTime(now.year, 7, 2);
    final july4 = DateTime(now.year, 7, 4);
    final august8 = DateTime(now.year, 8, 8);

    print('Current year: ${now.year}');
    print('July 2nd: $july2');
    print('July 4th: $july4');
    print('August 8th: $august8');

    _appointments = [
      Appointment(
        id: '3001',
        doctorName: 'Dr. John Doe',
        doctorImage: 'https://randomuser.me/api/portraits/men/11.jpg',
        specialty: 'Cardiologist',
        isVideoCall: true,
        date:
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
        time: '09:00 AM',
        preApprovalStatus:
            _preApprovalService.isPreApprovalRequired('Cardiologist')
                ? PreApprovalStatus.pending
                : PreApprovalStatus.notRequired,
      ),
      Appointment(
        id: '3002',
        doctorName: 'Dr. Sara Doe',
        doctorImage: 'https://randomuser.me/api/portraits/women/12.jpg',
        specialty: 'Dermatologist',
        isVideoCall: false,
        date:
            '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}',
        time: '10:00 AM',
        preApprovalStatus:
            _preApprovalService.isPreApprovalRequired('Dermatologist')
                ? PreApprovalStatus.pending
                : PreApprovalStatus.notRequired,
      ),
      Appointment(
        id: '3003',
        doctorName: 'Dr. Emily Brown',
        doctorImage: 'https://randomuser.me/api/portraits/women/13.jpg',
        specialty: 'Pediatrician',
        isVideoCall: true,
        date:
            '${dayAfterTomorrow.year}-${dayAfterTomorrow.month.toString().padLeft(2, '0')}-${dayAfterTomorrow.day.toString().padLeft(2, '0')}',
        time: '02:00 PM',
        preApprovalStatus:
            _preApprovalService.isPreApprovalRequired('Pediatrician')
                ? PreApprovalStatus.pending
                : PreApprovalStatus.notRequired,
      ),
      // July 2nd appointments
      Appointment(
        id: '3004',
        doctorName: 'Dr. Michael Chen',
        doctorImage: 'https://randomuser.me/api/portraits/men/14.jpg',
        specialty: 'Neurologist',
        isVideoCall: true,
        date:
            '${july2.year}-${july2.month.toString().padLeft(2, '0')}-${july2.day.toString().padLeft(2, '0')}',
        time: '11:00 AM',
        preApprovalStatus:
            _preApprovalService.isPreApprovalRequired('Neurologist')
                ? PreApprovalStatus.approved
                : PreApprovalStatus.notRequired,
      ),
      Appointment(
        id: '3005',
        doctorName: 'Dr. Lisa Wang',
        doctorImage: 'https://randomuser.me/api/portraits/women/15.jpg',
        specialty: 'Orthopedic',
        isVideoCall: false,
        date:
            '${july2.year}-${july2.month.toString().padLeft(2, '0')}-${july2.day.toString().padLeft(2, '0')}',
        time: '03:30 PM',
        preApprovalStatus:
            _preApprovalService.isPreApprovalRequired('Orthopedic')
                ? PreApprovalStatus.rejected
                : PreApprovalStatus.notRequired,
      ),
      // July 4th appointments
      Appointment(
        id: '3006',
        doctorName: 'Dr. Robert Johnson',
        doctorImage: 'https://randomuser.me/api/portraits/men/16.jpg',
        specialty: 'General Physician',
        isVideoCall: false,
        date:
            '${july4.year}-${july4.month.toString().padLeft(2, '0')}-${july4.day.toString().padLeft(2, '0')}',
        time: '09:30 AM',
        preApprovalStatus:
            _preApprovalService.isPreApprovalRequired('General Physician')
                ? PreApprovalStatus.pending
                : PreApprovalStatus.notRequired,
      ),
      Appointment(
        id: '3007',
        doctorName: 'Dr. Maria Garcia',
        doctorImage: 'https://randomuser.me/api/portraits/women/17.jpg',
        specialty: 'Dentist',
        isVideoCall: false,
        date:
            '${july4.year}-${july4.month.toString().padLeft(2, '0')}-${july4.day.toString().padLeft(2, '0')}',
        time: '02:00 PM',
        preApprovalStatus: _preApprovalService.isPreApprovalRequired('Dentist')
            ? PreApprovalStatus.pending
            : PreApprovalStatus.notRequired,
      ),
      Appointment(
        id: '3008',
        doctorName: 'Dr. David Kim',
        doctorImage: 'https://randomuser.me/api/portraits/men/18.jpg',
        specialty: 'Psychiatrist',
        isVideoCall: true,
        date:
            '${july4.year}-${july4.month.toString().padLeft(2, '0')}-${july4.day.toString().padLeft(2, '0')}',
        time: '04:15 PM',
        preApprovalStatus:
            _preApprovalService.isPreApprovalRequired('Psychiatrist')
                ? PreApprovalStatus.pending
                : PreApprovalStatus.notRequired,
      ),
      // August 8th appointments
      Appointment(
        id: '3009',
        doctorName: 'Dr. Sarah Wilson',
        doctorImage: 'https://randomuser.me/api/portraits/women/19.jpg',
        specialty: 'Gynecologist',
        isVideoCall: false,
        date:
            '${august8.year}-${august8.month.toString().padLeft(2, '0')}-${august8.day.toString().padLeft(2, '0')}',
        time: '10:00 AM',
        preApprovalStatus:
            _preApprovalService.isPreApprovalRequired('Gynecologist')
                ? PreApprovalStatus.pending
                : PreApprovalStatus.notRequired,
      ),
      Appointment(
        id: '3010',
        doctorName: 'Dr. James Anderson',
        doctorImage: 'https://randomuser.me/api/portraits/men/20.jpg',
        specialty: 'Urologist',
        isVideoCall: true,
        date:
            '${august8.year}-${august8.month.toString().padLeft(2, '0')}-${august8.day.toString().padLeft(2, '0')}',
        time: '01:45 PM',
        preApprovalStatus:
            _preApprovalService.isPreApprovalRequired('Urologist')
                ? PreApprovalStatus.pending
                : PreApprovalStatus.notRequired,
      ),
      Appointment(
        id: '3011',
        doctorName: 'Dr. Jennifer Lee',
        doctorImage: 'https://randomuser.me/api/portraits/women/21.jpg',
        specialty: 'Ophthalmologist',
        isVideoCall: false,
        date:
            '${august8.year}-${august8.month.toString().padLeft(2, '0')}-${august8.day.toString().padLeft(2, '0')}',
        time: '03:00 PM',
        preApprovalStatus:
            _preApprovalService.isPreApprovalRequired('Ophthalmologist')
                ? PreApprovalStatus.pending
                : PreApprovalStatus.notRequired,
      ),
    ];

    print('Created ${_appointments.length} appointments');
    _appointments.forEach((appointment) {
      print('Appointment: ${appointment.doctorName} on ${appointment.date}');
    });

    _historyAppointments = [
      Appointment(
        id: '3012',
        doctorName: 'Dr. Mike Johnson',
        doctorImage: 'https://randomuser.me/api/portraits/men/13.jpg',
        specialty: 'Neurologist',
        isVideoCall: true,
        date:
            '${today.subtract(const Duration(days: 1)).year}-${today.subtract(const Duration(days: 1)).month.toString().padLeft(2, '0')}-${today.subtract(const Duration(days: 1)).day.toString().padLeft(2, '0')}',
        time: '02:00 PM',
        preApprovalStatus: PreApprovalStatus.approved,
      ),
    ];
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
      preApprovalStatus: _preApprovalService.isPreApprovalRequired('General')
          ? PreApprovalStatus.pending
          : PreApprovalStatus.notRequired,
    );
    _appointments.add(newAppointment);
    notifyListeners();
    setBusy(false);
  }
}
