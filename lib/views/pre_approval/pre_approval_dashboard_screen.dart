import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/pre_approval_service.dart';

class PreApprovalDashboardScreen extends StatefulWidget {
  const PreApprovalDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PreApprovalDashboardScreen> createState() =>
      _PreApprovalDashboardScreenState();
}

class _PreApprovalDashboardScreenState extends State<PreApprovalDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PreApprovalService _preApprovalService = PreApprovalService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-approval Dashboard'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildStatusSummary(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                        _buildPreApprovalList('pending'),
        _buildPreApprovalList('approved'),
        _buildPreApprovalList('rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatusCard(
            'Pending',
            '5',
            Colors.orange,
            Icons.pending_actions,
          ),
          const SizedBox(width: 8),
          _buildStatusCard(
            'Approved',
            '12',
            Colors.green,
            Icons.check_circle,
          ),
          const SizedBox(width: 8),
          _buildStatusCard(
            'Rejected',
            '3',
            Colors.red,
            Icons.cancel,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreApprovalList(String status) {
    // In a real app, this would fetch from a service
    final appointments = _getDummyAppointments()
        .where((a) => a.preApprovalStatus == status)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildPreApprovalCard(appointment);
      },
    );
  }

  Widget _buildPreApprovalCard(Appointment appointment) {
    final requirements =
        _preApprovalService.getPreApprovalRequirements(appointment.specialty);
    final statusColor = _getStatusColor(appointment.preApprovalStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
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
                      Text(
                        appointment.specialty,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(appointment.preApprovalStatus),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Appointment Details',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Date', appointment.date),
            _buildDetailRow('Time', appointment.time),
            _buildDetailRow(
                'Type', appointment.isVideoCall ? 'Video Call' : 'In-Person'),
            const SizedBox(height: 12),
            const Text(
              'Pre-approval Requirements',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              requirements,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            if (appointment.preApprovalStatus == 'rejected')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success =
                          await _preApprovalService.submitPreApprovalRequest(
                        appointmentId: appointment.id,
                        patientName: 'Abdullah Alshahrani',
                        specialty: appointment.specialty,
                        insuranceNumber: '123456789',
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Pre-approval request submitted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Submit Pre-approval Request'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'notRequired':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      case 'notRequired':
        return 'Not Required';
      default:
        return 'Unknown';
    }
  }

  List<Appointment> _getDummyAppointments() {
    return [
      Appointment(
        id: '5001',
        doctorName: "Dr. Sarah Johnson",
        doctorImage:
            "https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg",
        specialty: "Cardiologist",
        isVideoCall: true,
        date: "2024-03-20",
        time: "10:00 AM",
        appointmentType: "consultation",
        preApprovalStatus: "pending",
      ),
      Appointment(
        id: '5002',
        doctorName: "Dr. James Rodriguez",
        doctorImage:
            "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
        specialty: "Neurologist",
        isVideoCall: false,
        date: "2024-03-22",
        time: "2:30 PM",
        appointmentType: "consultation",
        preApprovalStatus: "approved",
      ),
      Appointment(
        id: '5003',
        doctorName: "Dr. Maria Garcia",
        doctorImage:
            "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
        specialty: "Psychiatrist",
        isVideoCall: true,
        date: "2024-03-25",
        time: "11:15 AM",
        appointmentType: "consultation",
        preApprovalStatus: "rejected",
      ),
      // Add more dummy appointments as needed
    ];
  }
}
