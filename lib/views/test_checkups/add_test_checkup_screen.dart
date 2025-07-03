import 'package:flutter/material.dart';
import '../../models/test_checkup.dart';

class AddTestCheckupScreen extends StatefulWidget {
  const AddTestCheckupScreen({Key? key}) : super(key: key);

  @override
  State<AddTestCheckupScreen> createState() => _AddTestCheckupScreenState();
}

class _AddTestCheckupScreenState extends State<AddTestCheckupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TestCheckupType _type = TestCheckupType.bloodTest;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Test/Checkup'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                  labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TestCheckupType>(
              value: _type,
              decoration: const InputDecoration(
                  labelText: 'Type', border: OutlineInputBorder()),
              items: TestCheckupType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      ))
                  .toList(),
              onChanged: (type) => setState(() => _type = type!),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Date: ${_date.day}/${_date.month}/${_date.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            ListTile(
              title: Text('Time: ${_time.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) setState(() => _time = picked);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final checkup = TestCheckup(
      id: now.millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descController.text,
      type: _type,
      status: TestCheckupStatus.scheduled,
      priority: TestCheckupPriority.medium,
      scheduledDate: _date,
      scheduledTime: _time,
      createdAt: now,
      updatedAt: now,
    );
    Navigator.of(context).pop(checkup);
  }
}
