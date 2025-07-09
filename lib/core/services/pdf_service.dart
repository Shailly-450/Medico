import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../models/prescription.dart';
import '../../models/invoice.dart';
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

  static Future<File> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();

    // Add page with invoice details
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
                    pw.Text('INVOICE',
                        style: pw.TextStyle(
                            fontSize: 28, fontWeight: pw.FontWeight.bold)),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Invoice #${invoice.invoiceNumber}',
                            style: pw.TextStyle(
                                fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Date: ${_formatDate(invoice.issueDate)}',
                            style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('Due: ${_formatDate(invoice.dueDate)}',
                            style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Provider and Patient Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Provider Info
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('From:',
                              style: pw.TextStyle(
                                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 8),
                          pw.Text(invoice.providerName,
                              style: pw.TextStyle(
                                  fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          if (invoice.providerAddress != null)
                            pw.Text(invoice.providerAddress!,
                                style: const pw.TextStyle(fontSize: 12)),
                          if (invoice.providerPhone != null)
                            pw.Text('Phone: ${invoice.providerPhone}',
                                style: const pw.TextStyle(fontSize: 12)),
                          if (invoice.providerEmail != null)
                            pw.Text('Email: ${invoice.providerEmail}',
                                style: const pw.TextStyle(fontSize: 12)),
                          if (invoice.providerTaxId != null)
                            pw.Text('Tax ID: ${invoice.providerTaxId}',
                                style: const pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  // Patient Info
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Bill To:',
                              style: pw.TextStyle(
                                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 8),
                          pw.Text(invoice.patientName,
                              style: pw.TextStyle(
                                  fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Email: ${invoice.patientEmail}',
                              style: const pw.TextStyle(fontSize: 12)),
                          pw.Text('Phone: ${invoice.patientPhone}',
                              style: const pw.TextStyle(fontSize: 12)),
                          if (invoice.patientAddress != null)
                            pw.Text(invoice.patientAddress!,
                                style: const pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Invoice Items Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Description',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Qty',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Unit Price',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Total',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right),
                        ),
                      ],
                    ),
                    // Item rows
                    ...invoice.items.map((item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(item.description,
                                  style: const pw.TextStyle(fontSize: 12)),
                              if (item.notes != null)
                                pw.Text(item.notes!,
                                    style: const pw.TextStyle(
                                        fontSize: 10, color: PdfColors.grey600)),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.quantity.toString(),
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${invoice.currency} ${item.unitPrice.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.right),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${invoice.currency} ${item.totalPrice.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.right),
                        ),
                      ],
                    )).toList(),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Subtotal:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('${invoice.currency} ${invoice.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    if (invoice.tax > 0) ...[
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Tax:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('${invoice.currency} ${invoice.tax.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                    if (invoice.discount > 0) ...[
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Discount:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('-${invoice.currency} ${invoice.discount.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total:',
                            style: pw.TextStyle(
                                fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text('${invoice.currency} ${invoice.total.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                                fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Status and Payment Info
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: _getStatusColor(invoice.status),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Status: ${invoice.statusDisplayName}',
                        style: const pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    if (invoice.paidDate != null)
                      pw.Text('Paid: ${_formatDate(invoice.paidDate!)}',
                          style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Notes and Terms
              if (invoice.notes != null) ...[
                pw.Text('Notes:',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Text(invoice.notes!),
                ),
                pw.SizedBox(height: 15),
              ],

              if (invoice.paymentInstructions != null) ...[
                pw.Text('Payment Instructions:',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Text(invoice.paymentInstructions!),
                ),
                pw.SizedBox(height: 15),
              ],

              if (invoice.terms != null) ...[
                pw.Text('Terms:',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Text(invoice.terms!),
                ),
                pw.SizedBox(height: 15),
              ],

              // Footer
              pw.Divider(),
              pw.Text('This is a computer-generated invoice from Medico App',
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
        '${dir.path}/invoice_${invoice.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    // Save the PDF
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static PdfColor _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return PdfColors.green100;
      case InvoiceStatus.overdue:
        return PdfColors.red100;
      case InvoiceStatus.sent:
        return PdfColors.blue100;
      case InvoiceStatus.draft:
        return PdfColors.grey100;
      case InvoiceStatus.cancelled:
        return PdfColors.grey200;
      case InvoiceStatus.refunded:
        return PdfColors.orange100;
    }
  }
}
