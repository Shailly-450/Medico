class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String medicineType; // tablet, capsule, syrup, injection, etc.
  final String manufacturer;
  final DateTime? expiryDate;
  final int totalQuantity;
  final int remainingQuantity;
  final String? notes;
  final String? imageUrl;
  final bool isActive;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.medicineType,
    required this.manufacturer,
    this.expiryDate,
    required this.totalQuantity,
    required this.remainingQuantity,
    this.notes,
    this.imageUrl,
    this.isActive = true,
  });

  // Factory constructor to create Medicine from JSON
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      medicineType: json['medicineType'] as String,
      manufacturer: json['manufacturer'] as String,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      totalQuantity: json['totalQuantity'] as int,
      remainingQuantity: json['remainingQuantity'] as int,
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  // Convert Medicine to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'medicineType': medicineType,
      'manufacturer': manufacturer,
      'expiryDate': expiryDate?.toIso8601String(),
      'totalQuantity': totalQuantity,
      'remainingQuantity': remainingQuantity,
      'notes': notes,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }

  // Calculate if medicine needs refill (below 20% remaining)
  bool get needsRefill => (remainingQuantity / totalQuantity) <= 0.2;

  // Check if medicine is expired
  bool get isExpired =>
      expiryDate != null && DateTime.now().isAfter(expiryDate!);

  // Days until expiry
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  // Copy with method for updates
  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    String? medicineType,
    String? manufacturer,
    DateTime? expiryDate,
    int? totalQuantity,
    int? remainingQuantity,
    String? notes,
    String? imageUrl,
    bool? isActive,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      medicineType: medicineType ?? this.medicineType,
      manufacturer: manufacturer ?? this.manufacturer,
      expiryDate: expiryDate ?? this.expiryDate,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
