import 'medicine.dart';

enum RxOrderStatus {
  pending,
  confirmed,
  processing,
  readyForPickup,
  delivered,
  cancelled,
  expired,
}

enum RxOrderType {
  newPrescription,
  refill,
  transfer,
}

// Extension methods for enum display names
extension RxOrderStatusExtension on RxOrderStatus {
  String get displayName {
    switch (this) {
      case RxOrderStatus.pending:
        return 'Pending';
      case RxOrderStatus.confirmed:
        return 'Confirmed';
      case RxOrderStatus.processing:
        return 'Processing';
      case RxOrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case RxOrderStatus.delivered:
        return 'Delivered';
      case RxOrderStatus.cancelled:
        return 'Cancelled';
      case RxOrderStatus.expired:
        return 'Expired';
    }
  }
}

extension RxOrderTypeExtension on RxOrderType {
  String get displayName {
    switch (this) {
      case RxOrderType.newPrescription:
        return 'New Prescription';
      case RxOrderType.refill:
        return 'Refill';
      case RxOrderType.transfer:
        return 'Transfer';
    }
  }
}

class RxOrder {
  final String id;
  final String userId;
  final String pharmacyId;
  final String pharmacyName;
  final String? pharmacyAddress;
  final String? pharmacyPhone;
  final List<RxOrderItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String currency;
  final RxOrderStatus status;
  final RxOrderType orderType;
  final DateTime orderDate;
  final DateTime? expectedReadyDate;
  final DateTime? pickupDate;
  final String? prescriptionImageUrl;
  final String? doctorName;
  final String? doctorLicense;
  final String? patientNotes;
  final String? pharmacyNotes;
  final bool requiresInsurance;
  final String? insuranceProvider;
  final String? insurancePolicyNumber;
  final Map<String, dynamic>? metadata;

  RxOrder({
    required this.id,
    required this.userId,
    required this.pharmacyId,
    required this.pharmacyName,
    this.pharmacyAddress,
    this.pharmacyPhone,
    required this.items,
    required this.subtotal,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.total,
    this.currency = 'INR',
    this.status = RxOrderStatus.pending,
    this.orderType = RxOrderType.newPrescription,
    required this.orderDate,
    this.expectedReadyDate,
    this.pickupDate,
    this.prescriptionImageUrl,
    this.doctorName,
    this.doctorLicense,
    this.patientNotes,
    this.pharmacyNotes,
    this.requiresInsurance = false,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.metadata,
  });

