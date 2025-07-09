import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../models/order.dart';
import '../models/rx_order.dart';
import '../core/services/pdf_service.dart';
import 'dart:io';
import '../core/viewmodels/base_view_model.dart';

class InvoiceViewModel extends BaseViewModel {
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _error;
  Invoice? _selectedInvoice;

  // Getters
  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Invoice? get selectedInvoice => _selectedInvoice;

  // Filtered lists
  List<Invoice> get paidInvoices => _invoices.where((inv) => inv.isPaid).toList();
  List<Invoice> get pendingInvoices => _invoices.where((inv) => !inv.isPaid && !inv.isCancelled).toList();
  List<Invoice> get overdueInvoices => _invoices.where((inv) => inv.isOverdue).toList();
  List<Invoice> get dueSoonInvoices => _invoices.where((inv) => inv.isDueSoon).toList();
  
  // Tax and claim filtered lists
  List<Invoice> get taxDeductibleInvoices => _invoices.where((inv) => inv.isTaxDeductible).toList();
  List<Invoice> get claimableInvoices => _invoices.where((inv) => inv.isClaimable).toList();
  List<Invoice> get paidTaxDeductibleInvoices => _invoices.where((inv) => inv.isTaxDeductible && inv.isPaid).toList();
  List<Invoice> get paidClaimableInvoices => _invoices.where((inv) => inv.isClaimable && inv.isPaid).toList();
  
  // Tax and claim totals
  double get totalTaxDeductibleAmount => _invoices.fold(0.0, (sum, inv) => sum + inv.taxDeductibleAmount);
  double get totalClaimableAmount => _invoices.fold(0.0, (sum, inv) => sum + inv.claimableAmount);
  double get paidTaxDeductibleAmount => paidTaxDeductibleInvoices.fold(0.0, (sum, inv) => sum + inv.taxDeductibleAmount);
  double get paidClaimableAmount => paidClaimableInvoices.fold(0.0, (sum, inv) => sum + inv.claimableAmount);

  // Initialize with mock data
  void initialize() {
    _loadMockInvoices();
  }

