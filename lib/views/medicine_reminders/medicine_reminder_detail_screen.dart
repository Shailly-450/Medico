import 'package:flutter/material.dart';
import '../../models/medicine_reminder.dart';

class MedicineReminderDetailScreen extends StatelessWidget {
  final MedicineReminder reminder;

  const MedicineReminderDetailScreen({Key? key, required this.reminder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(reminder.reminderName)),
      body: const Center(child: Text('Reminder Details')),
    );
  }
}
