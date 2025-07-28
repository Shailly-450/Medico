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
      refills: json['refills']?.toString() ?? '0',
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
    try {
      // Handle the actual API structure
      final String id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

      // Extract patientId from object or string
      String patientId = '';
      if (json['patientId'] is Map) {
        patientId = json['patientId']['_id']?.toString() ?? '';
      } else {
        patientId = json['patientId']?.toString() ?? '';
      }

      // Extract doctorId from object or string
      String doctorId = '';
      if (json['doctorId'] is Map) {
        doctorId = json['doctorId']['_id']?.toString() ?? '';
      } else {
        doctorId = json['doctorId']?.toString() ?? '';
      }

      // Extract patient name from patientId object if available
      String patientName = '';
      if (json['patientId'] is Map && json['patientId']['profile'] != null) {
        patientName = json['patientId']['profile']['name']?.toString() ?? '';
      } else {
        patientName = json['patientName']?.toString() ?? 'Unknown Patient';
      }

      // Extract doctor name from doctorId object if available
      String doctorName = '';
      if (json['doctorId'] is Map && json['doctorId']['profile'] != null) {
        doctorName = json['doctorId']['profile']['name']?.toString() ?? '';
      } else {
        doctorName = json['doctorName']?.toString() ?? 'Unknown Doctor';
      }

      // Default values for missing fields
      final int patientAge = json['patientAge'] ?? 0;
      final String doctorSpecialty =
          json['doctorSpecialty']?.toString() ?? 'General Medicine';

      return Prescription(
        id: id,
        patientId: patientId,
        patientName: patientName,
        patientAge: patientAge,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        prescriptionDate: json['prescriptionDate'] != null
            ? DateTime.parse(json['prescriptionDate'].toString())
            : DateTime.now(),
        expirationDate: json['expirationDate'] != null
            ? DateTime.parse(json['expirationDate'].toString())
            : null,
        diagnosis: json['diagnosis']?.toString() ?? '',
        medications: json['medications'] != null
            ? (json['medications'] as List)
                .map((med) => PrescriptionMedicine.fromJson(med))
                .toList()
            : [],
        notes: json['notes']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : DateTime.now(),
      );
    } catch (e) {
      print('❌ Error parsing Prescription from JSON: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
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
