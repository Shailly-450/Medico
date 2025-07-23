import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/invoice.dart';
import '../config.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class InvoiceService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final String invoicesEndpoint = '/invoices';
  final Duration timeout = const Duration(seconds: 10);

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // Fetch all invoices
  Future<List<Invoice>> getInvoices() async {
    print('Fetching invoices...');

    final response = await http
        .get(Uri.parse('$baseUrl$invoicesEndpoint'), headers: _headers)
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Invoice.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch invoices: ${response.statusCode}');
    }
  }

  // Generate PDF for an invoice
  Future<String> generatePdf(String invoiceId) async {
    print('Generating PDF for invoice $invoiceId');

    final response = await http
        .get(
          Uri.parse('$baseUrl$invoicesEndpoint/$invoiceId/pdf'),
          headers: _headers,
        )
        .timeout(timeout);

    if (response.statusCode == 200) {
      // Save the PDF to a temporary file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/invoice_$invoiceId.pdf');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception('Failed to generate PDF: ${response.statusCode}');
    }
  }

  // Mark invoice as paid
  Future<void> markAsPaid(String invoiceId) async {
    print('Marking invoice $invoiceId as paid');

    final response = await http
        .patch(
          Uri.parse('$baseUrl$invoicesEndpoint/$invoiceId/status'),
          headers: _headers,
          body: jsonEncode({'status': 'Paid'}),
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to mark invoice as paid: ${response.statusCode}');
    }
  }

  // Create a new invoice
  Future<Invoice> createInvoice({
    required String type,
    required String provider,
    required double amount,
    required DateTime dueDate,
    required List<Map<String, dynamic>> items,
    String? appointmentId,
  }) async {
    final requestBody = {
      'type': type,
      'provider': provider,
      'amount': amount,
      'dueDate': dueDate.toUtc().toIso8601String(),
      'items': items,
      if (appointmentId != null) 'linkedAppointment': appointmentId,
    };

    print('Creating invoice with body: $requestBody');

    final response = await http
        .post(
          Uri.parse('$baseUrl$invoicesEndpoint'),
          headers: _headers,
          body: jsonEncode(requestBody),
        )
        .timeout(timeout);

    print('API Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 201) {
      return Invoice.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create invoice: ${response.statusCode}');
    }
  }
}
