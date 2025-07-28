import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/health_record.dart';
import '../../viewmodels/health_records_view_model.dart';
import '../../core/services/health_record_service.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({Key? key}) : super(key: key);

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeViewModel();
  }

  Future<void> _initializeViewModel() async {
    developer.log('🔍 HealthRecordsScreen: _initializeViewModel called',
        name: 'HealthRecordsScreen');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    developer.log(
        '🔍 HealthRecordsScreen: Token from SharedPreferences: ${token != null ? '${token.substring(0, 10)}...' : 'null'}',
        name: 'HealthRecordsScreen');

    if (token == null) {
      developer.log(
          '❌ HealthRecordsScreen: No token found, showing authentication error',
          name: 'HealthRecordsScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication required')));
      }
      return;
    }

    if (mounted) {
      developer.log(
          '🔍 HealthRecordsScreen: Initializing HealthRecordService with token',
          name: 'HealthRecordsScreen');
      final viewModel = context.read<HealthRecordsViewModel>();
      viewModel.init(HealthRecordService(token));
      developer.log('🔍 HealthRecordsScreen: Calling loadHealthRecords',
          name: 'HealthRecordsScreen');
      viewModel.loadHealthRecords();
    } else {
      developer.log(
          '❌ HealthRecordsScreen: Widget not mounted, cannot initialize',
          name: 'HealthRecordsScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi),
            onPressed: () async {
              final viewModel = context.read<HealthRecordsViewModel>();
              await viewModel.testBackendConnection();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Backend connection test - check console')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () async {
              final viewModel = context.read<HealthRecordsViewModel>();
              await viewModel.testCreateHealthRecord();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Test record creation attempted - check console')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              final viewModel = context.read<HealthRecordsViewModel>();
              viewModel.debugPrintState();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Debug info printed to console')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRecordDialog(context),
          ),
        ],
      ),
      body: Consumer<HealthRecordsViewModel>(
        builder: (context, viewModel, child) {
          developer.log(
              '🔍 HealthRecordsScreen: Consumer rebuild - isLoading: ${viewModel.isLoading}, error: ${viewModel.error}, records: ${viewModel.filteredRecords.length}',
              name: 'HealthRecordsScreen');

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search records...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.setSearchQuery('');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: viewModel.setSearchQuery,
                ),
              ),
              _buildFilterRow(viewModel),
              if (viewModel.isLoading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (viewModel.error != null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        viewModel.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                )
              else if (viewModel.filteredRecords.isEmpty)
                const Expanded(
                  child: Center(child: Text('No records found')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = viewModel.filteredRecords[index];
                      return _buildHealthRecordCard(
                        context,
                        record,
                        () => _showRecordDetails(context, record),
                        () => viewModel.deleteRecord(record.id),
                        (isImportant) =>
                            viewModel.markAsImportant(record.id, isImportant),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterRow(HealthRecordsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: viewModel.selectedCategory,
              isExpanded: true,
              items: viewModel.categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) => viewModel.setCategory(value!),
            ),
          ),
          IconButton(
            icon: Icon(
              viewModel.showImportantOnly ? Icons.star : Icons.star_border,
              color: viewModel.showImportantOnly ? Colors.amber : null,
            ),
            onPressed: viewModel.toggleImportantOnly,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecordCard(
    BuildContext context,
    HealthRecord record,
    VoidCallback onTap,
    VoidCallback onDelete,
    Function(bool) onToggleImportant,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    context
                        .read<HealthRecordsViewModel>()
                        .getCategoryIcon(record.category),
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      record.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      record.isImportant ? Icons.star : Icons.star_border,
                      color: record.isImportant ? Colors.amber : null,
                    ),
                    onPressed: () => onToggleImportant(!record.isImportant),
                  ),
                ],
              ),
              if (record.description != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  record.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    record.category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                  TextButton(
                    onPressed: onDelete,
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordDetails(BuildContext context, HealthRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Date: ${context.read<HealthRecordsViewModel>().formatDate(record.date)}'),
              if (record.description != null) ...[
                const SizedBox(height: 8.0),
                Text(record.description!),
              ],
              if (record.provider != null) ...[
                const SizedBox(height: 8.0),
                Text('Provider: ${record.provider}'),
              ],
              if (record.status != null) ...[
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Text('Status: '),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: context
                            .read<HealthRecordsViewModel>()
                            .getStatusColor(record.status!)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        record.status!,
                        style: TextStyle(
                          color: context
                              .read<HealthRecordsViewModel>()
                              .getStatusColor(record.status!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddRecordForm(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class AddRecordForm extends StatefulWidget {
  const AddRecordForm({Key? key}) : super(key: key);

  @override
  State<AddRecordForm> createState() => _AddRecordFormState();
}

class _AddRecordFormState extends State<AddRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _providerController = TextEditingController();
  final _notesController = TextEditingController();

  // Medical History Fields
  final _conditionController = TextEditingController();
  final _severityController = TextEditingController();
  final _statusController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _medicalNotesController = TextEditingController();

  // Allergy Fields
  final _allergenController = TextEditingController();
  final _reactionController = TextEditingController();
  final _allergySeverityController = TextEditingController();
  final _allergyMedicationsController = TextEditingController();

  // Medication Fields
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _medicationReasonController = TextEditingController();
  final _sideEffectsController = TextEditingController();

  // Lab Results Fields
  final _testNameController = TextEditingController();
  final _testResultController = TextEditingController();
  final _testUnitController = TextEditingController();
  final _referenceRangeController = TextEditingController();
  final _labNameController = TextEditingController();

  // Imaging Fields
  final _imagingTypeController = TextEditingController();
  final _bodyPartController = TextEditingController();
  final _findingsController = TextEditingController();
  final _radiologistController = TextEditingController();

  // Surgery Fields
  final _procedureController = TextEditingController();
  final _surgeonController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _complicationsController = TextEditingController();
  final _recoveryNotesController = TextEditingController();

  // Family History Fields
  final _relationController = TextEditingController();
  final _familyConditionController = TextEditingController();
  final _ageOfOnsetController = TextEditingController();

  String _selectedRecordType = 'medical_history';
  DateTime _selectedDate = DateTime.now();
  DateTime? _medicationStartDate;
  DateTime? _medicationEndDate;
  bool _isPrivate = false;
  bool _isImportant = false;

  final List<String> _recordTypes = [
    'medical_history',
    'allergies',
    'medications',
    'immunizations',
    'lab_results',
    'imaging',
    'surgery',
    'family_history',
  ];

  final List<String> _severityLevels = [
    'mild',
    'moderate',
    'severe',
    'life-threatening'
  ];
  final List<String> _statusLevels = ['active', 'resolved', 'chronic'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _providerController.dispose();
    _notesController.dispose();

    // Medical History
    _conditionController.dispose();
    _severityController.dispose();
    _statusController.dispose();
    _treatmentController.dispose();
    _medicalNotesController.dispose();

    // Allergies
    _allergenController.dispose();
    _reactionController.dispose();
    _allergySeverityController.dispose();
    _allergyMedicationsController.dispose();

    // Medications
    _medicationNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _medicationReasonController.dispose();
    _sideEffectsController.dispose();

    // Lab Results
    _testNameController.dispose();
    _testResultController.dispose();
    _testUnitController.dispose();
    _referenceRangeController.dispose();
    _labNameController.dispose();

    // Imaging
    _imagingTypeController.dispose();
    _bodyPartController.dispose();
    _findingsController.dispose();
    _radiologistController.dispose();

    // Surgery
    _procedureController.dispose();
    _surgeonController.dispose();
    _hospitalController.dispose();
    _complicationsController.dispose();
    _recoveryNotesController.dispose();

    // Family History
    _relationController.dispose();
    _familyConditionController.dispose();
    _ageOfOnsetController.dispose();

    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<HealthRecordsViewModel>();

      // Build medical history data
      Map<String, dynamic>? medicalHistory;
      if (_conditionController.text.isNotEmpty) {
        medicalHistory = {
          'condition': _conditionController.text,
          'severity': _severityController.text.isNotEmpty
              ? _severityController.text
              : 'mild',
          'status': _statusController.text.isNotEmpty
              ? _statusController.text
              : 'active',
          'treatment': _treatmentController.text,
          'notes': _medicalNotesController.text,
        };
      }

      // Build allergies data
      Map<String, dynamic>? allergies;
      if (_allergenController.text.isNotEmpty) {
        allergies = {
          'allergen': _allergenController.text,
          'reaction': _reactionController.text,
          'severity': _allergySeverityController.text.isNotEmpty
              ? _allergySeverityController.text
              : 'mild',
          'medications': _allergyMedicationsController.text.isNotEmpty
              ? _allergyMedicationsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .toList()
              : [],
        };
      }

      // Build medications data
      Map<String, dynamic>? medications;
      if (_medicationNameController.text.isNotEmpty) {
        medications = {
          'name': _medicationNameController.text,
          'dosage': _dosageController.text,
          'frequency': _frequencyController.text,
          'startDate': _medicationStartDate?.toIso8601String(),
          'endDate': _medicationEndDate?.toIso8601String(),
          'reason': _medicationReasonController.text,
          'sideEffects': _sideEffectsController.text.isNotEmpty
              ? _sideEffectsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .toList()
              : [],
        };
      }

      // Build lab results data
      Map<String, dynamic>? labResults;
      if (_testNameController.text.isNotEmpty) {
        labResults = {
          'testName': _testNameController.text,
          'result': _testResultController.text,
          'unit': _testUnitController.text,
          'referenceRange': _referenceRangeController.text,
          'labName': _labNameController.text,
        };
      }

      // Build imaging data
      Map<String, dynamic>? imaging;
      if (_imagingTypeController.text.isNotEmpty) {
        imaging = {
          'type': _imagingTypeController.text,
          'bodyPart': _bodyPartController.text,
          'findings': _findingsController.text,
          'radiologist': _radiologistController.text,
        };
      }

      // Build surgery data
      Map<String, dynamic>? surgery;
      if (_procedureController.text.isNotEmpty) {
        surgery = {
          'procedure': _procedureController.text,
          'surgeon': _surgeonController.text,
          'hospital': _hospitalController.text,
          'complications': _complicationsController.text,
          'recoveryNotes': _recoveryNotesController.text,
        };
      }

      // Build family history data
      Map<String, dynamic>? familyHistory;
      if (_relationController.text.isNotEmpty) {
        familyHistory = {
          'relation': _relationController.text,
          'condition': _familyConditionController.text,
          'ageOfOnset': _ageOfOnsetController.text.isNotEmpty
              ? int.tryParse(_ageOfOnsetController.text)
              : null,
        };
      }

      // Create the health record
      final record = HealthRecord.create(
        patientId: 'current-user-id', // This should come from auth service
        recordType: _selectedRecordType,
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        date: _selectedDate,
        medicalHistory: medicalHistory,
        allergies: allergies,
        medications: medications,
        labResults: labResults,
        imaging: imaging,
        surgery: surgery,
        familyHistory: familyHistory,
        isPrivate: _isPrivate,
        isImportant: _isImportant,
        provider: _providerController.text.isNotEmpty
            ? _providerController.text
            : null,
        createdBy: 'current-user-id', // This should come from auth service
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      developer.log(
          '🔍 AddRecordForm: Creating new health record: ${record.toJson()}',
          name: 'AddRecordForm');

      // Add the record
      viewModel.addRecord(record).then((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health record added successfully')),
        );
      }).catchError((error) {
        developer.log('❌ AddRecordForm: Error adding record: $error',
            name: 'AddRecordForm');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add record: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Health Record'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedRecordType,
                  decoration: const InputDecoration(
                    labelText: 'Record Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _recordTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.replaceAll('_', ' ').toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRecordType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _providerController,
                  decoration: const InputDecoration(
                    labelText: 'Provider',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Private Record'),
                  subtitle: const Text('Only visible to you'),
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Important'),
                  subtitle: const Text('Mark as important'),
                  value: _isImportant,
                  onChanged: (value) {
                    setState(() {
                      _isImportant = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
