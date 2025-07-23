import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import '../core/services/invoice_service.dart';
import '../core/viewmodels/base_view_model.dart';
import 'package:open_file/open_file.dart';

class InvoiceViewModel extends BaseViewModel {
  final _service = InvoiceService();
  List<Invoice> _invoices = [];
  String? _error;
  bool _isLoading = false;

  List<Invoice> get invoices => _invoices;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Filter getters
  List<Invoice> get pendingInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.Pending).toList();
  List<Invoice> get paidInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.Paid).toList();
  List<Invoice> get overdueInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.Overdue).toList();

  Future<void> loadInvoices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _invoices = await _service.getInvoices();
    } catch (e) {
      _error = 'Failed to load invoices: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsPaid(String invoiceId) async {
    try {
      await _service.markAsPaid(invoiceId);
      await loadInvoices(); // Reload to get updated status
    } catch (e) {
      _error = 'Failed to mark invoice as paid: $e';
      notifyListeners();
    }
  }

  Future<void> downloadPdf(String invoiceId) async {
    try {
      _error = null;
      notifyListeners();

      final pdfPath = await _service.generatePdf(invoiceId);
      await OpenFile.open(pdfPath);
    } catch (e) {
      _error = 'Failed to download invoice: $e';
      notifyListeners();
    }
  }

  Future<Invoice?> createInvoice({
    required String type,
    required String provider,
    required double amount,
    required DateTime dueDate,
    required List<Map<String, dynamic>> items,
    String? appointmentId,
  }) async {
    try {
      _error = null;
      notifyListeners();

      final invoice = await _service.createInvoice(
        type: type,
        provider: provider,
        amount: amount,
        dueDate: dueDate,
        items: items,
        appointmentId: appointmentId,
      );

      _invoices.add(invoice);
      notifyListeners();
      return invoice;
    } catch (e) {
      _error = 'Failed to create invoice: $e';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
