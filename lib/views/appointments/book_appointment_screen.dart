import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../core/config.dart';
import '../auth/login_screen.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool isSelected;

  const DoctorCard({
    Key? key,
    required this.doctor,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: doctor.profileImage.isNotEmpty
                  ? NetworkImage(doctor.profileImage)
                  : null,
              child: doctor.profileImage.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${doctor.specialty} • ${doctor.consultationFeeFormatted}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: doctor.isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        doctor.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: doctor.isOnline ? Colors.green : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookAppointmentScreen extends StatefulWidget {
  final String? specialty;
  final String? hospitalId;

  const BookAppointmentScreen({Key? key, this.specialty, this.hospitalId})
      : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int? _selectedDoctorIndex;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool _isLoadingDoctors = false;
  String? _errorMessage;
  bool _isVideoCall = false;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _insuranceProviderController =
      TextEditingController();
  final TextEditingController _insuranceNumberController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _accessToken;
  List<Doctor> _doctors = [];
  int _currentPage = 1;
  bool _hasMoreDoctors = true;
  String? _preferredTimeSlot;
  final List<String> _timeSlots = ['morning', 'afternoon', 'evening'];

  @override
  void initState() {
    super.initState();
    _loadAccessToken().then((_) {
      if (_accessToken != null) {
        _fetchDoctors();
      }
    });
  }

  Future<void> _loadAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _accessToken = prefs.getString('accessToken');
      });
    } catch (e) {
      _showError("Failed to load authentication token");
    }
  }

  Future<void> _fetchDoctors() async {
    if (!_hasMoreDoctors || _isLoadingDoctors) return;

    setState(() {
      _isLoadingDoctors = true;
      _errorMessage = null;
    });

    try {
      final queryParams = {
        'page': _currentPage.toString(),
        'limit': '10',
        if (widget.specialty != null) 'specialty': widget.specialty!,
        if (widget.hospitalId != null) 'hospital': widget.hospitalId!,
        if (_searchController.text.isNotEmpty) 'search': _searchController.text,
      };

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/doctors').replace(
          queryParameters: queryParams,
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> doctorsJson = responseData['data'];
          final List<Doctor> newDoctors =
              doctorsJson.map((doc) => Doctor.fromJson(doc)).toList();

        setState(() {
          _doctors.addAll(newDoctors);
          _hasMoreDoctors = newDoctors.length >= 10;
          _currentPage++;
          _isLoadingDoctors = false;
        });
      } else {
        throw Exception('Failed to load doctors: ${response.body}');
      }
    } else {
      throw Exception('Failed to load doctors: ${response.body}');
    }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingDoctors = false;
      });
    }
  }

  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildTimeSlotSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Time Slot (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _timeSlots.map((slot) {
            return ChoiceChip(
              label: Text(slot[0].toUpperCase() + slot.substring(1)),
              selected: _preferredTimeSlot == slot,
              onSelected: (selected) {
                setState(() {
                  _preferredTimeSlot = selected ? slot : null;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _bookAppointment() async {
    if (_accessToken == null) {
      _showError("Authentication required. Please login.");
      _redirectToLogin();
      return;
    }

    if (_selectedDoctorIndex == null) {
      _showError("Please select a doctor");
      return;
    }

    final selectedDoctor = _doctors[_selectedDoctorIndex!];
    if (selectedDoctor.id.isEmpty) {
      _showError("Invalid doctor selection");
      return;
    }

    if (_selectedDate == null) {
      _showError("Please select a date");
      return;
    }

    if (_selectedTime == null) {
      _showError("Please select a time");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appointment = Appointment(
        id: '',
        doctorId: selectedDoctor.id,
        doctorName: selectedDoctor.name,
        doctorImage: selectedDoctor.imageUrl,
        specialty: selectedDoctor.specialty,
        isVideoCall: _isVideoCall,
        date: _selectedDate!.toIso8601String(),
        time: _selectedTime!.format(context),
        appointmentType: 'consultation',
        reason: _reasonController.text.trim(),
        symptoms: _symptomsController.text.trim().isNotEmpty
            ? _symptomsController.text.trim().split(',')
            : null,
        insuranceProvider: _insuranceProviderController.text.trim(),
        insuranceNumber: _insuranceNumberController.text.trim(),
        preferredTimeSlot: _preferredTimeSlot, // Can be null
        status: 'scheduled',
        preApprovalStatus: 'pending',
      );

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode(appointment.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        _showSuccessDialog(Appointment.fromJson(responseData));
      } else {
        throw Exception('Failed to book appointment: ${response.body}');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Booked'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Doctor: ${appointment.doctorName}'),
              const SizedBox(height: 8),
              Text('Specialty: ${appointment.specialty}'),
              const SizedBox(height: 8),
              Text('Date: ${_formatDate(appointment.date)}'),
              const SizedBox(height: 8),
              Text('Time: ${appointment.time}'),
              const SizedBox(height: 8),
              Text(
                  'Type: ${appointment.isVideoCall ? 'Video Call' : 'In-Person'}'),
              if (_preferredTimeSlot != null) ...[
                const SizedBox(height: 8),
                Text('Preferred Time: ${_preferredTimeSlot!.capitalize()}'),
              ],
              const SizedBox(height: 16),
              const Text('You will receive a confirmation shortly.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search doctors...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _refreshDoctors();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: (value) => _refreshDoctors(),
      ),
    );
  }

  void _refreshDoctors() {
    setState(() {
      _currentPage = 1;
      _doctors.clear();
      _hasMoreDoctors = true;
    });
    _fetchDoctors();
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: _isLoadingDoctors
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _fetchDoctors,
                child: const Text('Load More Doctors'),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  _buildSearchBar(),
                  Text('Select Doctor',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_doctors.isEmpty && _isLoadingDoctors)
                    const Center(child: CircularProgressIndicator())
                  else if (_doctors.isEmpty)
                    const Center(child: Text('No doctors available'))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _doctors.length + (_hasMoreDoctors ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index == _doctors.length) {
                          return _buildLoadMoreButton();
                        }
                        final doctor = _doctors[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedDoctorIndex = index);
                          },
                          child: DoctorCard(
                            doctor: doctor,
                            isSelected: _selectedDoctorIndex == index,
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  Text('Appointment Type',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('In-Person'),
                          selected: !_isVideoCall,
                          onSelected: (selected) {
                            setState(() => _isVideoCall = !selected);
                          },
                          selectedColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Video Call'),
                          selected: _isVideoCall,
                          onSelected: (selected) {
                            setState(() => _isVideoCall = selected);
                          },
                          selectedColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Appointment Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason for visit (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _symptomsController,
                    decoration: InputDecoration(
                      labelText: 'Symptoms (comma separated, optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Text('Date & Time',
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
                              : _formatDate(_selectedDate!.toIso8601String())),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(_selectedTime == null
                              ? 'Choose Time'
                              : _selectedTime!.format(context)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTimeSlotSelector(),
                  Text('Insurance Information (optional)',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _insuranceProviderController,
                    decoration: InputDecoration(
                      labelText: 'Insurance Provider',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _insuranceNumberController,
                    decoration: InputDecoration(
                      labelText: 'Insurance Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                onPressed: _isLoading ? null : _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Appointment'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _symptomsController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
