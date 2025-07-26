import 'package:flutter/material.dart';
import '../../../models/prescription.dart';
import '../../../core/services/prescription_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final Prescription prescription;
  final PrescriptionService _prescriptionService = PrescriptionService();

  PrescriptionDetailScreen({
    Key? key,
    required this.prescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePrescription(context),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _downloadPdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              title: 'Doctor Information',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dr. ${prescription.doctorName}'),
                  const SizedBox(height: 4),
                  Text(
                    prescription.doctorSpecialty,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Patient Information',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prescription.patientName),
                  const SizedBox(height: 4),
                  Text(
                    'Age: ${prescription.patientAge}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Diagnosis',
              content: Text(prescription.diagnosis),
            ),
            const SizedBox(height: 16),
            const Text(
              'Medications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...prescription.medications.map((med) => _buildMedicineCard(med)),
            if (prescription.notes != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: 'Notes',
                content: Text(prescription.notes!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(PrescriptionMedicine medicine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicine.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildMedicineInfo('Dosage', medicine.dosage),
            _buildMedicineInfo('Frequency', medicine.frequency),
            _buildMedicineInfo('Duration', medicine.duration),
            if (medicine.instructions != null)
              _buildMedicineInfo('Instructions', medicine.instructions!),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final pdfUrl = await _prescriptionService.generatePrescriptionPdf(
        prescription.id,
      );

      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening PDF...')),
        );
      } else {
        throw 'Could not open PDF';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _sharePrescription(BuildContext context) async {
    try {
      final pdfUrl =
          await _prescriptionService.generatePrescriptionPdf(prescription.id);
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share using your device...')),
        );
      } else {
        throw 'Could not share prescription';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
