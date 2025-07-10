import 'package:flutter/material.dart';
import 'package:medico/models/patient_record.dart';

class PatientCard extends StatelessWidget {
  final PatientRecord patient;
  final VoidCallback onTap;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          patient.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Age: ${patient.age} | Gender: ${patient.gender}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
