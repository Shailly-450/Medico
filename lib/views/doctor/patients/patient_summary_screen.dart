import 'package:flutter/material.dart';
import 'package:medico/views/doctor/prescriptions/doctor_prescriptions_panel.dart';
import '../../../models/patient_record.dart';
import '../../../core/theme/app_colors.dart';

class PatientSummaryScreen extends StatelessWidget {
  final PatientRecord record;
  const PatientSummaryScreen({Key? key, required this.record})
      : super(key: key);

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildChipList(List<String> items, {Color color = Colors.blue}) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: items
          .map((e) => Chip(
                label: Text(e),
                backgroundColor: color.withOpacity(0.1),
                labelStyle: TextStyle(color: color),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Summary'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demographics
            _sectionTitle('Demographics'),
            Card(
              child: ListTile(
                title: Text(record.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Age: ${record.age}'),
                    Text('Gender: ${record.gender}'),
                    Text('Email: ${record.email}'),
                    Text('Phone: ${record.phone}'),
                    Text('Address: ${record.address}'),
                  ],
                ),
              ),
            ),
            // Insurance & Emergency
            _sectionTitle('Insurance & Emergency'),
            Card(
              child: ListTile(
                title: Text(
                    '${record.insuranceProvider} - ${record.insuranceNumber}'),
                subtitle: Text('Emergency: ${record.emergencyContact}'),
              ),
            ),
            // Vitals
            _sectionTitle('Latest Vitals'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: record.vitals.entries
                      .map((e) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text(e.key), Text(e.value)],
                          ))
                      .toList(),
                ),
              ),
            ),
            // Lab Results
            _sectionTitle('Recent Lab Results'),
            ...record.labResults.map((lr) => Card(
                  child: ListTile(
                    title: Text(lr['Test'] ?? ''),
                    trailing: Text(lr['Result'] ?? ''),
                  ),
                )),
            // Medical history
            _sectionTitle('Medical History'),
            _buildChipList(record.medicalHistory, color: Colors.orange),
            const SizedBox(height: 8),
            _sectionTitle('Current Medications'),
            _buildChipList(record.currentMedications, color: Colors.green),
            const SizedBox(height: 8),
            _sectionTitle('Allergies'),
            _buildChipList(record.allergies, color: Colors.red),
            const SizedBox(height: 8),
            _sectionTitle('Recent Appointments'),
            ...record.recentAppointments.map((a) => ListTile(title: Text(a))),
            const SizedBox(height: 8),
            _sectionTitle('Recent Prescriptions'),
            ...record.recentPrescriptions.map((p) => ListTile(title: Text(p))),
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
}
