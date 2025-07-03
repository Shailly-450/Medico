import 'package:flutter/material.dart';
import '../../models/medicine.dart';
import '../../models/medicine_reminder.dart';
import '../../core/theme/app_colors.dart';

class AddMedicineReminderScreen extends StatefulWidget {
  final List<Medicine> medicines;
  final MedicineReminder? editingReminder;

  const AddMedicineReminderScreen({
    Key? key,
    required this.medicines,
    this.editingReminder,
  }) : super(key: key);

  @override
  State<AddMedicineReminderScreen> createState() =>
      _AddMedicineReminderScreenState();
}

class _AddMedicineReminderScreenState extends State<AddMedicineReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reminderNameController = TextEditingController();
  final _instructionsController = TextEditingController();

  Medicine? _selectedMedicine;
  ReminderFrequency _frequency = ReminderFrequency.daily;
  int _dosesPerDay = 1;
  List<TimeOfDay> _reminderTimes = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();
  bool _takeWithFood = false;
  bool _hasNotifications = true;

  @override
  void initState() {
    super.initState();
    if (widget.editingReminder != null) {
      _loadEditingData();
    }
  }

  void _loadEditingData() {
    final reminder = widget.editingReminder!;
    _reminderNameController.text = reminder.reminderName;
    _instructionsController.text = reminder.instructions ?? '';
    _selectedMedicine = reminder.medicine;
    _frequency = reminder.frequency;
    _dosesPerDay = reminder.dosesPerDay;
    _reminderTimes = reminder.reminderTimes
        .map((time) => TimeOfDay.fromDateTime(time))
        .toList();
    _startDate = reminder.startDate;
    _takeWithFood = reminder.takeWithFood;
    _hasNotifications = reminder.hasNotifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.editingReminder == null ? 'Add Reminder' : 'Edit Reminder'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveReminder,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _reminderNameController,
                decoration: const InputDecoration(
                  labelText: 'Reminder Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Medicine>(
                value: _selectedMedicine,
                decoration: const InputDecoration(
                  labelText: 'Select Medicine',
                  border: OutlineInputBorder(),
                ),
                items: widget.medicines.map((medicine) {
                  return DropdownMenuItem(
                    value: medicine,
                    child: Text('${medicine.name} (${medicine.dosage})'),
                  );
                }).toList(),
                onChanged: (medicine) =>
                    setState(() => _selectedMedicine = medicine),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReminderFrequency>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: ReminderFrequency.values.map((freq) {
                  return DropdownMenuItem(
                    value: freq,
                    child: Text(freq.name),
                  );
                }).toList(),
                onChanged: (freq) => setState(() => _frequency = freq!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _dosesPerDay.toString(),
                decoration: const InputDecoration(
                  labelText: 'Doses per Day',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    setState(() => _dosesPerDay = int.tryParse(value) ?? 1),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _reminderTimes.first,
                  );
                  if (time != null) {
                    setState(() => _reminderTimes = [time]);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Reminder Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_reminderTimes.first.format(context)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Take with food'),
                value: _takeWithFood,
                onChanged: (value) => setState(() => _takeWithFood = value!),
              ),
              CheckboxListTile(
                title: const Text('Enable notifications'),
                value: _hasNotifications,
                onChanged: (value) =>
                    setState(() => _hasNotifications = value!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveReminder() {
    if (!_formKey.currentState!.validate()) return;

    final reminder = MedicineReminder(
      id: widget.editingReminder?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      medicineId: _selectedMedicine!.id,
      medicine: _selectedMedicine,
      reminderName: _reminderNameController.text,
      frequency: _frequency,
      dosesPerDay: _dosesPerDay,
      reminderTimes: _reminderTimes.map((time) {
        return DateTime(_startDate.year, _startDate.month, _startDate.day,
            time.hour, time.minute);
      }).toList(),
      startDate: _startDate,
      dosesCompleted: widget.editingReminder?.dosesCompleted ?? 0,
      instructions: _instructionsController.text.isEmpty
          ? null
          : _instructionsController.text,
      takeWithFood: _takeWithFood,
      hasNotifications: _hasNotifications,
      createdAt: widget.editingReminder?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(reminder);
  }
}