  factory RxOrder.fromJson(Map<String, dynamic> json) {
    return RxOrder(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      pharmacyId: json['pharmacyId'] ?? '',
      pharmacyName: json['pharmacyName'] ?? '',
      pharmacyAddress: json['pharmacyAddress'],
      pharmacyPhone: json['pharmacyPhone'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => RxOrderItem.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'INR',
      status: RxOrderStatus.values.firstWhere(
        (e) => e.toString() == 'RxOrderStatus.${json['status']}',
        orElse: () => RxOrderStatus.pending,
      ),
      orderType: RxOrderType.values.firstWhere(
        (e) => e.toString() == 'RxOrderType.${json['orderType']}',
        orElse: () => RxOrderType.newPrescription,
      ),
      orderDate: DateTime.parse(json['orderDate']),
      expectedReadyDate: json['expectedReadyDate'] != null
          ? DateTime.parse(json['expectedReadyDate'])
          : null,
      pickupDate: json['pickupDate'] != null
          ? DateTime.parse(json['pickupDate'])
          : null,
      prescriptionImageUrl: json['prescriptionImageUrl'],
      doctorName: json['doctorName'],
      doctorLicense: json['doctorLicense'],
      patientNotes: json['patientNotes'],
      pharmacyNotes: json['pharmacyNotes'],
      requiresInsurance: json['requiresInsurance'] ?? false,
      insuranceProvider: json['insuranceProvider'],
      insurancePolicyNumber: json['insurancePolicyNumber'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pharmacyId': pharmacyId,
      'pharmacyName': pharmacyName,
      'pharmacyAddress': pharmacyAddress,
      'pharmacyPhone': pharmacyPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'currency': currency,
      'status': status.toString().split('.').last,
      'orderType': orderType.toString().split('.').last,
      'orderDate': orderDate.toIso8601String(),
      'expectedReadyDate': expectedReadyDate?.toIso8601String(),
      'pickupDate': pickupDate?.toIso8601String(),
      'prescriptionImageUrl': prescriptionImageUrl,
      'doctorName': doctorName,
      'doctorLicense': doctorLicense,
      'patientNotes': patientNotes,
      'pharmacyNotes': pharmacyNotes,
      'requiresInsurance': requiresInsurance,
      'insuranceProvider': insuranceProvider,
      'insurancePolicyNumber': insurancePolicyNumber,
      'metadata': metadata,
    };
  }

  RxOrder copyWith({
    String? id,
    String? userId,
    String? pharmacyId,
    String? pharmacyName,
    String? pharmacyAddress,
    String? pharmacyPhone,
    List<RxOrderItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    String? currency,
    RxOrderStatus? status,
    RxOrderType? orderType,
    DateTime? orderDate,
    DateTime? expectedReadyDate,
    DateTime? pickupDate,
    String? prescriptionImageUrl,
    String? doctorName,
    String? doctorLicense,
    String? patientNotes,
    String? pharmacyNotes,
    bool? requiresInsurance,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    Map<String, dynamic>? metadata,
  }) {
    return RxOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      pharmacyAddress: pharmacyAddress ?? this.pharmacyAddress,
      pharmacyPhone: pharmacyPhone ?? this.pharmacyPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      orderDate: orderDate ?? this.orderDate,
      expectedReadyDate: expectedReadyDate ?? this.expectedReadyDate,
      pickupDate: pickupDate ?? this.pickupDate,
      prescriptionImageUrl: prescriptionImageUrl ?? this.prescriptionImageUrl,
      doctorName: doctorName ?? this.doctorName,
      doctorLicense: doctorLicense ?? this.doctorLicense,
      patientNotes: patientNotes ?? this.patientNotes,
      pharmacyNotes: pharmacyNotes ?? this.pharmacyNotes,
      requiresInsurance: requiresInsurance ?? this.requiresInsurance,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insurancePolicyNumber: insurancePolicyNumber ?? this.insurancePolicyNumber,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get isPending => status == RxOrderStatus.pending;
  bool get isConfirmed => status == RxOrderStatus.confirmed;
  bool get isProcessing => status == RxOrderStatus.processing;
  bool get isReadyForPickup => status == RxOrderStatus.readyForPickup;
  bool get isDelivered => status == RxOrderStatus.delivered;
  bool get isCancelled => status == RxOrderStatus.cancelled;
  bool get isExpired => status == RxOrderStatus.expired;

  String get statusDisplayName {
    switch (status) {
      case RxOrderStatus.pending:
        return 'Pending';
      case RxOrderStatus.confirmed:
        return 'Confirmed';
      case RxOrderStatus.processing:
        return 'Processing';
      case RxOrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case RxOrderStatus.delivered:
        return 'Delivered';
      case RxOrderStatus.cancelled:
        return 'Cancelled';
      case RxOrderStatus.expired:
        return 'Expired';
    }
  }

  String get orderTypeDisplayName {
    switch (orderType) {
      case RxOrderType.newPrescription:
        return 'New Prescription';
      case RxOrderType.refill:
        return 'Refill';
      case RxOrderType.transfer:
        return 'Transfer';
    }
  }
}

class RxOrderItem {
  final String id;
  final Medicine medicine;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? dosage;
  final String? instructions;
  final String? genericSubstitution;
  final bool allowGeneric;
  final String? notes;

  RxOrderItem({
    required this.id,
    required this.medicine,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.dosage,
    this.instructions,
    this.genericSubstitution,
    this.allowGeneric = true,
    this.notes,
  });

  factory RxOrderItem.fromJson(Map<String, dynamic> json) {
    return RxOrderItem(
      id: json['id'] ?? '',
      medicine: Medicine.fromJson(json['medicine']),
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      dosage: json['dosage'],
      instructions: json['instructions'],
      genericSubstitution: json['genericSubstitution'],
      allowGeneric: json['allowGeneric'] ?? true,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicine': medicine.toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'dosage': dosage,
      'instructions': instructions,
      'genericSubstitution': genericSubstitution,
      'allowGeneric': allowGeneric,
      'notes': notes,
    };
  }

  RxOrderItem copyWith({
    String? id,
    Medicine? medicine,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? dosage,
    String? instructions,
    String? genericSubstitution,
    bool? allowGeneric,
    String? notes,
  }) {
    return RxOrderItem(
      id: id ?? this.id,
      medicine: medicine ?? this.medicine,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      genericSubstitution: genericSubstitution ?? this.genericSubstitution,
      allowGeneric: allowGeneric ?? this.allowGeneric,
      notes: notes ?? this.notes,
    );
  }
}

class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final List<String> services;
  final String? operatingHours;
  final double? deliveryFee;
  final bool offersDelivery;
  final bool offersPickup;
  final String? imageUrl;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isOpen = true,
    this.services = const [],
    this.operatingHours,
    this.deliveryFee,
    this.offersDelivery = false,
    this.offersPickup = true,
    this.imageUrl,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isOpen: json['isOpen'] ?? true,
      services: List<String>.from(json['services'] ?? []),
      operatingHours: json['operatingHours'],
      deliveryFee: json['deliveryFee']?.toDouble(),
      offersDelivery: json['offersDelivery'] ?? false,
      offersPickup: json['offersPickup'] ?? true,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'rating': rating,
      'reviewCount': reviewCount,
      'isOpen': isOpen,
      'services': services,
      'operatingHours': operatingHours,
      'deliveryFee': deliveryFee,
      'offersDelivery': offersDelivery,
      'offersPickup': offersPickup,
      'imageUrl': imageUrl,
    };
  }
} 