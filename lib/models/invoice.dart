import 'package:intl/intl.dart';

class InvoiceItem {
  final String name;
  final double price;

  InvoiceItem({required this.name, required this.price});

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}

enum InvoiceType { Consultation, Prescription }

enum InvoiceStatus { Pending, Paid, Overdue }

class Invoice {
  final String id;
  final String invoiceNumber;
  final InvoiceType type;
  final InvoiceStatus status;
  final String provider;
  final double amount;
  final DateTime dueDate;
  final bool sent;
  final List<InvoiceItem> items;
  final String? linkedAppointment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    required this.status,
    required this.provider,
    required this.amount,
    required this.dueDate,
    required this.sent,
    required this.items,
    this.linkedAppointment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['_id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      type: InvoiceType.values.firstWhere(
        (e) => e.toString() == 'InvoiceType.${json['type']}',
        orElse: () => InvoiceType.Consultation,
      ),
      status: InvoiceStatus.values.firstWhere(
        (e) => e.toString() == 'InvoiceStatus.${json['status']}',
        orElse: () => InvoiceStatus.Pending,
      ),
      provider: json['provider'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      sent: json['sent'] as bool? ?? false,
      items: (json['items'] as List<dynamic>)
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      linkedAppointment: json['linkedAppointment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'invoiceNumber': invoiceNumber,
    'type': type.toString().split('.').last,
    'status': status.toString().split('.').last,
    'provider': provider,
    'amount': amount,
    'dueDate': dueDate.toUtc().toIso8601String(),
    'sent': sent,
    'items': items.map((item) => item.toJson()).toList(),
    if (linkedAppointment != null) 'linkedAppointment': linkedAppointment,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  String get typeDisplayName => type.toString().split('.').last;
  String get statusDisplayName => status.toString().split('.').last;

  bool get isPaid => status == InvoiceStatus.Paid;
  bool get isOverdue => status == InvoiceStatus.Overdue;
  bool get isDueSoon =>
      !isPaid &&
      dueDate.difference(DateTime.now()).inDays <= 3 &&
      dueDate.difference(DateTime.now()).inDays > 0;

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  String get formattedAmount =>
      NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(amount);

  String get formattedDueDate => DateFormat('MMM dd, yyyy').format(dueDate);
}