  void _loadMockInvoices() {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _invoices = _generateMockInvoices();
      _isLoading = false;
      notifyListeners();
    });
  }

  List<Invoice> _generateMockInvoices() {
    return [
      Invoice(
        id: 'inv_001',
        invoiceNumber: 'INV-2024-001',
        patientId: 'patient_001',
        patientName: 'John Doe',
        patientEmail: 'john.doe@email.com',
        patientPhone: '+91 98765 43210',
        patientAddress: '123 Main Street, Mumbai, Maharashtra 400001',
        providerId: 'hospital_001',
        providerName: 'City General Hospital',
        providerAddress: '456 Hospital Road, Mumbai, Maharashtra 400002',
        providerPhone: '+91 22 1234 5678',
        providerEmail: 'billing@cityhospital.com',
        providerTaxId: 'TAX123456789',
        type: InvoiceType.medicalService,
        status: InvoiceStatus.paid,
        issueDate: DateTime.now().subtract(const Duration(days: 15)),
        dueDate: DateTime.now().add(const Duration(days: 15)),
        paidDate: DateTime.now().subtract(const Duration(days: 10)),
        items: [
          InvoiceItem(
            id: 'item_001',
            description: 'General Consultation',
            quantity: 1,
            unitPrice: 1500.0,
            totalPrice: 1500.0,
          ),
          InvoiceItem(
            id: 'item_002',
            description: 'Blood Test Package',
            quantity: 1,
            unitPrice: 2500.0,
            totalPrice: 2500.0,
          ),
        ],
        subtotal: 4000.0,
        tax: 720.0,
        discount: 200.0,
        total: 4520.0,
        currency: 'INR',
        notes: 'Payment received via online transfer',
        terms: 'Payment due within 30 days of invoice date',
        paymentInstructions: 'Please pay via online banking or visit our billing counter',
        isTaxDeductible: true,
        isClaimable: true,
      ),
      Invoice(
        id: 'inv_002',
        invoiceNumber: 'INV-2024-002',
        patientId: 'patient_001',
        patientName: 'John Doe',
        patientEmail: 'john.doe@email.com',
        patientPhone: '+91 98765 43210',
        patientAddress: '123 Main Street, Mumbai, Maharashtra 400001',
        providerId: 'pharmacy_001',
        providerName: 'MedPlus Pharmacy',
        providerAddress: '789 Pharmacy Lane, Mumbai, Maharashtra 400003',
        providerPhone: '+91 22 9876 5432',
        providerEmail: 'orders@medplus.com',
        providerTaxId: 'TAX987654321',
        type: InvoiceType.prescription,
        status: InvoiceStatus.sent,
        issueDate: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 25)),
        items: [
          InvoiceItem(
            id: 'item_003',
            description: 'Paracetamol 500mg',
            quantity: 2,
            unitPrice: 150.0,
            totalPrice: 300.0,
            notes: 'Take 1 tablet every 6 hours',
          ),
          InvoiceItem(
            id: 'item_004',
            description: 'Vitamin D3 1000IU',
            quantity: 1,
            unitPrice: 450.0,
            totalPrice: 450.0,
            notes: 'Take 1 capsule daily',
          ),
        ],
        subtotal: 750.0,
        tax: 135.0,
        discount: 0.0,
        total: 885.0,
        currency: 'INR',
        notes: 'Prescription verified by Dr. Smith',
        terms: 'Payment due within 30 days of invoice date',
        paymentInstructions: 'Pay at pharmacy counter or online',
        isTaxDeductible: true,
        isClaimable: true,
      ),
      Invoice(
        id: 'inv_003',
        invoiceNumber: 'INV-2024-003',
        patientId: 'patient_001',
        patientName: 'John Doe',
        patientEmail: 'john.doe@email.com',
        patientPhone: '+91 98765 43210',
        patientAddress: '123 Main Street, Mumbai, Maharashtra 400001',
        providerId: 'hospital_002',
        providerName: 'Specialty Medical Center',
        providerAddress: '321 Medical Plaza, Mumbai, Maharashtra 400004',
        providerPhone: '+91 22 5555 6666',
        providerEmail: 'billing@specialty.com',
        providerTaxId: 'TAX555666777',
        type: InvoiceType.consultation,
        status: InvoiceStatus.overdue,
        issueDate: DateTime.now().subtract(const Duration(days: 45)),
        dueDate: DateTime.now().subtract(const Duration(days: 15)),
        items: [
          InvoiceItem(
            id: 'item_005',
            description: 'Cardiology Consultation',
            quantity: 1,
            unitPrice: 3000.0,
            totalPrice: 3000.0,
          ),
          InvoiceItem(
            id: 'item_006',
            description: 'ECG Test',
            quantity: 1,
            unitPrice: 1200.0,
            totalPrice: 1200.0,
          ),
        ],
        subtotal: 4200.0,
        tax: 756.0,
        discount: 0.0,
        total: 4956.0,
        currency: 'INR',
        notes: 'Urgent payment required',
        terms: 'Payment due within 30 days of invoice date',
        paymentInstructions: 'Please contact billing department immediately',
        isTaxDeductible: true,
        isClaimable: true,
      ),
      // Add a non-tax deductible invoice example
      Invoice(
        id: 'inv_004',
        invoiceNumber: 'INV-2024-004',
        patientId: 'patient_001',
        patientName: 'John Doe',
        patientEmail: 'john.doe@email.com',
        patientPhone: '+91 98765 43210',
        patientAddress: '123 Main Street, Mumbai, Maharashtra 400001',
        providerId: 'spa_001',
        providerName: 'Wellness Spa Center',
        providerAddress: '789 Wellness Street, Mumbai, Maharashtra 400005',
        providerPhone: '+91 22 7777 8888',
        providerEmail: 'info@wellnessspa.com',
        providerTaxId: 'TAX777888999',
        type: InvoiceType.other,
        status: InvoiceStatus.paid,
        issueDate: DateTime.now().subtract(const Duration(days: 20)),
        dueDate: DateTime.now().add(const Duration(days: 10)),
        paidDate: DateTime.now().subtract(const Duration(days: 18)),
        items: [
          InvoiceItem(
            id: 'item_007',
            description: 'Relaxation Massage',
            quantity: 1,
            unitPrice: 2000.0,
            totalPrice: 2000.0,
            notes: '60-minute session',
          ),
        ],
        subtotal: 2000.0,
        tax: 360.0,
        discount: 0.0,
        total: 2360.0,
        currency: 'INR',
        notes: 'Wellness service - not medically necessary',
        terms: 'Payment due within 30 days of invoice date',
        paymentInstructions: 'Pay at spa counter or online',
        isTaxDeductible: false, // Wellness services are typically not tax deductible
        isClaimable: false, // Wellness services are typically not claimable
      ),
    ];
  }

  // Create invoice from order
  Invoice createInvoiceFromOrder(Order order, String patientName, String patientEmail, String patientPhone) {
    final invoice = Invoice.fromOrder(order, patientName, patientEmail, patientPhone);
    _invoices.add(invoice);
    notifyListeners();
    return invoice;
  }

  // Create invoice from prescription order
  Invoice createInvoiceFromRxOrder(RxOrder order, String patientName, String patientEmail, String patientPhone) {
    final invoice = Invoice.fromRxOrder(order, patientName, patientEmail, patientPhone);
    _invoices.add(invoice);
    notifyListeners();
    return invoice;
  }

  // Select invoice
  void selectInvoice(Invoice invoice) {
    _selectedInvoice = invoice;
    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedInvoice = null;
    notifyListeners();
  }

  // Download invoice as PDF
  Future<File?> downloadInvoice(Invoice invoice) async {
    try {
      _isLoading = true;
      notifyListeners();

      final file = await PdfService.generateInvoicePdf(invoice);
      
      _isLoading = false;
      notifyListeners();
      
      return file;
    } catch (e) {
      _error = 'Failed to download invoice: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Open PDF file
  Future<void> openPdf(File file) async {
    try {
      await PdfService.openPdf(file);
    } catch (e) {
      _error = 'Failed to open PDF: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Mark invoice as paid
  void markAsPaid(String invoiceId) {
    final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (index != -1) {
      final invoice = _invoices[index];
      final updatedInvoice = Invoice(
        id: invoice.id,
        invoiceNumber: invoice.invoiceNumber,
        patientId: invoice.patientId,
        patientName: invoice.patientName,
        patientEmail: invoice.patientEmail,
        patientPhone: invoice.patientPhone,
        patientAddress: invoice.patientAddress,
        providerId: invoice.providerId,
        providerName: invoice.providerName,
        providerAddress: invoice.providerAddress,
        providerPhone: invoice.providerPhone,
        providerEmail: invoice.providerEmail,
        providerTaxId: invoice.providerTaxId,
        type: invoice.type,
        status: InvoiceStatus.paid,
        issueDate: invoice.issueDate,
        dueDate: invoice.dueDate,
        paidDate: DateTime.now(),
        items: invoice.items,
        subtotal: invoice.subtotal,
        tax: invoice.tax,
        discount: invoice.discount,
        total: invoice.total,
        currency: invoice.currency,
        notes: invoice.notes,
        terms: invoice.terms,
        paymentInstructions: invoice.paymentInstructions,
        orderId: invoice.orderId,
        rxOrderId: invoice.rxOrderId,
        metadata: invoice.metadata,
        isTaxDeductible: invoice.isTaxDeductible,
        isClaimable: invoice.isClaimable,
      );
      
      _invoices[index] = updatedInvoice;
      notifyListeners();
    }
  }

  // Get invoice by ID
  Invoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((inv) => inv.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get invoices by status
  List<Invoice> getInvoicesByStatus(InvoiceStatus status) {
    return _invoices.where((inv) => inv.status == status).toList();
  }

  // Get invoices by type
  List<Invoice> getInvoicesByType(InvoiceType type) {
    return _invoices.where((inv) => inv.type == type).toList();
  }

  // Search invoices
  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) return _invoices;
    
    final lowercaseQuery = query.toLowerCase();
    return _invoices.where((inv) =>
      inv.invoiceNumber.toLowerCase().contains(lowercaseQuery) ||
      inv.patientName.toLowerCase().contains(lowercaseQuery) ||
      inv.providerName.toLowerCase().contains(lowercaseQuery) ||
      inv.typeDisplayName.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Get invoices by tax and claim eligibility
  List<Invoice> getInvoicesByTaxEligibility(bool isTaxDeductible) {
    return _invoices.where((inv) => inv.isTaxDeductible == isTaxDeductible).toList();
  }

  List<Invoice> getInvoicesByClaimEligibility(bool isClaimable) {
    return _invoices.where((inv) => inv.isClaimable == isClaimable).toList();
  }

  // Get invoices ready for claims (paid and claimable)
  List<Invoice> getInvoicesReadyForClaims() {
    return _invoices.where((inv) => inv.canBeClaimed).toList();
  }

  // Get invoices ready for tax deduction (paid and tax deductible)
  List<Invoice> getInvoicesReadyForTaxDeduction() {
    return _invoices.where((inv) => inv.canBeTaxDeducted).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh invoices
  void refresh() {
    _loadMockInvoices();
  }
} 