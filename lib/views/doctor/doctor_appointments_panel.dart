import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/doctor_appointment_view_model.dart';
import 'doctor_appointment_detail_screen.dart';

// Wrapper widget to provide the view model
class DoctorAppointmentsPanelWrapper extends StatelessWidget {
  const DoctorAppointmentsPanelWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🔧 DoctorAppointmentsPanelWrapper - Creating provider');
    return ChangeNotifierProvider(
      create: (_) {
        print(
            '🔧 DoctorAppointmentsPanelWrapper - Creating DoctorAppointmentViewModel');
        return DoctorAppointmentViewModel();
      },
      child: const DoctorAppointmentsPanel(),
    );
  }
}

class DoctorAppointmentsPanel extends StatefulWidget {
  const DoctorAppointmentsPanel({Key? key}) : super(key: key);

  @override
  State<DoctorAppointmentsPanel> createState() =>
      _DoctorAppointmentsPanelState();
}

class _DoctorAppointmentsPanelState extends State<DoctorAppointmentsPanel> {
  final Map<String, String> _statusMap = {
    'pending': 'Pending',
    'approved': 'Approved',
    'rejected': 'Rejected',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorAppointmentViewModel>().loadAppointments();
    });
  }

  Future<void> _updateAppointmentStatus(
      Appointment appointment, String status) async {
    final viewModel = context.read<DoctorAppointmentViewModel>();
    final success =
        await viewModel.updateAppointmentStatus(appointment.id, status);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Appointment ${status} successfully'
              : viewModel.errorMessage),
          backgroundColor: success
              ? (status == 'approved' ? Colors.green : Colors.red)
              : Colors.red,
        ),
      );
    }
  }

  Color _statusColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<DoctorAppointmentViewModel>().loadAppointments(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<DoctorAppointmentViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              _buildFilterChips(viewModel),
              Expanded(
                child: viewModel.busy
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.errorMessage.isNotEmpty
                        ? _buildErrorView(viewModel)
                        : viewModel.appointments.isEmpty
                            ? _buildEmptyView()
                            : _buildAppointmentsList(viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(DoctorAppointmentViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(viewModel, 'all', 'All'),
            const SizedBox(width: 8),
            _buildFilterChip(viewModel, 'pending', 'Pending'),
            const SizedBox(width: 8),
            _buildFilterChip(viewModel, 'today', 'Today'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      DoctorAppointmentViewModel viewModel, String value, String label) {
    final isSelected = viewModel.selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        viewModel.setFilter(value);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildErrorView(DoctorAppointmentViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.loadAppointments(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any appointments yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(DoctorAppointmentViewModel viewModel) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = viewModel.appointments[index];
        return _buildAppointmentTile(appointment, viewModel);
      },
    );
  }

  Widget _buildAppointmentTile(
      Appointment appointment, DoctorAppointmentViewModel viewModel) {
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
              builder: (context) => DoctorAppointmentDetailScreen(
                appointment: appointment,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
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
                          'Patient Consultation',
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
                              appointment.isVideoCall
                                  ? 'Video Call'
                                  : 'In Person',
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
                      color: viewModel
                          .getStatusColor(appointment.preApprovalStatus)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _statusMap[appointment.preApprovalStatus] ?? 'Unknown',
                      style: TextStyle(
                        color: viewModel
                            .getStatusColor(appointment.preApprovalStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (appointment.preApprovalStatus == 'pending') ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      label: 'Approve',
                      icon: Icons.check_circle,
                      color: Colors.green,
                      onTap: () =>
                          _updateAppointmentStatus(appointment, 'approved'),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      label: 'Reject',
                      icon: Icons.cancel,
                      color: Colors.red,
                      onTap: () =>
                          _updateAppointmentStatus(appointment, 'rejected'),
                    ),
                  ],
                ),
              ],
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
}
