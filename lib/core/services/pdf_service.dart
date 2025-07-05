import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../models/prescription.dart';
import 'package:open_file/open_file.dart';

class PdfService {
  static Future<File> generatePrescriptionPdf(Prescription prescription) async {
    final pdf = pw.Document();

    // Add page with prescription details
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Medical Prescription',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('ID: ${prescription.id}',
                        style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Doctor Info
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Dr. ${prescription.doctorName}',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text(prescription.doctorSpecialty,
                        style: const pw.TextStyle(fontSize: 14)),
                    pw.Text(
                        'Date: ${prescription.prescriptionDate.day}/${prescription.prescriptionDate.month}/${prescription.prescriptionDate.year}',
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Diagnosis
              pw.Text('Diagnosis:',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Text(prescription.diagnosis),
              ),
              pw.SizedBox(height: 20),

              // Medications
              pw.Text('Medications:',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...prescription.medications.map((medication) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(medication.name,
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Dosage: ${medication.dosage}'),
                      pw.Text('Frequency: ${medication.frequency}'),
                      pw.Text('Duration: ${medication.duration}'),
                      if (medication.instructions != null)
                        pw.Text('Instructions: ${medication.instructions}'),
                    ],
                  ),
                );
              }).toList(),

              // Notes if available
              if (prescription.notes != null) ...[
                pw.SizedBox(height: 20),
                pw.Text('Notes:',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Text(prescription.notes!),
                ),
              ],

              // Footer
              pw.SizedBox(height: 40),
              pw.Divider(),
              pw.Text('This is a computer-generated prescription',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700)),
            ],
          );
        },
      ),
    );

    // Get the application documents directory
    final dir = await getApplicationDocumentsDirectory();
    final String filePath =
        '${dir.path}/prescription_${prescription.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    // Save the PDF
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<void> openPdf(File file) async {
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      throw Exception('Could not open PDF: ${result.message}');
    }
  }
}
