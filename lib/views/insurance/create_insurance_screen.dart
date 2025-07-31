import 'package:flutter/material.dart';
import '../../models/insurance.dart';
import '../../viewmodels/insurance_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/views/base_view.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/services/file_upload_service.dart';

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
    return BaseView<InsuranceViewModel>(
      viewModelBuilder: () => InsuranceViewModel(),
      builder: (context, model, child) => Scaffold(
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
                onPressed: () => _save(model),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter insurance provider';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Policy Number
              TextFormField(
                controller: _policyNumberController,
                decoration: const InputDecoration(
                  labelText: 'Policy Number*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter policy number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Policy Holder Name
              TextFormField(
                controller: _policyHolderController,
                decoration: const InputDecoration(
                  labelText: 'Policy Holder Name*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter policy holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Valid From Date
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Valid From*',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_validFrom.day}/${_validFrom.month}/${_validFrom.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Valid To Date
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Valid To*',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_validTo.day}/${_validTo.month}/${_validTo.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Insurance Card Upload
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Insurance Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_insuranceCardFile != null)
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _insuranceCardFile!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Change Image'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 48),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _insuranceCardFile = null;
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Remove'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 48),
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
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
      final file = await FileUploadService.pickImageFromGallery();
      if (file != null) {
        // Validate file size
        if (!FileUploadService.isValidFileSize(file)) {
          setState(() {
            _error = 'File size must be less than 10MB';
          });
          return;
        }
        
        setState(() {
          _insuranceCardFile = file;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _save(InsuranceViewModel model) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? insuranceCardUrl;
      
      // Upload insurance card to Google Drive if selected
      if (_insuranceCardFile != null) {
        final uploadResult = await FileUploadService.uploadInsuranceCard(_insuranceCardFile!);
        
        if (uploadResult['success'] == true) {
          insuranceCardUrl = uploadResult['webContentLink'] as String;
        } else {
          setState(() {
            _error = 'Failed to upload insurance card: ${uploadResult['error']}';
            _isLoading = false;
          });
          return;
        }
      }

      bool success;

      if (widget.insurance == null) {
        final insurance = await model.createInsurance(
          insuranceProvider: _providerController.text,
          policyNumber: _policyNumberController.text,
          policyHolderName: _policyHolderController.text,
          validFrom: _validFrom,
          validTo: _validTo,
          insuranceCardUrl: insuranceCardUrl, // Use Google Drive URL
        );
        success = insurance != null;
      } else {
        final insurance = await model.updateInsurance(
          insuranceId: widget.insurance!.id,
          insuranceProvider: _providerController.text,
          policyNumber: _policyNumberController.text,
          policyHolderName: _policyHolderController.text,
          validFrom: _validFrom,
          validTo: _validTo,
          insuranceCardUrl: insuranceCardUrl, // Use Google Drive URL
        );
        success = insurance != null;
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insurance saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
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
