import '../core/services/pre_approval_service.dart';

class Appointment {
  final String id;
  final String? patientId;
  final String? doctorId;
  final String? hospitalId;
  final String doctorName;
  final String doctorImage;
  final String specialty;
  final bool isVideoCall;
  final String date;
  final String time;
  final String appointmentType;
  final String? reason;
  final List<String>? symptoms;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final String? preferredTimeSlot;
  final String status;
  final String preApprovalStatus;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    this.patientId,
    this.doctorId,
    this.hospitalId,
    required this.doctorName,
    required this.doctorImage,
    required this.specialty,
    required this.isVideoCall,
    required this.date,
    required this.time,
    required this.appointmentType,
    this.reason,
    this.symptoms,
    this.insuranceProvider,
    this.insuranceNumber,
    this.preferredTimeSlot,
    this.status = 'scheduled',
    this.preApprovalStatus = 'notRequired',
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create Appointment from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctorId'];
    String doctorName = 'Unknown Doctor';
    String doctorImage = 'https://randomuser.me/api/portraits/men/1.jpg';
    String? doctorId;
    if (doctor is Map) {
      doctorId = doctor['_id'];
      doctorName = doctor['name'] ?? doctor['fullName'] ?? doctor['email'] ?? 'Unknown Doctor';
      final img = doctor['image'] ?? doctor['profileImage'];
      if (img != null && img is String && img.isNotEmpty) {
        doctorImage = img;
      }
    } else if (doctor is String) {
      doctorId = doctor;
    }

    // Defensive for patientId
    String? patientId;
    if (json['patientId'] is Map) {
      patientId = json['patientId']['_id'];
    } else if (json['patientId'] is String) {
      patientId = json['patientId'];
    }

    // Defensive for hospitalId
    String? hospitalId;
    if (json['hospitalId'] is Map) {
      hospitalId = json['hospitalId']['_id'];
    } else if (json['hospitalId'] is String) {
      hospitalId = json['hospitalId'];
    }

    // Defensive for symptoms
    List<String>? symptoms;
    if (json['symptoms'] is List) {
      symptoms = List<String>.from(json['symptoms']);
    } else if (json['symptoms'] is String && json['symptoms'].isNotEmpty) {
      symptoms = [json['symptoms']];
    }

    return Appointment(
      id: json['_id'] ?? json['id'] ?? '',
      patientId: patientId,
      doctorId: doctorId,
      hospitalId: hospitalId,
      doctorName: doctorName,
      doctorImage: doctorImage,
      specialty: json['specialty'] ?? 'General',
      isVideoCall: json['isVideoCall'] ?? false,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      appointmentType: json['appointmentType'] ?? 'consultation',
      reason: json['reason'],
      symptoms: symptoms,
      insuranceProvider: json['insuranceProvider'],
      insuranceNumber: json['insuranceNumber'],
      preferredTimeSlot: json['preferredTimeSlot'],
      status: json['status'] ?? 'scheduled',
      preApprovalStatus: json['preApprovalStatus'] ?? 'notRequired',
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Convert Appointment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'hospitalId': hospitalId,
      'doctorName': doctorName,
      'doctorImage': doctorImage,
      'specialty': specialty,
      'isVideoCall': isVideoCall,
      'date': date,
      'time': time,
      'appointmentType': appointmentType,
      'reason': reason,
      'symptoms': symptoms,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'preferredTimeSlot': preferredTimeSlot,
      'status': status,
      'preApprovalStatus': preApprovalStatus,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Returns the preferred time slot string for a given time (24-hour format).
/// Enum values must match your backend: e.g. 'morning', 'afternoon', 'evening', 'night'.
String getPreferredTimeSlot(String time) {
  // Expects time in "HH:mm" or "HH:mm:ss" format
  final parts = time.split(':');
  if (parts.length < 2) return 'morning'; // fallback

  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  final totalMinutes = hour * 60 + minute;

  if (totalMinutes >= 360 && totalMinutes < 720) {
    return 'morning';    // 06:00 - 12:00
  } else if (totalMinutes >= 720 && totalMinutes < 1020) {
    return 'afternoon';  // 12:00 - 17:00
  } else if (totalMinutes >= 1020 && totalMinutes < 1260) {
    return 'evening';    // 17:00 - 21:00
  } else {
    return 'night';      // 21:00 - 06:00
  }
}