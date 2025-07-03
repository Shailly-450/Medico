import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class InsuranceFormScreen extends StatefulWidget {
  const InsuranceFormScreen({Key? key}) : super(key: key);

  @override
  State<InsuranceFormScreen> createState() => _InsuranceFormScreenState();
}

class _InsuranceFormScreenState extends State<InsuranceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _providerController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _holderNameController = TextEditingController();
  DateTime? _validFrom;
  DateTime? _validTo;
  String? _cardImagePath;

  @override
  void dispose() {
    _providerController.dispose();
    _policyNumberController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool from}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: from ? (_validFrom ?? now) : (_validTo ?? now),
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        if (from) {
          _validFrom = picked;
        } else {
          _validTo = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleBackground,
      appBar: AppBar(
        title: const Text('Insurance Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Insurance Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _providerController,
                      decoration: const InputDecoration(
                        labelText: 'Insurance Provider',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _policyNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Policy Number',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _holderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Policy Holder Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(from: true),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Valid From',
                                  prefixIcon: const Icon(Icons.date_range),
                                ),
                                controller: TextEditingController(
                                  text: _validFrom == null
                                      ? ''
                                      : '${_validFrom!.day}/${_validFrom!.month}/${_validFrom!.year}',
                                ),
                                validator: (v) => _validFrom == null ? 'Required' : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(from: false),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Valid To',
                                  prefixIcon: const Icon(Icons.date_range),
                                ),
                                controller: TextEditingController(
                                  text: _validTo == null
                                      ? ''
                                      : '${_validTo!.day}/${_validTo!.month}/${_validTo!.year}',
                                ),
                                validator: (v) => _validTo == null ? 'Required' : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.upload_file),
                            label: Text(_cardImagePath == null ? 'Upload Card' : 'Change Card'),
                            onPressed: () {
                              // TODO: Implement image picker
                              setState(() {
                                _cardImagePath = 'dummy_path.jpg';
                              });
                            },
                          ),
                        ),
                        if (_cardImagePath != null)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.check_circle, color: AppColors.success),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                // TODO: Save logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Insurance details saved!')),
                                );
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 