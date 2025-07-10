import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/prescription.dart';
import '../../../core/theme/app_colors.dart';
import '../../prescriptions/widgets/prescription_card.dart';
import '../patients/patient_summary_screen.dart';
import '../../../models/patient_record.dart';

class DoctorPrescriptionsPanel extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialty;

  const DoctorPrescriptionsPanel({
    Key? key,
    required this.doctorName,
    this.doctorSpecialty = 'General Physician',
  }) : super(key: key);

  @override
  State<DoctorPrescriptionsPanel> createState() =>
      _DoctorPrescriptionsPanelState();
}

class _DoctorPrescriptionsPanelState extends State<DoctorPrescriptionsPanel> {
  final List<Prescription> _prescriptions = [];

  void _addPrescription(Prescription prescription) {
    setState(() {
      _prescriptions.insert(0, prescription);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prescriptions'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search),
            tooltip: 'Patient Summary',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientSummaryScreen(
                    record: _mockPatientRecord(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () async {
          final newPrescription = await Navigator.push<Prescription>(
            context,
            MaterialPageRoute(
              builder: (context) => _AddPrescriptionScreen(
                doctorName: widget.doctorName,
                doctorSpecialty: widget.doctorSpecialty,
              ),
            ),
          );
          if (newPrescription != null) {
            _addPrescription(newPrescription);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _prescriptions.isEmpty
          ? const Center(
              child: Text('No prescriptions uploaded yet'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _prescriptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final prescription = _prescriptions[index];
                return PrescriptionCard(
                  prescription: prescription,
                  onTap: () {
                    // In real app: open detail view
                  },
                );
              },
            ),
    );
  }

  PatientRecord _mockPatientRecord() {
    return PatientRecord(
      name: 'John Smith',
      age: 35,
      gender: 'Male',
      email: 'john.smith@example.com',
      phone: '+1 (555) 123-4567',
      address: '123 Main Street, City, State',
      insuranceProvider: 'Blue Cross',
      insuranceNumber: 'BC123456',
      emergencyContact: 'Jane Smith - +1 (555) 987-6543',
      medicalHistory: ['Hypertension', 'Diabetes Type 2', 'Appendectomy'],
      currentMedications: ['Metformin', 'Lisinopril', 'Atorvastatin'],
      allergies: ['Penicillin', 'Sulfa drugs'],
      vitals: {
        'Blood Pressure': '120/80 mmHg',
        'Heart Rate': '72 bpm',
        'BMI': '24.5',
      },
      labResults: [
        {'Test': 'CBC', 'Result': 'Normal'},
        {'Test': 'HbA1c', 'Result': '6.5%'},
        {'Test': 'Cholesterol', 'Result': '190 mg/dL'},
      ],
      recentAppointments: [
        '2024-06-15 - General Checkup',
        '2024-05-10 - Endocrinology',
      ],
      recentPrescriptions: [
        'Metformin 500mg',
        'Lisinopril 10mg',
      ],
    );
  }
}

class _AddPrescriptionScreen extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialty;

  const _AddPrescriptionScreen({
    Key? key,
    required this.doctorName,
    required this.doctorSpecialty,
  }) : super(key: key);

  @override
  State<_AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<_AddPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  String? _selectedFilePath;

  @override
  void dispose() {
    _patientNameController.dispose();
    _diagnosisController.dispose();
    _medicationController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      // Optional: ensure a file is selected
      if (_selectedFilePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload a prescription file'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final prescription = Prescription(
        id: const Uuid().v4(),
        patientName: _patientNameController.text.trim(),
        doctorName: widget.doctorName,
        doctorSpecialty: widget.doctorSpecialty,
        prescriptionDate: DateTime.now(),
        diagnosis: _diagnosisController.text.trim(),
        medications: [
          PrescriptionMedication(
            name: _medicationController.text.trim(),
            dosage: _dosageController.text.trim(),
            frequency: _frequencyController.text.trim(),
            duration: _durationController.text.trim(),
            quantity: 1,
            isActive: true,
          ),
        ],
        status: PrescriptionStatus.active,
        prescriptionImageUrl: _selectedFilePath,
      );
      Navigator.pop(context, prescription);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Prescription'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(labelText: 'Diagnosis'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _medicationController,
                decoration: const InputDecoration(labelText: 'Medication Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosageController,
                decoration:
                    const InputDecoration(labelText: 'Dosage (e.g. 500mg)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                    labelText: 'Frequency (e.g. Twice daily)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration:
                    const InputDecoration(labelText: 'Duration (e.g. 7 days)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              // File upload
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedFilePath != null
                          ? _selectedFilePath!.split('/').last
                          : 'No file selected',
                      style: TextStyle(
                        color: _selectedFilePath != null
                            ? AppColors.textBlack
                            : Colors.grey[600],
                        fontStyle: _selectedFilePath != null
                            ? FontStyle.normal
                            : FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: const Text('Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Upload Prescription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFilePath = result.files.first.path;
      });
    }
  }
}
