import 'package:flutter/material.dart';
import '../../models/test_checkup.dart';
import '../../core/services/test_checkup_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';

class AddTestCheckupScreen extends StatefulWidget {
  const AddTestCheckupScreen({Key? key}) : super(key: key);

  @override
  State<AddTestCheckupScreen> createState() => _AddTestCheckupScreenState();
}

class _AddTestCheckupScreenState extends State<AddTestCheckupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _doctorSpecialtyController = TextEditingController();
  final _clinicController = TextEditingController();
  final _costController = TextEditingController();

  String _type = 'blood-test';
  String _priority = 'medium';
  DateTime _scheduledAt = DateTime.now();
  bool _isLoading = false;
  String? _error;

  final _testTypes = [
    'blood-test',
    'urine-test',
    'x-ray',
    'mri',
    'ct-scan',
    'ultrasound',
    'ecg',
    'endoscopy',
  ];

  final _priorities = ['low', 'medium', 'high', 'urgent'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Test/Checkup'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: TextStyle(color: Colors.red[900])),
              ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Test Name*',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description*',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Test Type*',
                border: OutlineInputBorder(),
              ),
              items: _testTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.replaceAll('-', ' ').toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority*',
                border: OutlineInputBorder(),
              ),
              items: _priorities
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 16),
            // Provider Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Provider Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _doctorNameController,
                    decoration: const InputDecoration(
                      labelText: 'Doctor Name*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _doctorSpecialtyController,
                    decoration: const InputDecoration(
                      labelText: 'Specialty*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _clinicController,
                    decoration: const InputDecoration(
                      labelText: 'Clinic/Hospital*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost*',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'Scheduled Date & Time: ${_scheduledAt.day}/${_scheduledAt.month}/${_scheduledAt.year} at ${_scheduledAt.hour}:${_scheduledAt.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _scheduledAt,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_scheduledAt),
                  );
                  if (time != null) {
                    setState(() {
                      _scheduledAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = TestCheckupService();
      final userId = AuthService.currentUserId;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await service.createCheckup(
        name: _nameController.text,
        type: _type,
        priority: _priority,
        description: _descController.text,
        scheduledAt: _scheduledAt,
        provider: {
          'name': _doctorNameController.text,
          'specialty': _doctorSpecialtyController.text,
          'clinic': _clinicController.text,
        },
        cost: double.parse(_costController.text),
        userId: userId,
      );

      if (mounted) {
        Navigator.of(context).pop(response);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
