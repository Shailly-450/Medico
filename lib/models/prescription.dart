class PrescriptionMedication {
  final String name;
  final String dosage;
  final String duration;
  final String instructions;

  PrescriptionMedication({
    required this.name,
    required this.dosage,
    required this.duration,
    required this.instructions,
  });

  factory PrescriptionMedication.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedication(
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      duration: json['duration'] as String,
      instructions: json['instructions'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'dosage': dosage,
    'duration': duration,
    'instructions': instructions,
  };
}

class Prescription {
  final String id;
  final String patientId;
  final String patientName;
  final int patientAge;
  final String? patientGender;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime prescriptionDate;
  final List<PrescriptionMedication> medications;
  final String? diagnosis;
  final String? additionalInstructions;
  final DateTime? followUpDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    this.patientGender,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.prescriptionDate,
    required this.medications,
    this.diagnosis,
    this.additionalInstructions,
    this.followUpDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['_id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      patientAge: json['patientAge'] as int,
      patientGender: json['patientGender'] as String?,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorSpecialty: json['doctorSpecialty'] as String,
      prescriptionDate: DateTime.parse(json['prescriptionDate'] as String),
      medications: (json['medications'] as List<dynamic>)
          .map(
            (med) =>
                PrescriptionMedication.fromJson(med as Map<String, dynamic>),
          )
          .toList(),
      diagnosis: json['diagnosis'] as String?,
      additionalInstructions: json['additionalInstructions'] as String?,
      followUpDate: json['followUpDate'] != null
          ? DateTime.parse(json['followUpDate'] as String)
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'patientName': patientName,
    'patientAge': patientAge,
    if (patientGender != null) 'patientGender': patientGender,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'doctorSpecialty': doctorSpecialty,
    'prescriptionDate': prescriptionDate.toIso8601String(),
    'medications': medications.map((med) => med.toJson()).toList(),
    if (diagnosis != null) 'diagnosis': diagnosis,
    if (additionalInstructions != null)
      'additionalInstructions': additionalInstructions,
    if (followUpDate != null) 'followUpDate': followUpDate!.toIso8601String(),
    'status': status,
  };

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isPending => status == 'pending';

  String get formattedPrescriptionDate =>
      '${prescriptionDate.day}/${prescriptionDate.month}/${prescriptionDate.year}';

  String get formattedFollowUpDate => followUpDate != null
      ? '${followUpDate!.day}/${followUpDate!.month}/${followUpDate!.year}'
      : 'No follow-up scheduled';

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }
}
