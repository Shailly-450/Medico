class PrescriptionMedicine {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;
  final int quantity;
  final String refills;
  final String? genericName;
  final String? brandName;
  final String? strength;
  final String? form;
  final String? route;
  final List<String>? sideEffects;
  final List<String>? contraindications;
  final bool isDispensed;
  final DateTime? dispensedAt;
  final String? dispensedBy;

  PrescriptionMedicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
    this.quantity = 1,
    this.refills = '0',
    this.genericName,
    this.brandName,
    this.strength,
    this.form,
    this.route,
    this.sideEffects,
    this.contraindications,
    this.isDispensed = false,
    this.dispensedAt,
    this.dispensedBy,
  });

  factory PrescriptionMedicine.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedicine(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      instructions: json['instructions'],
      quantity: json['quantity'] ?? 1,
      refills: json['refills'] ?? '0',
      genericName: json['genericName'],
      brandName: json['brandName'],
      strength: json['strength'],
      form: json['form'],
      route: json['route'],
      sideEffects: json['sideEffects'] != null
          ? List<String>.from(json['sideEffects'])
          : null,
      contraindications: json['contraindications'] != null
          ? List<String>.from(json['contraindications'])
          : null,
      isDispensed: json['isDispensed'] ?? false,
      dispensedAt: json['dispensedAt'] != null
          ? DateTime.parse(json['dispensedAt'])
          : null,
      dispensedBy: json['dispensedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
      'quantity': quantity,
      'refills': refills,
      'genericName': genericName,
      'brandName': brandName,
      'strength': strength,
      'form': form,
      'route': route,
      'isDispensed': isDispensed,
      'dispensedAt': dispensedAt?.toIso8601String(),
      'dispensedBy': dispensedBy,
    };
  }
}

class Prescription {
  final String id;
  final String patientId;
  final String patientName;
  final int patientAge;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime prescriptionDate;
  final DateTime? expirationDate; // Added expiration date field
  final String diagnosis;
  final List<PrescriptionMedicine> medications;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.prescriptionDate,
    this.expirationDate, // Added expiration date parameter
    required this.diagnosis,
    required this.medications,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Status check methods
  bool isActive() {
    final now = DateTime.now();
    return !isExpired() && !isCompleted();
  }

  bool isExpired() {
    final now = DateTime.now();
    return expirationDate != null && now.isAfter(expirationDate!);
  }

  bool isCompleted() {
    return medications.every((med) => med.isDispensed);
  }

  String get status {
    if (isExpired()) return 'expired';
    if (isCompleted()) return 'completed';
    if (isActive()) return 'active';
    return 'unknown';
  }

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      patientAge: json['patientAge'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      doctorSpecialty: json['doctorSpecialty'],
      prescriptionDate: DateTime.parse(json['prescriptionDate']),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      diagnosis: json['diagnosis'],
      medications: (json['medications'] as List)
          .map((med) => PrescriptionMedicine.fromJson(med))
          .toList(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientAge': patientAge,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'prescriptionDate': prescriptionDate.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'diagnosis': diagnosis,
      'medications': medications.map((med) => med.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
