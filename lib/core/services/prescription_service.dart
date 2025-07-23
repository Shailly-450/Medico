import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../config.dart';
import 'auth_service.dart';
import '../../models/prescription.dart';

class PrescriptionService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final String prescriptionEndpoint = '/prescriptions';
  final Duration timeout = const Duration(seconds: 10);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${AuthService.accessToken}',
  };

  // Get all prescriptions
  Future<List<Prescription>> getPrescriptions() async {
    print('Fetching prescriptions...');

    if (AuthService.accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http
        .get(Uri.parse('$baseUrl$prescriptionEndpoint'), headers: _headers)
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => Prescription.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to fetch prescriptions: ${response.statusCode}');
    }
  }

  // Get prescription by ID
  Future<Prescription> getPrescriptionById(String id) async {
    print('Fetching prescription $id...');

    if (AuthService.accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http
        .get(Uri.parse('$baseUrl$prescriptionEndpoint/$id'), headers: _headers)
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        return Prescription.fromJson(responseData['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to fetch prescription: ${response.statusCode}');
    }
  }

  // Generate PDF for a prescription
  Future<String> generatePrescriptionPDF(Prescription prescription) async {
    final pdf = pw.Document();

    // Add hospital logo and header
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Medical Prescription',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Prescription ID: ${prescription.id}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Date: ${prescription.prescriptionDate}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Dr. ${prescription.doctorName}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        prescription.doctorSpecialty,
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Patient Information
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Patient Information',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('Name: ${prescription.patientName}'),
                    pw.Text('Age: ${prescription.patientAge} years'),
                    if (prescription.patientGender != null)
                      pw.Text('Gender: ${prescription.patientGender}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Medications
              pw.Text(
                'Prescribed Medications',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerLeft,
                },
                headers: ['Medication', 'Dosage', 'Duration', 'Instructions'],
                data: prescription.medications.map((med) {
                  return [med.name, med.dosage, med.duration, med.instructions];
                }).toList(),
              ),
              pw.SizedBox(height: 20),

              // Additional Instructions
              if (prescription.additionalInstructions != null &&
                  prescription.additionalInstructions!.isNotEmpty) ...[
                pw.Text(
                  'Additional Instructions',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(prescription.additionalInstructions!),
                pw.SizedBox(height: 20),
              ],

              // Follow-up
              if (prescription.followUpDate != null) ...[
                pw.Text(
                  'Follow-up Appointment',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Date: ${prescription.followUpDate}'),
              ],

              // Footer with signature
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 150,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 1)),
                        ),
                        padding: const pw.EdgeInsets.only(top: 8),
                        child: pw.Text(
                          'Doctor\'s Signature',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/prescription_${prescription.id}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  // Download prescription PDF
  Future<String> downloadPrescriptionPDF(String prescriptionId) async {
    print('Downloading prescription PDF $prescriptionId...');

    if (AuthService.accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http
        .get(
          Uri.parse('$baseUrl$prescriptionEndpoint/$prescriptionId/pdf'),
          headers: _headers,
        )
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        final prescription = await getPrescriptionById(prescriptionId);
        return generatePrescriptionPDF(prescription);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception(
        'Failed to download prescription PDF: ${response.statusCode}',
      );
    }
  }
}
