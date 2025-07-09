import 'package:flutter/material.dart';
import '../../../models/appointment.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/pre_approval_service.dart';

class AdminAppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const AdminAppointmentDetailScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<AdminAppointmentDetailScreen> createState() =>
      _AdminAppointmentDetailScreenState();
}

class _AdminAppointmentDetailScreenState
    extends State<AdminAppointmentDetailScreen> {
  // Mock patient data - in real app this would come from API
  final Map<String, dynamic> _patientData = {
    'name': 'John Smith',
    'email': 'john.smith@email.com',
    'phone': '+1 (555) 123-4567',
    'age': 35,
    'gender': 'Male',
    'address': '123 Main Street, City, State 12345',
    'emergencyContact': 'Jane Smith (Wife) - +1 (555) 987-6543',
    'insuranceProvider': 'Blue Cross Blue Shield',
    'insuranceNumber': 'BCBS123456789',
    'medicalHistory': [
      'Hypertension (2020)',
      'Diabetes Type 2 (2018)',
      'Appendectomy (2015)',
    ],
    'currentMedications': [
      'Metformin 500mg twice daily',
      'Lisinopril 10mg once daily',
      'Atorvastatin 20mg once daily',
    ],
    'allergies': ['Penicillin', 'Sulfa drugs'],
    'problem':
        'Experiencing chest pain and shortness of breath for the past 3 days. Pain radiates to left arm. Also feeling fatigued and having difficulty sleeping.',
    'symptoms': [
      'Chest pain',
      'Shortness of breath',
      'Fatigue',
      'Difficulty sleeping',
      'Pain radiating to left arm',
    ],
    'duration': '3 days',
    'severity': 'Moderate',
    'previousVisits': 2,
    'lastVisit': '2024-06-15',
  };

  final Map<String, dynamic> _appointmentData = {
    'id': 'APT-2024-001',
    'createdAt': '2024-07-08 14:30:00',
    'status': 'Pending',
    'type': 'Video Call',
    'duration': '30 minutes',
    'price': 120.0,
    'paymentStatus': 'Pending',
    'paymentMethod': 'Credit Card',
    'notes':
        'Patient requested urgent consultation due to chest pain symptoms.',
    'priority': 'High',
    'assignedTo': 'Dr. Alice Johnson',
    'department': 'Cardiology',
    'location': 'Virtual Consultation',
    'timezone': 'EST (UTC-5)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment #${_appointmentData['id']}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(),
            tooltip: 'Edit Appointment',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printAppointment(),
            tooltip: 'Print Details',
          ),
        ],
      ),
      backgroundColor: AppColors.paleBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildDoctorCard(),
            const SizedBox(height: 16),
            _buildPatientCard(),
            const SizedBox(height: 16),
            _buildAppointmentDetailsCard(),
            const SizedBox(height: 16),
            _buildMedicalInfoCard(),
            const SizedBox(height: 16),
            _buildPaymentCard(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor = _getStatusColor(widget.appointment.preApprovalStatus);
    String statusText = _getStatusText(widget.appointment.preApprovalStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(widget.appointment.preApprovalStatus),
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $statusText',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Text(
                  'Priority: ${_appointmentData['priority']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (widget.appointment.preApprovalStatus == PreApprovalStatus.pending)
            _buildStatusActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => _updateStatus(PreApprovalStatus.approved),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Approve'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _updateStatus(PreApprovalStatus.rejected),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Reject'),
        ),
      ],
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doctor Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(widget.appointment.doctorImage),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appointment.doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.appointment.specialty,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          widget.appointment.isVideoCall
                              ? Icons.videocam
                              : Icons.person,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.appointment.isVideoCall
                              ? 'Video Consultation'
                              : 'In-Person Visit',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Name', _patientData['name']),
          _buildDetailRow('Email', _patientData['email']),
          _buildDetailRow('Phone', _patientData['phone']),
          _buildDetailRow('Age', '${_patientData['age']} years'),
          _buildDetailRow('Gender', _patientData['gender']),
          _buildDetailRow('Address', _patientData['address']),
          _buildDetailRow(
              'Emergency Contact', _patientData['emergencyContact']),
          _buildDetailRow('Insurance',
              '${_patientData['insuranceProvider']} - ${_patientData['insuranceNumber']}'),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Appointment ID', _appointmentData['id']),
          _buildDetailRow('Date', widget.appointment.date),
          _buildDetailRow('Time', widget.appointment.time),
          _buildDetailRow('Duration', _appointmentData['duration']),
          _buildDetailRow('Type', _appointmentData['type']),
          _buildDetailRow('Created', _appointmentData['createdAt']),
          _buildDetailRow('Location', _appointmentData['location']),
          _buildDetailRow('Timezone', _appointmentData['timezone']),
          _buildDetailRow('Notes', _appointmentData['notes']),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medical Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Problem', _patientData['problem'], isProblem: true),
          _buildDetailRow('Duration', _patientData['duration']),
          _buildDetailRow('Severity', _patientData['severity']),
          _buildDetailRow(
              'Previous Visits', '${_patientData['previousVisits']} visits'),
          _buildDetailRow('Last Visit', _patientData['lastVisit']),
          const SizedBox(height: 8),
          const Text(
            'Symptoms:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...(_patientData['symptoms'] as List<String>).map(
            (symptom) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 2),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record,
                      size: 8, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(symptom, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Current Medications:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...(_patientData['currentMedications'] as List<String>).map(
            (med) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 2),
              child: Row(
                children: [
                  const Icon(Icons.medication, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(med, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Allergies:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...(_patientData['allergies'] as List<String>).map(
            (allergy) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 2),
              child: Row(
                children: [
                  const Icon(Icons.warning, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(allergy, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
              'Amount', '\$${_appointmentData['price'].toStringAsFixed(2)}'),
          _buildDetailRow('Status', _appointmentData['paymentStatus']),
          _buildDetailRow('Method', _appointmentData['paymentMethod']),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _rescheduleAppointment(),
            icon: const Icon(Icons.schedule),
            label: const Text('Reschedule Appointment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _sendNotification(),
            icon: const Icon(Icons.notifications),
            label: const Text('Send Notification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _viewMedicalHistory(),
            icon: const Icon(Icons.history),
            label: const Text('View Medical History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isProblem = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment:
            isProblem ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textBlack,
                fontWeight: isProblem ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: isProblem ? 3 : 1,
              overflow: isProblem ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PreApprovalStatus status) {
    switch (status) {
      case PreApprovalStatus.approved:
        return Colors.green;
      case PreApprovalStatus.rejected:
        return Colors.red;
      case PreApprovalStatus.pending:
        return AppColors.accent;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(PreApprovalStatus status) {
    switch (status) {
      case PreApprovalStatus.approved:
        return 'Approved';
      case PreApprovalStatus.rejected:
        return 'Rejected';
      case PreApprovalStatus.pending:
        return 'Pending';
      default:
        return 'Not Required';
    }
  }

  IconData _getStatusIcon(PreApprovalStatus status) {
    switch (status) {
      case PreApprovalStatus.approved:
        return Icons.check_circle;
      case PreApprovalStatus.rejected:
        return Icons.cancel;
      case PreApprovalStatus.pending:
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  void _updateStatus(PreApprovalStatus newStatus) {
    // In real app, this would update the backend
    // For now, just show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Appointment status updated to ${_getStatusText(newStatus)}'),
        backgroundColor: _getStatusColor(newStatus),
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Appointment'),
        content: const Text('Edit functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _printAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Printing appointment details...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _rescheduleAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening reschedule dialog...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _sendNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sending notification to patient...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewMedicalHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening medical history...'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
