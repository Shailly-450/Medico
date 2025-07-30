import 'package:flutter/material.dart';
import '../../models/prescription.dart';
import '../../viewmodels/prescriptions_view_model.dart';
import '../../viewmodels/family_members_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/views/base_view.dart';
import '../../core/services/auth_service.dart';
import '../../views/profile/family_members_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreatePrescriptionScreen extends StatefulWidget {
  const CreatePrescriptionScreen({Key? key}) : super(key: key);

  @override
  State<CreatePrescriptionScreen> createState() => _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState extends State<CreatePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  final _appointmentIdController = TextEditingController();

  final List<PrescriptionMedicine> _medications = [];
  DateTime? _expiryDate;
  bool _requiresFollowUp = false;
  DateTime? _followUpDate;
  final _followUpReasonController = TextEditingController();

  // Patient selection
  String? _selectedPatientId;
  String? _selectedPatientName;
  String? _selectedPatientRole;

  // Vital signs
  final _bloodPressureController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  // Insurance
  final _insuranceProviderController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _coverageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set current user as default patient
    _selectedPatientId = AuthService.currentUserId;
    _selectedPatientName = AuthService.currentUserName ?? 'Current User';
    _selectedPatientRole = 'Self';
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    _appointmentIdController.dispose();
    _followUpReasonController.dispose();
    _bloodPressureController.dispose();
    _temperatureController.dispose();
    _heartRateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _insuranceProviderController.dispose();
    _policyNumberController.dispose();
    _coverageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FamilyMembersViewModel()),
      ],
      child: BaseView<PrescriptionsViewModel>(
        viewModelBuilder: () => PrescriptionsViewModel()..initialize(),
        builder: (context, model, child) => Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Create Prescription'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientSelectionCard(),
                  const SizedBox(height: 16),
                  _buildBasicInfoCard(),
                  const SizedBox(height: 16),
                  _buildMedicationsCard(),
                  const SizedBox(height: 16),
                  _buildVitalSignsCard(),
                  const SizedBox(height: 16),
                  _buildFollowUpCard(),
                  const SizedBox(height: 16),
                  _buildInsuranceCard(),
                  const SizedBox(height: 16),
                  _buildNotesCard(),
                  const SizedBox(height: 16),
                  _buildSummaryCard(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(model),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientSelectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<FamilyMembersViewModel>(
              builder: (context, familyVM, child) {
                return Column(
                  children: [
                    // Current user option
                    _buildPatientOption(
                      id: AuthService.currentUserId ?? 'current-user',
                      name: AuthService.currentUserName ?? 'Current User',
                      role: 'Self',
                      isSelected: _selectedPatientId == AuthService.currentUserId,
                      onTap: () => _selectPatient(
                        AuthService.currentUserId ?? 'current-user',
                        AuthService.currentUserName ?? 'Current User',
                        'Self',
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Family members
                    ...familyVM.members.map((member) => _buildPatientOption(
                      id: member.id,
                      name: member.name,
                      role: member.role,
                      isSelected: _selectedPatientId == member.id,
                      onTap: () => _selectPatient(member.id, member.name, member.role),
                    )),
                    const SizedBox(height: 8),
                    // Add new family member option
                    InkWell(
                      onTap: () => _showAddFamilyMemberDialog(context, familyVM),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              'Add Family Member',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientOption({
    required String id,
    required String name,
    required String role,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }



  void _selectPatient(String id, String name, String role) {
    setState(() {
      _selectedPatientId = id;
      _selectedPatientName = name;
      _selectedPatientRole = role;
    });
  }

  void _showAddFamilyMemberDialog(BuildContext context, FamilyMembersViewModel familyVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Family Member'),
        content: const Text('This will open the Family Members screen where you can add a new family member.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FamilyMembersScreen(),
                ),
              );
            },
            child: const Text('Go to Family Members'),
          ),
        ],
      ),
    );
  }

  // Helper method to validate patient selection
  bool _isPatientSelected() {
    return _selectedPatientId != null && _selectedPatientId!.isNotEmpty;
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prescription Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Patient', _selectedPatientName ?? 'Not selected'),
            _buildSummaryRow('Diagnosis', _diagnosisController.text.isEmpty ? 'Not specified' : _diagnosisController.text),
            _buildSummaryRow('Medications', '${_medications.length} medication(s)'),
            if (_expiryDate != null)
              _buildSummaryRow('Expiry Date', DateFormat('MMM dd, yyyy').format(_expiryDate!)),
            if (_requiresFollowUp)
              _buildSummaryRow('Follow-up', 'Required'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Selected patient display
            if (_selectedPatientId != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        _selectedPatientName?.isNotEmpty == true 
                            ? _selectedPatientName![0].toUpperCase() 
                            : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPatientName ?? 'Unknown Patient',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _selectedPatientRole ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _appointmentIdController,
              decoration: const InputDecoration(
                labelText: 'Appointment ID (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Diagnosis *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Diagnosis is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectExpiryDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Expiry Date (Optional)',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _expiryDate != null
                      ? DateFormat('MMM dd, yyyy').format(_expiryDate!)
                      : 'Select expiry date',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Medications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Medication'),
                  onPressed: () => _showAddMedicationDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_medications.isEmpty)
              const Center(
                child: Text(
                  'No medications added yet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ..._medications.asMap().entries.map((entry) {
                final index = entry.key;
                final medication = entry.value;
                return _buildMedicationItem(index, medication);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItem(int index, PrescriptionMedicine medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          medication.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${medication.dosage} - ${medication.frequency}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              _medications.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  Widget _buildVitalSignsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vital Signs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bloodPressureController,
                    decoration: const InputDecoration(
                      labelText: 'Blood Pressure',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _temperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Temperature',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heartRateController,
                    decoration: const InputDecoration(
                      labelText: 'Heart Rate',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Height',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Follow-up Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: _requiresFollowUp,
                  onChanged: (value) {
                    setState(() {
                      _requiresFollowUp = value;
                    });
                  },
                ),
              ],
            ),
            if (_requiresFollowUp) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectFollowUpDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Follow-up Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _followUpDate != null
                        ? DateFormat('MMM dd, yyyy').format(_followUpDate!)
                        : 'Select follow-up date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _followUpReasonController,
                decoration: const InputDecoration(
                  labelText: 'Follow-up Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insurance Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _insuranceProviderController,
              decoration: const InputDecoration(
                labelText: 'Insurance Provider',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _policyNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Policy Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _coverageController,
                    decoration: const InputDecoration(
                      labelText: 'Coverage %',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(PrescriptionsViewModel model) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (model.isBusy || !_isPatientSelected()) ? null : () => _submitPrescription(model),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: model.isBusy
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create Prescription',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_selectedPatientName != null)
                    Text(
                      'for ${_selectedPatientName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _selectFollowUpDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _followUpDate = picked;
      });
    }
  }

  void _showAddMedicationDialog(BuildContext context) {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    final durationController = TextEditingController();
    final instructionsController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final refillsController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medication'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name *',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage *',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frequency *',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration *',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: refillsController,
                      decoration: const InputDecoration(
                        labelText: 'Refills',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  dosageController.text.isNotEmpty &&
                  frequencyController.text.isNotEmpty &&
                  durationController.text.isNotEmpty) {
                final medication = PrescriptionMedicine(
                  name: nameController.text,
                  dosage: dosageController.text,
                  frequency: frequencyController.text,
                  duration: durationController.text,
                  instructions: instructionsController.text.isEmpty
                      ? null
                      : instructionsController.text,
                  quantity: int.tryParse(quantityController.text) ?? 1,
                  refills: refillsController.text,
                );
                setState(() {
                  _medications.add(medication);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPrescription(PrescriptionsViewModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one medication is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Clean up the data to remove null values
    final Map<String, dynamic> prescriptionData = {
      'patientId': _selectedPatientId,
      'diagnosis': _diagnosisController.text,
      'medications': _medications.map((med) => med.toJson()).toList(),
    };

    // Add optional fields only if they have values
    if (_appointmentIdController.text.isNotEmpty) {
      prescriptionData['appointmentId'] = _appointmentIdController.text;
    }

    if (_notesController.text.isNotEmpty) {
      prescriptionData['notes'] = _notesController.text;
    }

    if (_expiryDate != null) {
      prescriptionData['expiryDate'] = _expiryDate!.toIso8601String();
    }

    // Add vital signs only if any are provided
    final vitalSigns = <String, dynamic>{};
    if (_bloodPressureController.text.isNotEmpty) {
      vitalSigns['bloodPressure'] = _bloodPressureController.text;
    }
    if (_temperatureController.text.isNotEmpty) {
      vitalSigns['temperature'] = _temperatureController.text;
    }
    if (_heartRateController.text.isNotEmpty) {
      vitalSigns['heartRate'] = _heartRateController.text;
    }
    if (_weightController.text.isNotEmpty) {
      vitalSigns['weight'] = _weightController.text;
    }
    if (_heightController.text.isNotEmpty) {
      vitalSigns['height'] = _heightController.text;
    }
    if (vitalSigns.isNotEmpty) {
      prescriptionData['vitalSigns'] = vitalSigns;
    }

    // Add follow-up only if required
    if (_requiresFollowUp) {
      final followUp = <String, dynamic>{
        'required': true,
      };
      if (_followUpDate != null) {
        followUp['date'] = _followUpDate!.toIso8601String();
      }
      if (_followUpReasonController.text.isNotEmpty) {
        followUp['reason'] = _followUpReasonController.text;
      }
      prescriptionData['followUp'] = followUp;
    }

    // Add insurance only if provider is provided
    if (_insuranceProviderController.text.isNotEmpty) {
      final insurance = <String, dynamic>{
        'provider': _insuranceProviderController.text,
      };
      if (_policyNumberController.text.isNotEmpty) {
        insurance['policyNumber'] = _policyNumberController.text;
      }
      if (_coverageController.text.isNotEmpty) {
        final coverage = double.tryParse(_coverageController.text);
        if (coverage != null) {
          insurance['coverage'] = coverage;
        }
      }
      prescriptionData['insurance'] = insurance;
    }

    final success = await model.createPrescription(prescriptionData);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(model.error?.contains('Backend server is not available') == true 
            ? 'Prescription created locally (backend offline)'
            : 'Prescription created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(model.error ?? 'Failed to create prescription'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 