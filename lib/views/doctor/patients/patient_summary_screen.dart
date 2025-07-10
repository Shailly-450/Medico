import 'package:flutter/material.dart';
import 'package:medico/views/doctor/prescriptions/doctor_prescriptions_panel.dart';
import '../../../models/patient_record.dart';
import '../../../core/theme/app_colors.dart';

class PatientSummaryScreen extends StatelessWidget {
  final PatientRecord record;
  const PatientSummaryScreen({Key? key, required this.record})
      : super(key: key);

  Widget _sectionTitle(String title, {IconData? icon}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
          ],
        ),
      );

  Widget _buildChipList(List<String> items, {Color color = Colors.blue}) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map((e) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    e,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Widget content,
    Color? accentColor,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor?.withOpacity(0.1) ?? AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: accentColor ?? AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor ?? AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSign(String name, String value, {Color? statusColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor?.withOpacity(0.1) ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor?.withOpacity(0.3) ?? Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: statusColor ?? AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResult(Map<String, String> result) {
    final testName = result['Test'] ?? '';
    final testResult = result['Result'] ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              testName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
          ),
          Expanded(
            child: Text(
              testResult,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Patient Summary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Summary',
            onPressed: () {
              // TODO: Implement print functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Print feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Summary',
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          record.name.split(' ').map((e) => e[0]).join(''),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${record.age} years • ${record.gender}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.white.withOpacity(0.8), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          record.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.white.withOpacity(0.8), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        record.phone,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Demographics
            _sectionTitle('Demographics', icon: Icons.person),
            _buildInfoCard(
              title: 'Personal Information',
              accentColor: Colors.blue,
              icon: Icons.location_on,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Address', record.address),
                  const SizedBox(height: 8),
                  _buildInfoRow('Age', '${record.age} years'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Gender', record.gender),
                ],
              ),
            ),

            // Insurance & Emergency
            _sectionTitle('Insurance & Emergency', icon: Icons.security),
            _buildInfoCard(
              title: 'Insurance Details',
              accentColor: Colors.green,
              icon: Icons.medical_services,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Provider', record.insuranceProvider),
                  const SizedBox(height: 8),
                  _buildInfoRow('Policy Number', record.insuranceNumber),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.emergency, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Emergency Contact: ${record.emergencyContact}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Vitals
            _sectionTitle('Latest Vitals', icon: Icons.favorite),
            _buildInfoCard(
              title: 'Vital Signs',
              accentColor: Colors.red,
              icon: Icons.monitor_heart,
              content: Column(
                children: record.vitals.entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildVitalSign(e.key, e.value),
                        ))
                    .toList(),
              ),
            ),

            // Lab Results
            _sectionTitle('Recent Lab Results', icon: Icons.science),
            if (record.labResults.isNotEmpty)
              _buildInfoCard(
                title: 'Laboratory Tests',
                accentColor: Colors.purple,
                icon: Icons.science,
                content: Column(
                  children: record.labResults
                      .map((lr) => _buildLabResult(lr))
                      .toList(),
                ),
              ),

            // Medical History
            _sectionTitle('Medical History', icon: Icons.history),
            _buildChipList(record.medicalHistory, color: Colors.orange),

            const SizedBox(height: 16),

            // Current Medications
            _sectionTitle('Current Medications', icon: Icons.medication),
            _buildChipList(record.currentMedications, color: Colors.green),

            const SizedBox(height: 16),

            // Allergies
            _sectionTitle('Allergies', icon: Icons.warning),
            _buildChipList(record.allergies, color: Colors.red),

            const SizedBox(height: 16),

            // Recent Appointments
            _sectionTitle('Recent Appointments', icon: Icons.calendar_today),
            if (record.recentAppointments.isNotEmpty)
              _buildInfoCard(
                title: 'Appointment History',
                accentColor: Colors.indigo,
                icon: Icons.event,
                content: Column(
                  children: record.recentAppointments
                      .map((a) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.event_note, color: Colors.indigo, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    a,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),

            const SizedBox(height: 16),

            // Recent Prescriptions
            _sectionTitle('Recent Prescriptions', icon: Icons.medication),
            if (record.recentPrescriptions.isNotEmpty)
              _buildInfoCard(
                title: 'Prescription History',
                accentColor: Colors.teal,
                icon: Icons.medication,
                content: Column(
                  children: record.recentPrescriptions
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.medication, color: Colors.teal, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    p,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  DoctorPrescriptionsPanel(doctorName: 'Dr. Smith'),
            ),
          );
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Prescription'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
        ),
      ],
    );
  }
}
