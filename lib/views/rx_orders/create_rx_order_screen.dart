import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/rx_order_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/rx_order.dart';
import 'widgets/pharmacy_selection_dialog.dart';
import 'widgets/medicine_selection_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import '../../models/medicine.dart';

class CreateRxOrderScreen extends StatefulWidget {
  const CreateRxOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateRxOrderScreen> createState() => _CreateRxOrderScreenState();
}

class _CreateRxOrderScreenState extends State<CreateRxOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNameController = TextEditingController();
  final _doctorLicenseController = TextEditingController();
  final _patientNotesController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insurancePolicyController = TextEditingController();

  Pharmacy? _selectedPharmacy;
  RxOrderType _selectedOrderType = RxOrderType.newPrescription;
  bool _requiresInsurance = false;
  File? _prescriptionFile;
  String? _prescriptionFileType; // 'image' or 'pdf'
  final ImagePicker _picker = ImagePicker();
  bool _isScanning = false;

  @override
  void dispose() {
    _doctorNameController.dispose();
    _doctorLicenseController.dispose();
    _patientNotesController.dispose();
    _insuranceProviderController.dispose();
    _insurancePolicyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<RxOrderViewModel>(
      viewModelBuilder: () => RxOrderViewModel()..initialize(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Create Rx Order'),
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
                _buildOrderTypeSection(),
                const SizedBox(height: 24),
                _buildPharmacySection(model),
                const SizedBox(height: 24),
                _buildMedicineSection(model),
                const SizedBox(height: 24),
                _buildPrescriptionSection(model),
                const SizedBox(height: 24),
                _buildDoctorSection(),
                const SizedBox(height: 24),
                _buildInsuranceSection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 32),
                _buildOrderSummary(model),
                const SizedBox(height: 24),
                _buildSubmitButton(model),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...RxOrderType.values.map((type) => RadioListTile<RxOrderType>(
              title: Text(type.displayName),
              value: type,
              groupValue: _selectedOrderType,
              onChanged: (value) {
                setState(() {
                  _selectedOrderType = value!;
                });
              },
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacySection(RxOrderViewModel model) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Pharmacy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showPharmacySelection(context, model),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_pharmacy,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _selectedPharmacy != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedPharmacy!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedPharmacy!.address,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                if (_selectedPharmacy!.operatingHours != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedPharmacy!.operatingHours!,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            )
                          : Text(
                              'Tap to select a pharmacy',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
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

  Widget _buildMedicineSection(RxOrderViewModel model) {
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
                  'Medicines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showMedicineSelection(context, model),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Medicine'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (model.selectedItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No medicines selected',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "Add Medicine" to start',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...model.selectedItems.map((item) => _buildMedicineItem(item, model)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineItem(RxOrderItem item, RxOrderViewModel model) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medication,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medicine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${item.medicine.dosage} • ${item.medicine.medicineType}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (item.dosage != null)
                  Text(
                    'Dosage: ${item.dosage}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: () {
                      if (item.quantity > 1) {
                        model.updateItemQuantity(item.id, item.quantity - 1);
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () {
                      model.updateItemQuantity(item.id, item.quantity + 1);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Text(
                '₹${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => model.removeItemFromSelection(item.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionSection(RxOrderViewModel model) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prescription',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _showUploadOptions,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _prescriptionFile != null ? Colors.green : Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (_prescriptionFile != null && _prescriptionFileType == 'image')
                      Column(
                        children: [
                          Image.file(
                            _prescriptionFile!,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _removePrescription,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Remove', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      )
                    else if (_prescriptionFile != null && _prescriptionFileType == 'pdf')
                      Column(
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            _prescriptionFile!.path.split('/').last,
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _removePrescription,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Remove', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      )
                    else ...[
                      const Icon(
                        Icons.upload_file,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Upload prescription (photo or PDF)',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to upload prescription photo or PDF',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_prescriptionFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _isScanning
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.document_scanner),
                        label: const Text('Scan Prescription'),
                        onPressed: () => _scanPrescription(model),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  void _showUploadOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _prescriptionFile = File(pickedFile.path);
                    _prescriptionFileType = 'image';
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose Photo'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _prescriptionFile = File(pickedFile.path);
                    _prescriptionFileType = 'image';
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Choose PDF'),
              onTap: () async {
                Navigator.pop(context);
                final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                if (result != null && result.files.single.path != null) {
                  setState(() {
                    _prescriptionFile = File(result.files.single.path!);
                    _prescriptionFileType = 'pdf';
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Doctor Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _doctorNameController,
              decoration: const InputDecoration(
                labelText: 'Doctor Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _doctorLicenseController,
              decoration: const InputDecoration(
                labelText: 'License Number (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: const Text('Use Insurance'),
              value: _requiresInsurance,
              onChanged: (value) {
                setState(() {
                  _requiresInsurance = value!;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (_requiresInsurance) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _insuranceProviderController,
                decoration: const InputDecoration(
                  labelText: 'Insurance Provider',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.health_and_safety),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _insurancePolicyController,
                decoration: const InputDecoration(
                  labelText: 'Policy Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _patientNotesController,
              decoration: const InputDecoration(
                labelText: 'Special instructions or notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(RxOrderViewModel model) {
    final subtotal = model.getTotalPrice();
    final tax = subtotal * 0.08; // 8% tax
    final total = subtotal + tax;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('₹${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax (8%)'),
                Text('₹${tax.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(RxOrderViewModel model) {
    final isValid = _selectedPharmacy != null && model.selectedItems.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid && !model.busy ? () => _submitOrder(model) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: model.busy
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Create Order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _showPharmacySelection(BuildContext context, RxOrderViewModel model) {
    showDialog(
      context: context,
      builder: (context) => PharmacySelectionDialog(
        pharmacies: model.pharmacies,
        selectedPharmacy: _selectedPharmacy,
        onPharmacySelected: (pharmacy) {
          setState(() {
            _selectedPharmacy = pharmacy;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMedicineSelection(BuildContext context, RxOrderViewModel model) {
    showDialog(
      context: context,
      builder: (context) => MedicineSelectionDialog(
        medicines: model.medicines,
        onMedicineSelected: (medicine) {
          final item = RxOrderItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            medicine: medicine,
            quantity: 1,
                    unitPrice: 1199.99, // Mock price in INR
        totalPrice: 1199.99,
          );
          model.addItemToSelection(item);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removePrescription() {
    setState(() {
      _prescriptionFile = null;
      _prescriptionFileType = null;
    });
  }

  Future<void> _scanPrescription(RxOrderViewModel model) async {
    setState(() => _isScanning = true);
    String extractedText = '';
    try {
      if (_prescriptionFileType == 'image') {
        final inputImage = InputImage.fromFile(_prescriptionFile!);
        final textRecognizer = GoogleMlKit.vision.textRecognizer();
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        extractedText = recognizedText.text;
        await textRecognizer.close();
      } else if (_prescriptionFileType == 'pdf') {
        extractedText = await ReadPdfText.getPDFtext(_prescriptionFile!.path);
      }
      if (extractedText.isNotEmpty) {
        _showDetectedMedicinesDialog(extractedText, model);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No text found in prescription.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan prescription: $e')),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  void _showDetectedMedicinesDialog(String text, RxOrderViewModel model) async {
    final allMedicines = model.medicines;
    // Simple matching: check if any medicine name appears in the text
    final List<Medicine> detected = [];
    for (final med in allMedicines) {
      if (text.toLowerCase().contains(med.name.toLowerCase())) {
        detected.add(med);
      }
    }
    if (detected.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Medicines Detected'),
          content: const Text('No known medicines were found in the scanned prescription.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }
    // Let user confirm which medicines to add
    final Set<Medicine> selected = Set<Medicine>.from(detected);
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Detected Medicines'),
          content: SizedBox(
            width: 300,
            child: ListView(
              shrinkWrap: true,
              children: detected.map<Widget>((med) => CheckboxListTile(
                value: selected.contains(med),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selected.add(med);
                    } else {
                      selected.remove(med);
                    }
                  });
                },
                title: Text(med.name),
                subtitle: Text(med.medicineType),
              )).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                for (final med in selected) {
                  final item = RxOrderItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString() + med.id,
                    medicine: med,
                    quantity: 1,
                    unitPrice: 1199.99,
                    totalPrice: 1199.99,
                  );
                  model.addItemToSelection(item);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(' 24{selected.length} medicines added to order.')),
                );
              },
              child: const Text('Add to Order'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitOrder(RxOrderViewModel model) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await model.createRxOrder(
      pharmacyId: _selectedPharmacy!.id,
      items: model.selectedItems,
      orderType: _selectedOrderType,
      prescriptionImageUrl: _prescriptionFile?.path, // Pass file path (image or pdf)
      doctorName: _doctorNameController.text.isEmpty ? null : _doctorNameController.text,
      doctorLicense: _doctorLicenseController.text.isEmpty ? null : _doctorLicenseController.text,
      patientNotes: _patientNotesController.text.isEmpty ? null : _patientNotesController.text,
      requiresInsurance: _requiresInsurance,
      insuranceProvider: _requiresInsurance && _insuranceProviderController.text.isNotEmpty
          ? _insuranceProviderController.text
          : null,
      insurancePolicyNumber: _requiresInsurance && _insurancePolicyController.text.isNotEmpty
          ? _insurancePolicyController.text
          : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rx order created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
} 