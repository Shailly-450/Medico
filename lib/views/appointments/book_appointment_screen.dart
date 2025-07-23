import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/doctor.dart';
import '../../core/services/hospital_service.dart';
import 'package:medico/viewmodels/doctors_view_model.dart';
import '../../viewmodels/appointment_view_model.dart';
import '../home/widgets/doctor_card.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int? _selectedDoctorIndex;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isBooking = false;
  String? _errorMessage;
  String _selectedPreferredTimeSlot = 'morning';

  final List<String> _timeSlots = [
    'morning',
    'afternoon',
    'evening',
    'night',
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DoctorsViewModel()..fetchDoctorsFromApi()),
        ChangeNotifierProvider(create: (_) => AppointmentViewModel()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Appointment'),
          elevation: 0.5,
        ),
        backgroundColor: Colors.grey[50],
        body: Consumer2<DoctorsViewModel, AppointmentViewModel>(
          builder: (context, docViewModel, apptViewModel, child) {
            if (docViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (docViewModel.filteredDoctors.isEmpty) {
              return const Center(child: Text('No doctors available.'));
            }
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Doctor',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docViewModel.filteredDoctors.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 2),
                          itemBuilder: (context, index) {
                            final doc = docViewModel.filteredDoctors[index];
                            return GestureDetector(
                              onTap: () => setState(() => _selectedDoctorIndex = index),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedDoctorIndex == index
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DoctorCard(
                                  doctor: doc,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('Select Date',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickDate,
                                icon: const Icon(Icons.calendar_today),
                                label: Text(_selectedDate == null
                                    ? 'Choose Date'
                                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Select Time',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickTime,
                                icon: const Icon(Icons.access_time),
                                label: Text(_selectedTime == null
                                    ? 'Choose Time'
                                    : _selectedTime!.format(context)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Add preferred time slot dropdown
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: DropdownButtonFormField<String>(
                            value: _selectedPreferredTimeSlot,
                            decoration: const InputDecoration(
                              labelText: 'Preferred Time Slot',
                              border: OutlineInputBorder(),
                            ),
                            items: _timeSlots.map((slot) {
                              return DropdownMenuItem(
                                value: slot,
                                child: Text(slot[0].toUpperCase() + slot.substring(1)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPreferredTimeSlot = value ?? 'morning';
                              });
                            },
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_selectedDoctorIndex != null &&
                              _selectedDate != null &&
                              _selectedTime != null &&
                              !_isBooking)
                          ? () async {
                              setState(() {
                                _isBooking = true;
                                _errorMessage = null;
                              });
                              final doc = docViewModel.filteredDoctors[_selectedDoctorIndex!];
                              final DateTime appointmentDateTime = DateTime(
                                _selectedDate!.year,
                                _selectedDate!.month,
                                _selectedDate!.day,
                                _selectedTime!.hour,
                                _selectedTime!.minute,
                              );
                              // You may need to get hospitalId from doctor or context
                              final hospitalId = doc.hospital ?? '';
                              final apptViewModel = Provider.of<AppointmentViewModel>(context, listen: false);
                              final success = await apptViewModel.createAppointment(
                                doctorId: doc.id,
                                hospitalId: hospitalId,
                                appointmentDate: appointmentDateTime,
                                appointmentType: 'consultation',
                                preferredTimeSlot: _selectedPreferredTimeSlot,
                              );
                              setState(() {
                                _isBooking = false;
                              });
                              if (success) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Appointment Booked'),
                                    content: Text(
                                        'Your appointment with ${doc.name} is booked for '
                                        '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} at '
                                        '${_selectedTime!.format(context)}.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                setState(() {
                                  _errorMessage = apptViewModel.errorMessage ?? 'Failed to book appointment.';
                                });
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      child: _isBooking
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Confirm Appointment'),
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }
}
