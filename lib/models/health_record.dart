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
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['_id'] ?? '',
      patientId: json['patientId'] ?? '',
      recordType: json['recordType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      date: DateTime.parse(json['date']),
      medicalHistory: json['medicalHistory'],
      allergies: json['allergies'],
      medications: json['medications'],
      labResults: json['labResults'],
      imaging: json['imaging'],
      surgery: json['surgery'],
      familyHistory: json['familyHistory'],
      attachments: json['attachments'],
      isPrivate: json['isPrivate'] ?? false,
      familyMemberId: json['familyMemberId'],
      provider: json['provider'],
      providerImage: json['providerImage'],
      status: json['status'],
      isImportant: json['isImportant'] ?? false,
    );
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
