import 'package:flutter/material.dart';

class HealthRecord {
  final String id;
  final String patientId;
  final String recordType;
  final String title;
  final String? description;
  final DateTime date;
  final Map<String, dynamic>? medicalHistory;
  final Map<String, dynamic>? allergies;
  final Map<String, dynamic>? medications;
  final Map<String, dynamic>? labResults;
  final Map<String, dynamic>? imaging;
  final Map<String, dynamic>? surgery;
  final Map<String, dynamic>? familyHistory;
  final List<dynamic>? attachments;
  final bool isPrivate;
  final String? familyMemberId;
  final String? provider;
  final String? providerImage;
  final String? status;
  final bool isImportant;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HealthRecord({
    required this.id,
    required this.patientId,
    required this.recordType,
    required this.title,
    this.description,
    required this.date,
    this.medicalHistory,
    this.allergies,
    this.medications,
    this.labResults,
    this.imaging,
    this.surgery,
    this.familyHistory,
    this.attachments,
    this.isPrivate = false,
    this.familyMemberId,
    this.provider,
    this.providerImage,
    this.status,
    this.isImportant = false,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    try {
      return HealthRecord(
        id: json['_id']?.toString() ?? '',
        patientId: json['patientId']?.toString() ?? '',
        recordType: json['recordType']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        date: json['date'] != null
            ? DateTime.parse(json['date'].toString())
            : DateTime.now(),
        medicalHistory: json['medicalHistory'] != null
            ? Map<String, dynamic>.from(json['medicalHistory'])
            : null,
        allergies: json['allergies'] != null
            ? Map<String, dynamic>.from(json['allergies'])
            : null,
        medications: json['medications'] != null
            ? Map<String, dynamic>.from(json['medications'])
            : null,
        labResults: json['labResults'] != null
            ? Map<String, dynamic>.from(json['labResults'])
            : null,
        imaging: json['imaging'] != null
            ? Map<String, dynamic>.from(json['imaging'])
            : null,
        surgery: json['surgery'] != null
            ? Map<String, dynamic>.from(json['surgery'])
            : null,
        familyHistory: json['familyHistory'] != null
            ? Map<String, dynamic>.from(json['familyHistory'])
            : null,
        attachments: json['attachments'] != null
            ? List<dynamic>.from(json['attachments'])
            : null,
        isPrivate: json['isPrivate'] == true,
        familyMemberId: json['familyMemberId']?.toString(),
        provider: json['provider']?.toString(),
        providerImage: json['providerImage']?.toString(),
        status: json['status']?.toString(),
        isImportant: json['isImportant'] == true,
        createdBy: json['createdBy']?.toString(),
        updatedBy: json['updatedBy']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : null,
      );
    } catch (e) {
      print('Error parsing HealthRecord from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'recordType': recordType,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'medications': medications,
      'labResults': labResults,
      'imaging': imaging,
      'surgery': surgery,
      'familyHistory': familyHistory,
      'attachments': attachments,
      'isPrivate': isPrivate,
      'familyMemberId': familyMemberId,
      'provider': provider,
      'providerImage': providerImage,
      'status': status,
      'isImportant': isImportant,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get category {
    switch (recordType) {
      case 'medical_history':
        return 'Conditions';
      case 'allergies':
        return 'Allergies';
      case 'medications':
        return 'Medications';
      case 'immunizations':
        return 'Immunizations';
      case 'lab_results':
        return 'Lab Results';
      case 'imaging':
        return 'Procedures';
      case 'surgery':
        return 'Procedures';
      case 'family_history':
        return 'Family History';
      default:
        return 'Other';
    }
  }

  // Factory constructor for creating new records
  factory HealthRecord.create({
    required String patientId,
    required String recordType,
    required String title,
    String? description,
    DateTime? date,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? allergies,
    Map<String, dynamic>? medications,
    Map<String, dynamic>? labResults,
    Map<String, dynamic>? imaging,
    Map<String, dynamic>? surgery,
    Map<String, dynamic>? familyHistory,
    List<dynamic>? attachments,
    bool isPrivate = false,
    String? familyMemberId,
    String? provider,
    String? providerImage,
    String? status,
    bool isImportant = false,
    String? createdBy,
    String? notes,
  }) {
    return HealthRecord(
      id: '', // Will be set by the server
      patientId: patientId,
      recordType: recordType,
      title: title,
      description: description,
      date: date ?? DateTime.now(),
      medicalHistory: medicalHistory,
      allergies: allergies,
      medications: medications,
      labResults: labResults,
      imaging: imaging,
      surgery: surgery,
      familyHistory: familyHistory,
      attachments: attachments,
      isPrivate: isPrivate,
      familyMemberId: familyMemberId,
      provider: provider,
      providerImage: providerImage,
      status: status,
      isImportant: isImportant,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
  }

  // Copy with method for updating records
  HealthRecord copyWith({
    String? id,
    String? patientId,
    String? recordType,
    String? title,
    String? description,
    DateTime? date,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? allergies,
    Map<String, dynamic>? medications,
    Map<String, dynamic>? labResults,
    Map<String, dynamic>? imaging,
    Map<String, dynamic>? surgery,
    Map<String, dynamic>? familyHistory,
    List<dynamic>? attachments,
    bool? isPrivate,
    String? familyMemberId,
    String? provider,
    String? providerImage,
    String? status,
    bool? isImportant,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      labResults: labResults ?? this.labResults,
      imaging: imaging ?? this.imaging,
      surgery: surgery ?? this.surgery,
      familyHistory: familyHistory ?? this.familyHistory,
      attachments: attachments ?? this.attachments,
      isPrivate: isPrivate ?? this.isPrivate,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      provider: provider ?? this.provider,
      providerImage: providerImage ?? this.providerImage,
      status: status ?? this.status,
      isImportant: isImportant ?? this.isImportant,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // For dummy data (can be removed in production)
  static List<HealthRecord> dummyList() {
    return [];
  }
}

class VitalSigns {
  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;
  final int? heartRate;
  final double? temperature;
  final int? oxygenSaturation;
  final double? weight;
  final double? height;
  final DateTime date;

  VitalSigns({
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.temperature,
    this.oxygenSaturation,
    this.weight,
    this.height,
    required this.date,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      bloodPressureSystolic: json['bloodPressureSystolic']?.toDouble(),
      bloodPressureDiastolic: json['bloodPressureDiastolic']?.toDouble(),
      heartRate: json['heartRate'],
      temperature: json['temperature']?.toDouble(),
      oxygenSaturation: json['oxygenSaturation'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
}

class LabResult {
  final String testName;
  final String result;
  final String unit;
  final String normalRange;
  final String status;
  final DateTime date;
  final String labName;

  LabResult({
    required this.testName,
    required this.result,
    required this.unit,
    required this.normalRange,
    required this.status,
    required this.date,
    required this.labName,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      testName: json['testName'] ?? '',
      result: json['result'] ?? '',
      unit: json['unit'] ?? '',
      normalRange: json['referenceRange'] ?? '',
      status: json['status'] ?? 'normal',
      date: DateTime.parse(json['date']),
      labName: json['labName'] ?? '',
    );
  }
}
