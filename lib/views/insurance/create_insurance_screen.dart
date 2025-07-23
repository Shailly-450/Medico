import 'package:flutter/material.dart';
import '../../models/insurance.dart';
import '../../viewmodels/insurance_view_model.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateInsuranceScreen extends StatefulWidget {
  final Insurance? insurance;

  const CreateInsuranceScreen({Key? key, this.insurance}) : super(key: key);

  @override
  State<CreateInsuranceScreen> createState() => _CreateInsuranceScreenState();
}

class _CreateInsuranceScreenState extends State<CreateInsuranceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _providerController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _policyHolderController = TextEditingController();

  DateTime _validFrom = DateTime.now();
  DateTime _validTo = DateTime.now().add(const Duration(days: 365));
  File? _insuranceCardFile;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.insurance != null) {
      _providerController.text = widget.insurance!.insuranceProvider;
      _policyNumberController.text = widget.insurance!.policyNumber;
      _policyHolderController.text = widget.insurance!.policyHolderName;
      _validFrom = widget.insurance!.validFrom;
      _validTo = widget.insurance!.validTo;
    }
  }

  @override
  void dispose() {
    _providerController.dispose();
    _policyNumberController.dispose();
    _policyHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.insurance == null ? 'Add Insurance' : 'Edit Insurance',
        ),
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

            // Insurance Provider
            TextFormField(
              controller: _providerController,
              decoration: const InputDecoration(
                labelText: 'Insurance Provider*',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Policy Number
            TextFormField(
              controller: _policyNumberController,
              decoration: const InputDecoration(
                labelText: 'Policy Number*',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Policy Holder Name
            TextFormField(
              controller: _policyHolderController,
              decoration: const InputDecoration(
                labelText: 'Policy Holder Name*',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Valid From Date
            ListTile(
              title: Text(
                'Valid From: ${_validFrom.day}/${_validFrom.month}/${_validFrom.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 16),

            // Valid To Date
            ListTile(
              title: Text(
                'Valid To: ${_validTo.day}/${_validTo.month}/${_validTo.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 16),

            // Insurance Card Upload
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insurance Card',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_insuranceCardFile != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _insuranceCardFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _insuranceCardFile = null;
                                });
                              },
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (widget.insurance?.insuranceCard != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.insurance!.insuranceCard!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.edit),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Insurance Card'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isValidFrom) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isValidFrom ? _validFrom : _validTo,
      firstDate: isValidFrom ? DateTime(2000) : _validFrom,
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        if (isValidFrom) {
          _validFrom = date;
          if (_validTo.isBefore(_validFrom)) {
            _validTo = _validFrom.add(const Duration(days: 365));
          }
        } else {
          _validTo = date;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _insuranceCardFile = File(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final viewModel = context.read<InsuranceViewModel>();
      bool success;

      if (widget.insurance == null) {
        final insurance = await viewModel.createInsurance(
          insuranceProvider: _providerController.text,
          policyNumber: _policyNumberController.text,
          policyHolderName: _policyHolderController.text,
          validFrom: _validFrom,
          validTo: _validTo,
          insuranceCardFile: _insuranceCardFile,
        );
        success = insurance != null;
      } else {
        final insurance = await viewModel.updateInsurance(
          insuranceId: widget.insurance!.id,
          insuranceProvider: _providerController.text,
          policyNumber: _policyNumberController.text,
          policyHolderName: _policyHolderController.text,
          validFrom: _validFrom,
          validTo: _validTo,
          insuranceCardFile: _insuranceCardFile,
        );
        success = insurance != null;
      }

      if (success && mounted) {
        Navigator.pop(context, true);
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
