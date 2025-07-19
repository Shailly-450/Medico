import 'package:flutter/material.dart';
import '../../../models/appointment.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/pre_approval_service.dart';
import 'admin_appointment_detail_screen.dart';

class AdminAppointmentsPanel extends StatefulWidget {
  const AdminAppointmentsPanel({Key? key}) : super(key: key);

  @override
  State<AdminAppointmentsPanel> createState() => _AdminAppointmentsPanelState();
}

class _AdminAppointmentsPanelState extends State<AdminAppointmentsPanel> {
  late List<Appointment> _appointments;
  final Map<String, String> _statusMap = {
    'pending': 'Pending',
    'approved': 'Approved',
    'rejected': 'Rejected',
  };

  @override
  void initState() {
    super.initState();
    _appointments = _generateDummyAppointments();
  }

  void _updateAppointmentStatus(Appointment appointment, String statusKey) {
    setState(() {
      final index = _appointments.indexWhere((a) => a.id == appointment.id);
      if (index != -1) {
        _appointments[index] = Appointment(
          id: appointment.id,
          doctorName: appointment.doctorName,
          doctorImage: appointment.doctorImage,
          specialty: appointment.specialty,
          isVideoCall: appointment.isVideoCall,
          date: appointment.date,
          time: appointment.time,
          appointmentType: appointment.appointmentType,
          preApprovalStatus: statusKey,
        );
      }
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _appointments.isEmpty
          ? const Center(child: Text('No appointments found'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                return _buildAppointmentTile(appointment);
              },
            ),
    );
  }

  Widget _buildAppointmentTile(Appointment appointment) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminAppointmentDetailScreen(
                appointment: appointment,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(appointment.doctorImage),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              appointment.isVideoCall
                                  ? Icons.videocam_rounded
                                  : Icons.person_rounded,
                              size: 16,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              appointment.isVideoCall ? 'Video' : 'In Person',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${appointment.date} | ${appointment.time}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(appointment.preApprovalStatus)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _statusMap[appointment.preApprovalStatus] ?? 'Pending',
                      style: TextStyle(
                        color: _statusColor(appointment.preApprovalStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (appointment.preApprovalStatus == 'pending')
                    _buildActionButton(
                      label: 'Approve',
                      icon: Icons.check_circle,
                      color: Colors.green,
                      onTap: () =>
                          _updateAppointmentStatus(appointment, 'approved'),
                    ),
                  if (appointment.preApprovalStatus == 'pending')
                    const SizedBox(width: 8),
                  if (appointment.preApprovalStatus == 'pending')
                    _buildActionButton(
                      label: 'Reject',
                      icon: Icons.cancel,
                      color: Colors.red,
                      onTap: () =>
                          _updateAppointmentStatus(appointment, 'rejected'),
                    ),
                  if (appointment.preApprovalStatus == 'approved')
                    const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  List<Appointment> _generateDummyAppointments() {
    return [
      Appointment(
        id: '1',
        doctorName: 'Dr. Alice Johnson',
        doctorImage: 'https://randomuser.me/api/portraits/women/44.jpg',
        specialty: 'Cardiology',
        isVideoCall: false,
        date: '2024-07-09',
        time: '09:30 AM',
        appointmentType: 'consultation',
        preApprovalStatus: 'pending',
      ),
      Appointment(
        id: '2',
        doctorName: 'Dr. Bob Smith',
        doctorImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        specialty: 'Dermatology',
        isVideoCall: true,
        date: '2024-07-10',
        time: '02:00 PM',
        appointmentType: 'consultation',
        preApprovalStatus: 'approved',
      ),
      Appointment(
        id: '3',
        doctorName: 'Dr. Sara Lee',
        doctorImage: 'https://randomuser.me/api/portraits/women/65.jpg',
        specialty: 'Pediatrics',
        isVideoCall: false,
        date: '2024-07-08',
        time: '11:00 AM',
        appointmentType: 'consultation',
        preApprovalStatus: 'approved',
      ),
      Appointment(
        id: '4',
        doctorName: 'Dr. David Kim',
        doctorImage: 'https://randomuser.me/api/portraits/men/45.jpg',
        specialty: 'Orthopedics',
        isVideoCall: true,
        date: '2024-07-07',
        time: '04:15 PM',
        appointmentType: 'consultation',
        preApprovalStatus: 'rejected',
      ),
    ];
  }
}
