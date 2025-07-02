import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/appointment.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/schedule_view_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Appointment>> _events = {};
  ScheduleViewModel? _viewModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    print('ScheduleScreen initState called');
    _initializeData();
  }

  Future<void> _initializeData() async {
    print('Starting _initializeData');
    _viewModel = ScheduleViewModel();
    print('ScheduleViewModel created');
    await _viewModel!.loadAppointments();
    print(
        'loadAppointments completed, appointments count: ${_viewModel!.appointments.length}');
    setState(() {
      _loadEvents(_viewModel!.appointments);
      _isLoading = false;
    });
    print('setState called, _isLoading set to false');
  }

  void _loadEvents(List<Appointment> appointments) {
    _events.clear();
    print('Loading ${appointments.length} appointments into events map');

    // Group appointments by date
    for (var appointment in appointments) {
      final date = _parseDate(appointment.date);
      print(
          'Appointment: ${appointment.doctorName} on ${appointment.date} -> parsed as $date');
      if (_events[date] == null) _events[date] = [];
      _events[date]!.add(appointment);
    }

    print('Events map now contains ${_events.length} dates with appointments');
    _events.forEach((date, appointments) {
      print('Date $date: ${appointments.length} appointments');
    });
  }

  DateTime _parseDate(String dateString) {
    print('Parsing date string: "$dateString"');
    // Handle different date formats
    if (dateString.contains('-')) {
      final parts = dateString.split('-');
      final parsed = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      print('Parsed as: $parsed');
      return parsed;
    } else if (dateString.contains('/')) {
      final parts = dateString.split('/');
      final parsed = DateTime(
          int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      print('Parsed as: $parsed');
      return parsed;
    } else {
      // For "Today" or "Yesterday" format, use current date
      final now = DateTime.now();
      DateTime parsed;
      if (dateString.startsWith('Today')) {
        parsed = DateTime(now.year, now.month, now.day);
      } else if (dateString.startsWith('Yesterday')) {
        parsed = DateTime(now.year, now.month, now.day - 1);
      } else {
        parsed = now;
      }
      print('Parsed as: $parsed');
      return parsed;
    }
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    print('Getting events for day $day (${day.year}-${day.month}-${day.day})');
    print('Available event dates: ${_events.keys.toList()}');

    // Check for exact match
    final events = _events[day] ?? [];

    // Also check for dates that might match when normalized
    final normalizedDay = DateTime(day.year, day.month, day.day);
    if (events.isEmpty) {
      for (final eventDate in _events.keys) {
        final normalizedEventDate =
            DateTime(eventDate.year, eventDate.month, eventDate.day);
        if (normalizedEventDate.isAtSameMomentAs(normalizedDay)) {
          print(
              'Found matching events through normalization: ${_events[eventDate]!.length}');
          return _events[eventDate]!;
        }
      }
    }

    print(
        'Found ${events.length} appointments for ${day.year}-${day.month}-${day.day}');
    return events;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
