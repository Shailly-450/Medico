import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/appointment.dart';
import '../../core/theme/app_colors.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  const AppointmentCalendarScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentCalendarScreen> createState() =>
      _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Appointment>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  void _loadEvents() {
    // Sample appointments data - in real app, this would come from a service
    final appointments = [
      // January 2025 Appointments
      Appointment(
        doctorName: "Dr. Sarah Johnson",
        doctorImage:
            "https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg",
        specialty: "Cardiologist",
        isVideoCall: true,
        date: "2025-01-15",
        time: "10:00 AM",
      ),
      Appointment(
        doctorName: "Dr. Michael Chen",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Dentist",
        isVideoCall: false,
        date: "2025-01-15",
        time: "2:30 PM",
      ),
      Appointment(
        doctorName: "Dr. Emily Brown",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Pediatrician",
        isVideoCall: true,
        date: "2025-01-20",
        time: "4:00 PM",
      ),
      Appointment(
        doctorName: "Dr. Rajesh Kumar",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "General Physician",
        isVideoCall: false,
        date: "2025-01-22",
        time: "11:00 AM",
      ),
      Appointment(
        doctorName: "Dr. Priya Sharma",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Dermatologist",
        isVideoCall: true,
        date: "2025-01-25",
        time: "3:00 PM",
      ),

      // February 2025 Appointments
      Appointment(
        doctorName: "Dr. David Wilson",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Orthopedic Surgeon",
        isVideoCall: false,
        date: "2025-02-03",
        time: "9:00 AM",
      ),
      Appointment(
        doctorName: "Dr. Lisa Anderson",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Gynecologist",
        isVideoCall: true,
        date: "2025-02-05",
        time: "1:30 PM",
      ),
      Appointment(
        doctorName: "Dr. James Rodriguez",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Neurologist",
        isVideoCall: false,
        date: "2025-02-08",
        time: "3:45 PM",
      ),
      Appointment(
        doctorName: "Dr. Maria Garcia",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Psychiatrist",
        isVideoCall: true,
        date: "2025-02-12",
        time: "11:15 AM",
      ),
      Appointment(
        doctorName: "Dr. Robert Taylor",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Urologist",
        isVideoCall: false,
        date: "2025-02-15",
        time: "2:00 PM",
      ),
      Appointment(
        doctorName: "Dr. Jennifer Lee",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Endocrinologist",
        isVideoCall: true,
        date: "2025-02-18",
        time: "10:30 AM",
      ),
      Appointment(
        doctorName: "Dr. Thomas Martinez",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Pulmonologist",
        isVideoCall: false,
        date: "2025-02-22",
        time: "4:15 PM",
      ),

      // March 2025 Appointments
      Appointment(
        doctorName: "Dr. Amanda White",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Ophthalmologist",
        isVideoCall: true,
        date: "2025-03-01",
        time: "9:30 AM",
      ),
      Appointment(
        doctorName: "Dr. Christopher Davis",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Gastroenterologist",
        isVideoCall: false,
        date: "2025-03-05",
        time: "1:00 PM",
      ),
      Appointment(
        doctorName: "Dr. Nicole Thompson",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Rheumatologist",
        isVideoCall: true,
        date: "2025-03-08",
        time: "3:30 PM",
      ),
      Appointment(
        doctorName: "Dr. Kevin Johnson",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Hematologist",
        isVideoCall: false,
        date: "2025-03-12",
        time: "11:45 AM",
      ),
      Appointment(
        doctorName: "Dr. Rachel Green",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Oncologist",
        isVideoCall: true,
        date: "2025-03-15",
        time: "2:30 PM",
      ),
      Appointment(
        doctorName: "Dr. Daniel Brown",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Nephrologist",
        isVideoCall: false,
        date: "2025-03-18",
        time: "10:15 AM",
      ),
      Appointment(
        doctorName: "Dr. Stephanie Clark",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Dermatologist",
        isVideoCall: true,
        date: "2025-03-20",
        time: "4:00 PM",
      ),
      Appointment(
        doctorName: "Dr. Matthew Lewis",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Cardiologist",
        isVideoCall: false,
        date: "2025-03-25",
        time: "1:45 PM",
      ),
      Appointment(
        doctorName: "Dr. Jessica Hall",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Pediatrician",
        isVideoCall: true,
        date: "2025-03-28",
        time: "11:00 AM",
      ),

      // April 2025 Appointments
      Appointment(
        doctorName: "Dr. Andrew Young",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "General Physician",
        isVideoCall: false,
        date: "2025-04-02",
        time: "9:00 AM",
      ),
      Appointment(
        doctorName: "Dr. Michelle King",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Dentist",
        isVideoCall: true,
        date: "2025-04-05",
        time: "2:15 PM",
      ),
      Appointment(
        doctorName: "Dr. Ryan Scott",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Orthopedic Surgeon",
        isVideoCall: false,
        date: "2025-04-08",
        time: "3:30 PM",
      ),
      Appointment(
        doctorName: "Dr. Kimberly Adams",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Gynecologist",
        isVideoCall: true,
        date: "2025-04-12",
        time: "10:45 AM",
      ),
      Appointment(
        doctorName: "Dr. Brandon Baker",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Neurologist",
        isVideoCall: false,
        date: "2025-04-15",
        time: "1:20 PM",
      ),
      Appointment(
        doctorName: "Dr. Ashley Nelson",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Psychiatrist",
        isVideoCall: true,
        date: "2025-04-18",
        time: "4:30 PM",
      ),
      Appointment(
        doctorName: "Dr. Jonathan Carter",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Urologist",
        isVideoCall: false,
        date: "2025-04-22",
        time: "11:30 AM",
      ),
      Appointment(
        doctorName: "Dr. Samantha Mitchell",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Endocrinologist",
        isVideoCall: true,
        date: "2025-04-25",
        time: "2:45 PM",
      ),
      Appointment(
        doctorName: "Dr. Tyler Perez",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Pulmonologist",
        isVideoCall: false,
        date: "2025-04-28",
        time: "9:15 AM",
      ),

      // May 2025 Appointments
      Appointment(
        doctorName: "Dr. Lauren Roberts",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Ophthalmologist",
        isVideoCall: true,
        date: "2025-05-03",
        time: "3:00 PM",
      ),
      Appointment(
        doctorName: "Dr. Nathan Turner",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Gastroenterologist",
        isVideoCall: false,
        date: "2025-05-06",
        time: "10:30 AM",
      ),
      Appointment(
        doctorName: "Dr. Victoria Phillips",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Rheumatologist",
        isVideoCall: true,
        date: "2025-05-10",
        time: "1:45 PM",
      ),
      Appointment(
        doctorName: "Dr. Gregory Campbell",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Hematologist",
        isVideoCall: false,
        date: "2025-05-13",
        time: "4:15 PM",
      ),
      Appointment(
        doctorName: "Dr. Danielle Parker",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Oncologist",
        isVideoCall: true,
        date: "2025-05-16",
        time: "11:00 AM",
      ),
      Appointment(
        doctorName: "Dr. Sean Evans",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Nephrologist",
        isVideoCall: false,
        date: "2025-05-20",
        time: "2:30 PM",
      ),
      Appointment(
        doctorName: "Dr. Rebecca Edwards",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Dermatologist",
        isVideoCall: true,
        date: "2025-05-23",
        time: "9:45 AM",
      ),
      Appointment(
        doctorName: "Dr. Patrick Collins",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Cardiologist",
        isVideoCall: false,
        date: "2025-05-27",
        time: "3:30 PM",
      ),
      Appointment(
        doctorName: "Dr. Hannah Stewart",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Pediatrician",
        isVideoCall: true,
        date: "2025-05-30",
        time: "10:15 AM",
      ),
    ];

    // Group appointments by date
    for (var appointment in appointments) {
      final date = _parseDate(appointment.date);
      if (_events[date] == null) _events[date] = [];
      _events[date]!.add(appointment);
    }
  }

  DateTime _parseDate(String dateString) {
    final parts = dateString.split('-');
    return DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Calendar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<CalendarFormat>(
            icon: const Icon(Icons.view_week),
            onSelected: (CalendarFormat format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarFormat.month,
                child: Text('Month'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.week,
                child: Text('Week'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.twoWeeks,
                child: Text('2 Weeks'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          TableCalendar<Appointment>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: const TextStyle(color: Colors.red),
              holidayTextStyle: const TextStyle(color: Colors.red),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Selected day appointments
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text(
                      'Select a date to view appointments',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : _buildAppointmentsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to book appointment screen
          Navigator.pushNamed(context, '/book-appointment');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final events = _getEventsForDay(_selectedDay!);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments on ${_formatDate(_selectedDay!)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to schedule an appointment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final appointment = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Doctor Image
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(appointment.doctorImage),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle image loading error
                  },
                  child: appointment.doctorImage.isEmpty
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),

                // Appointment Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.specialty,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.time,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: appointment.isVideoCall
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  appointment.isVideoCall
                                      ? Icons.videocam
                                      : Icons.location_on,
                                  size: 12,
                                  color: appointment.isVideoCall
                                      ? Colors.blue
                                      : Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  appointment.isVideoCall
                                      ? 'Video'
                                      : 'In-Person',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: appointment.isVideoCall
                                        ? Colors.blue
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Join video call or navigate to appointment details
                        _showAppointmentActions(appointment);
                      },
                      icon: const Icon(Icons.more_vert),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAppointmentActions(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Appointment with ${appointment.doctorName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                appointment.isVideoCall ? Icons.videocam : Icons.location_on,
                color: AppColors.primary,
              ),
              title: Text(
                appointment.isVideoCall ? 'Join Video Call' : 'Get Directions',
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle video call or directions
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.primary),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to appointment details
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Reschedule'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to reschedule screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel Appointment'),
              onTap: () {
                Navigator.pop(context);
                _showCancelConfirmation(appointment);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Text(
          'Are you sure you want to cancel your appointment with ${appointment.doctorName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle appointment cancellation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment cancelled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
