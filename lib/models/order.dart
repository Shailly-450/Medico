import 'medical_service.dart';

enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  refunded,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

class Order {
  final String id;
  final String userId;
  final String serviceProviderId; // hospital/clinic ID
  final String serviceProviderName;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String currency;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime orderDate;
  final DateTime? scheduledDate;
  final String? notes;
  final String? cancellationReason;
  final Map<String, dynamic>? metadata;

  Order({
    required this.id,
    required this.userId,
    required this.serviceProviderId,
    required this.serviceProviderName,
    required this.items,
    required this.subtotal,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.total,
    this.currency = 'INR',
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    required this.orderDate,
    this.scheduledDate,
    this.notes,
    this.cancellationReason,
    this.metadata,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      serviceProviderId: json['serviceProviderId'] ?? '',
      serviceProviderName: json['serviceProviderName'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ?? [],
      subtotal: (json['subtotal'] ?? json['totalAmount'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? json['taxAmount'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? json['discountAmount'] ?? 0.0).toDouble(),
      total: (json['total'] ?? json['finalAmount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'INR',
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['paymentStatus']}',
        orElse: () => PaymentStatus.pending,
      ),
      orderDate: DateTime.parse(json['orderDate'] ?? json['createdAt']),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      notes: json['notes'],
      cancellationReason: json['cancellationReason'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceProviderId': serviceProviderId,
      'serviceProviderName': serviceProviderName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'currency': currency,
      'status': status.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'orderDate': orderDate.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'notes': notes,
      'cancellationReason': cancellationReason,
      'metadata': metadata,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? serviceProviderId,
    String? serviceProviderName,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    String? currency,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? orderDate,
    DateTime? scheduledDate,
    String? notes,
    String? cancellationReason,
    Map<String, dynamic>? metadata,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceProviderId: serviceProviderId ?? this.serviceProviderId,
      serviceProviderName: serviceProviderName ?? this.serviceProviderName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderDate: orderDate ?? this.orderDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      metadata: metadata ?? this.metadata,
    );
  }
}

class OrderItem {
  final String id;
  final MedicalService service;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  OrderItem({
    required this.id,
    required this.service,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Support both 'service' and 'serviceId' as the service object
    final serviceJson = json['service'] ?? json['serviceId'];
    return OrderItem(
      id: json['id'] ?? json['_id'] ?? '',
      service: MedicalService.fromJson(serviceJson),
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service.toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'notes': notes,
    };
  }
} 