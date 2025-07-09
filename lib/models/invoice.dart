import 'order.dart';
import 'rx_order.dart';

enum InvoiceStatus {
  draft,
  sent,
  paid,
  overdue,
  cancelled,
  refunded,
}

enum InvoiceType {
  medicalService,
  prescription,
  consultation,
  test,
  procedure,
  other,
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String? patientAddress;
  final String providerId;
  final String providerName;
  final String? providerAddress;
  final String? providerPhone;
  final String? providerEmail;
  final String? providerTaxId;
  final InvoiceType type;
  final InvoiceStatus status;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? paidDate;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String currency;
  final String? notes;
  final String? terms;
  final String? paymentInstructions;
  final String? orderId; // Reference to related order
  final String? rxOrderId; // Reference to related prescription order
  final Map<String, dynamic>? metadata;
  final bool isTaxDeductible; // Flag for tax deduction eligibility
  final bool isClaimable; // Flag for insurance/reimbursement claim eligibility

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.patientPhone,
    this.patientAddress,
    required this.providerId,
    required this.providerName,
    this.providerAddress,
    this.providerPhone,
    this.providerEmail,
    this.providerTaxId,
    required this.type,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    this.paidDate,
    required this.items,
    required this.subtotal,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.total,
    this.currency = 'INR',
    this.notes,
    this.terms,
    this.paymentInstructions,
    this.orderId,
    this.rxOrderId,
    this.metadata,
    this.isTaxDeductible = true, // Default to true for medical expenses
    this.isClaimable = true, // Default to true for medical expenses
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      patientEmail: json['patientEmail'] ?? '',
      patientPhone: json['patientPhone'] ?? '',
      patientAddress: json['patientAddress'],
      providerId: json['providerId'] ?? '',
      providerName: json['providerName'] ?? '',
      providerAddress: json['providerAddress'],
      providerPhone: json['providerPhone'],
      providerEmail: json['providerEmail'],
      providerTaxId: json['providerTaxId'],
      type: InvoiceType.values.firstWhere(
        (e) => e.toString() == 'InvoiceType.${json['type']}',
        orElse: () => InvoiceType.other,
      ),
      status: InvoiceStatus.values.firstWhere(
        (e) => e.toString() == 'InvoiceStatus.${json['status']}',
        orElse: () => InvoiceStatus.draft,
      ),
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItem.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'INR',
      notes: json['notes'],
      terms: json['terms'],
      paymentInstructions: json['paymentInstructions'],
      orderId: json['orderId'],
      rxOrderId: json['rxOrderId'],
      metadata: json['metadata'],
      isTaxDeductible: json['isTaxDeductible'] ?? true,
      isClaimable: json['isClaimable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'patientPhone': patientPhone,
      'patientAddress': patientAddress,
      'providerId': providerId,
      'providerName': providerName,
      'providerAddress': providerAddress,
      'providerPhone': providerPhone,
      'providerEmail': providerEmail,
      'providerTaxId': providerTaxId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'currency': currency,
      'notes': notes,
      'terms': terms,
      'paymentInstructions': paymentInstructions,
      'orderId': orderId,
      'rxOrderId': rxOrderId,
      'metadata': metadata,
      'isTaxDeductible': isTaxDeductible,
      'isClaimable': isClaimable,
    };
  }

  // Helper methods
  bool get isPaid => status == InvoiceStatus.paid;
  bool get isOverdue => status == InvoiceStatus.overdue && DateTime.now().isAfter(dueDate);
  bool get isDraft => status == InvoiceStatus.draft;
  bool get isCancelled => status == InvoiceStatus.cancelled;
  
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  bool get isDueSoon => daysUntilDue <= 7 && daysUntilDue > 0;
  
  // Tax and claim helper methods
  double get taxDeductibleAmount => isTaxDeductible ? total : 0.0;
  double get claimableAmount => isClaimable ? total : 0.0;
  bool get canBeClaimed => isClaimable && isPaid;
  bool get canBeTaxDeducted => isTaxDeductible && isPaid;
  
  String get statusDisplayName {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      case InvoiceStatus.refunded:
        return 'Refunded';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case InvoiceType.medicalService:
        return 'Medical Service';
      case InvoiceType.prescription:
        return 'Prescription';
      case InvoiceType.consultation:
        return 'Consultation';
      case InvoiceType.test:
        return 'Medical Test';
      case InvoiceType.procedure:
        return 'Medical Procedure';
      case InvoiceType.other:
        return 'Other';
    }
  }

  // Create invoice from order
  factory Invoice.fromOrder(Order order, String patientName, String patientEmail, String patientPhone) {
    return Invoice(
      id: 'inv_${order.id}',
      invoiceNumber: 'INV-${DateTime.now().year}-${order.id.substring(order.id.length - 6)}',
      patientId: order.userId,
      patientName: patientName,
      patientEmail: patientEmail,
      patientPhone: patientPhone,
      providerId: order.serviceProviderId,
      providerName: order.serviceProviderName,
      type: InvoiceType.medicalService,
      status: InvoiceStatus.sent,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      items: order.items.map((item) => InvoiceItem(
        id: item.id,
        description: item.service.name,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
        notes: item.notes,
      )).toList(),
      subtotal: order.subtotal,
      tax: order.tax,
      discount: order.discount,
      total: order.total,
      currency: order.currency,
      notes: order.notes,
      orderId: order.id,
      isTaxDeductible: true, // Medical services are typically tax deductible
      isClaimable: true, // Medical services are typically claimable
    );
  }

  // Create invoice from prescription order
  factory Invoice.fromRxOrder(RxOrder order, String patientName, String patientEmail, String patientPhone) {
    return Invoice(
      id: 'inv_rx_${order.id}',
      invoiceNumber: 'INV-RX-${DateTime.now().year}-${order.id.substring(order.id.length - 6)}',
      patientId: order.userId,
      patientName: patientName,
      patientEmail: patientEmail,
      patientPhone: patientPhone,
      providerId: order.pharmacyId,
      providerName: order.pharmacyName,
      providerAddress: order.pharmacyAddress,
      providerPhone: order.pharmacyPhone,
      type: InvoiceType.prescription,
      status: InvoiceStatus.sent,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      items: order.items.map((item) => InvoiceItem(
        id: item.id,
        description: item.medicine.name,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
        notes: item.notes,
      )).toList(),
      subtotal: order.subtotal,
      tax: order.tax,
      discount: order.discount,
      total: order.total,
      currency: order.currency,
      notes: order.patientNotes,
      rxOrderId: order.id,
      isTaxDeductible: true, // Prescription medicines are typically tax deductible
      isClaimable: true, // Prescription medicines are typically claimable
    );
  }
}

class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'notes': notes,
    };
  }
} 