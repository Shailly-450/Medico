import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/doctor.dart';
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

  final List<Map<String, dynamic>> _dummyDoctors = [
    {
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Cardiologist',
      'imageUrl': 'https://randomuser.me/api/portraits/women/44.jpg',
      'hospital': 'City Hospital',
      'price': 500.0,
      'rating': 4.8,
      'reviews': 120,
    },
    {
      'name': 'Dr. Michael Chen',
      'specialty': 'Dentist',
      'imageUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
      'hospital': 'Smile Dental',
      'price': 350.0,
      'rating': 4.6,
      'reviews': 98,
    },
    {
      'name': 'Dr. Priya Singh',
      'specialty': 'Physiotherapist',
      'imageUrl': 'https://randomuser.me/api/portraits/women/68.jpg',
      'hospital': 'Wellness Center',
      'price': 400.0,
      'rating': 4.9,
      'reviews': 150,
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),

        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Doctor', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dummyDoctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final doc = _dummyDoctors[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDoctorIndex = index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedDoctorIndex == index ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DoctorCard(
                      doctor: Doctor(
                        name: doc['name'],
                        specialty: doc['specialty'],
                        imageUrl: doc['imageUrl'],
                        hospital: doc['hospital'],
                        price: doc['price'],
                        rating: doc['rating'],
                        reviews: doc['reviews'], isOnline: true,
                      ),
                    ),
                  ),
                );
              },
            ),

            Text('Select Date', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Select Time', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_selectedDoctorIndex != null && (_selectedDate != null || _selectedTime != null))
                    ? () {
                        final doc = _dummyDoctors[_selectedDoctorIndex!];
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Appointment Booked'),
                            content: Text('Your appointment with ${doc['name']} is booked for '
                                '${_selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : 'No date selected'} at '
                                '${_selectedTime != null ? _selectedTime!.format(context) : 'No time selected'}.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                child: const Text('Confirm Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 