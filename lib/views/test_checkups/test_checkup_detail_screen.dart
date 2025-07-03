import 'package:flutter/material.dart';
import '../../models/test_checkup.dart';

class TestCheckupDetailScreen extends StatelessWidget {
  final TestCheckup checkup;
  const TestCheckupDetailScreen({Key? key, required this.checkup})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(checkup.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDetailRow('Type', checkup.typeDisplayName),
          _buildDetailRow('Status', checkup.statusDisplayName),
          _buildDetailRow('Priority', checkup.priorityDisplayName),
          _buildDetailRow('Date',
              '${checkup.scheduledDate.day}/${checkup.scheduledDate.month}/${checkup.scheduledDate.year}'),
          _buildDetailRow('Time',
              '${checkup.scheduledTime.hour.toString().padLeft(2, '0')}:${checkup.scheduledTime.minute.toString().padLeft(2, '0')}'),
          if (checkup.location != null)
            _buildDetailRow('Location', checkup.location!),
          if (checkup.doctorName != null)
            _buildDetailRow('Doctor', checkup.doctorName!),
          if (checkup.doctorSpecialty != null)
            _buildDetailRow('Specialty', checkup.doctorSpecialty!),
          if (checkup.estimatedCost != null)
            _buildDetailRow('Estimated Cost',
                '\$${checkup.estimatedCost!.toStringAsFixed(2)}'),
          if (checkup.instructions != null)
            _buildDetailRow('Instructions', checkup.instructions!),
          if (checkup.requiresFasting) _buildDetailRow('Fasting', 'Required'),
          if (checkup.requiresPreparation)
            _buildDetailRow('Preparation', 'Required'),
          if (checkup.preparationInstructions != null)
            _buildDetailRow(
                'Preparation Instructions', checkup.preparationInstructions!),
          if (checkup.requiredDocuments.isNotEmpty)
            _buildDetailRow('Documents', checkup.requiredDocuments.join(', ')),
          if (checkup.hasReminder && checkup.reminderTime != null)
            _buildDetailRow('Reminder',
                '${checkup.reminderTime!.day}/${checkup.reminderTime!.month}/${checkup.reminderTime!.year}'),
          if (checkup.completedDate != null)
            _buildDetailRow('Completed',
                '${checkup.completedDate!.day}/${checkup.completedDate!.month}/${checkup.completedDate!.year}'),
          if (checkup.results != null)
            _buildDetailRow('Results', checkup.results!),
          if (checkup.notes != null) _buildDetailRow('Notes', checkup.notes!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
