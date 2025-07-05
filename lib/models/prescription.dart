class Prescription {
  final String id;
  final String patientName;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime prescriptionDate;
  final DateTime? expiryDate;
  final String diagnosis;
  final List<PrescriptionMedication> medications;
  final String? notes;
  final PrescriptionStatus status;
  final String? prescriptionImageUrl;
  final String? digitalSignature;

  Prescription({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.prescriptionDate,
    this.expiryDate,
    required this.diagnosis,
    required this.medications,
    this.notes,
    required this.status,
    this.prescriptionImageUrl,
    this.digitalSignature,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      patientName: json['patientName'],
      doctorName: json['doctorName'],
      doctorSpecialty: json['doctorSpecialty'],
      prescriptionDate: DateTime.parse(json['prescriptionDate']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      diagnosis: json['diagnosis'],
      medications: (json['medications'] as List)
          .map((med) => PrescriptionMedication.fromJson(med))
          .toList(),
      notes: json['notes'],
      status: PrescriptionStatus.values.firstWhere(
          (e) => e.toString() == 'PrescriptionStatus.${json['status']}'),
      prescriptionImageUrl: json['prescriptionImageUrl'],
      digitalSignature: json['digitalSignature'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'prescriptionDate': prescriptionDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'diagnosis': diagnosis,
      'medications': medications.map((med) => med.toJson()).toList(),
      'notes': notes,
      'status': status.toString().split('.').last,
      'prescriptionImageUrl': prescriptionImageUrl,
      'digitalSignature': digitalSignature,
    };
  }

  bool get isExpired =>
      expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get isActive => status == PrescriptionStatus.active && !isExpired;
  int get totalMedications => medications.length;
  int get activeMedications => medications.where((med) => med.isActive).length;
}

class PrescriptionMedication {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;
  final int quantity;
  final String? refills;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  PrescriptionMedication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
    required this.quantity,
    this.refills,
    required this.isActive,
    this.startDate,
    this.endDate,
  });

  factory PrescriptionMedication.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedication(
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
      instructions: json['instructions'],
      quantity: json['quantity'],
      refills: json['refills'],
      isActive: json['isActive'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
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
      'isActive': isActive,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }
}

enum PrescriptionStatus {
  active,
  completed,
  expired,
  cancelled,
  pending,
}

extension PrescriptionStatusExtension on PrescriptionStatus {
  String get displayName {
    switch (this) {
      case PrescriptionStatus.active:
        return 'Active';
      case PrescriptionStatus.completed:
        return 'Completed';
      case PrescriptionStatus.expired:
        return 'Expired';
      case PrescriptionStatus.cancelled:
        return 'Cancelled';
      case PrescriptionStatus.pending:
        return 'Pending';
    }
  }

  String get description {
    switch (this) {
      case PrescriptionStatus.active:
        return 'Prescription is currently active and valid';
      case PrescriptionStatus.completed:
        return 'Prescription has been completed';
      case PrescriptionStatus.expired:
        return 'Prescription has expired';
      case PrescriptionStatus.cancelled:
        return 'Prescription has been cancelled';
      case PrescriptionStatus.pending:
        return 'Prescription is pending approval';
    }
  }
}
