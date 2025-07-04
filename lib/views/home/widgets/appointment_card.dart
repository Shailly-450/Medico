import 'package:flutter/material.dart';
import '../../../models/appointment.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/pre_approval_service.dart';
import '../../appointments/appointment_detail_screen.dart';
import '../../schedule/schedule_screen.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isVideo = appointment.isVideoCall;
    final statusText = isVideo ? 'Video Call' : 'In Person';
    final statusColor = isVideo ? AppColors.accent : AppColors.secondary;
    final statusTextColor = isVideo ? AppColors.primary : AppColors.primary;

    // Pre-approval status colors
    final preApprovalColor =
        _getPreApprovalColor(appointment.preApprovalStatus);
    final preApprovalText = _getPreApprovalText(appointment.preApprovalStatus);

    return GestureDetector(
      onTap: () {
        // Check if pre-approval is required and not approved
        if (appointment.preApprovalStatus == PreApprovalStatus.pending ||
            appointment.preApprovalStatus == PreApprovalStatus.rejected) {
          _showPreApprovalDialog(context);
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AppointmentDetailScreen(
              appointment: appointment,
              appointmentId: appointment.id,
              patientName: 'Abdullah Alshahrani',
              gender: 'Male',
              age: 28,
              problem:
                  'Hey, I have a problem with my stomach and I need to see a doctor.',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent bar
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: preApprovalColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor avatar with border
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.primary, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                NetworkImage(appointment.doctorImage),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    appointment.doctorName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textBlack,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Status tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isVideo
                                              ? Icons.videocam
                                              : Icons.event,
                                          size: 14,
                                          color: statusColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          statusText,
                                          style: TextStyle(
                                            color: statusTextColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  appointment.specialty,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${appointment.date} • ${appointment.time}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              if (appointment.preApprovalStatus !=
                                  PreApprovalStatus.notRequired) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: preApprovalColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: preApprovalColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    preApprovalText,
                                    style: TextStyle(
                                      color: preApprovalColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(
                        height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _cancelAppointment(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _rescheduleAppointment(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Reschedule'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPreApprovalColor(PreApprovalStatus status) {
    switch (status) {
      case PreApprovalStatus.approved:
        return Colors.green;
      case PreApprovalStatus.pending:
        return Colors.orange;
      case PreApprovalStatus.rejected:
        return Colors.red;
      case PreApprovalStatus.notRequired:
        return AppColors.accent;
    }
  }

  String _getPreApprovalText(PreApprovalStatus status) {
    switch (status) {
      case PreApprovalStatus.approved:
        return 'Pre-approved';
      case PreApprovalStatus.pending:
        return 'Pre-approval Pending';
      case PreApprovalStatus.rejected:
        return 'Pre-approval Required';
      case PreApprovalStatus.notRequired:
        return '';
    }
  }

  void _showPreApprovalDialog(BuildContext context) {
    final preApprovalService = PreApprovalService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          appointment.preApprovalStatus == PreApprovalStatus.rejected
              ? 'Pre-approval Required'
              : 'Pre-approval Pending',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(preApprovalService
                .getPreApprovalRequirements(appointment.specialty)),
            const SizedBox(height: 16),
            if (appointment.preApprovalStatus == PreApprovalStatus.rejected)
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success =
                      await preApprovalService.submitPreApprovalRequest(
                    appointmentId: appointment.id,
                    patientName: 'Abdullah Alshahrani',
                    specialty: appointment.specialty,
                    insuranceNumber: '123456789',
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Pre-approval request submitted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to submit pre-approval request'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit Pre-approval Request'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(BuildContext context) {
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

  void _rescheduleAppointment(BuildContext context) async {
    final result = await _showRescheduleDialog(context);
    if (result != null) {
      final newDate = result['date'] as DateTime;
      final newTime = result['time'] as TimeOfDay;

      // In a real app, this would call the API to reschedule
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment rescheduled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> _showRescheduleDialog(
      BuildContext context) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reschedule Appointment'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${appointment.doctorName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  appointment.specialty,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Date Selection
                const Text(
                  'Select New Date:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: AppColors.primary,
                                ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      selectedDate == null
                          ? 'Choose Date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time Selection
                const Text(
                  'Select New Time:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: AppColors.primary,
                                ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      selectedTime == null
                          ? 'Choose Time'
                          : selectedTime!.format(context),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                if (selectedDate != null && selectedTime != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'New appointment: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at ${selectedTime!.format(context)}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedDate != null && selectedTime != null
                  ? () => Navigator.pop(context, {
                        'date': selectedDate,
                        'time': selectedTime,
                      })
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Reschedule'),
            ),
          ],
        ),
      ),
    );
  }
}
