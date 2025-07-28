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
  final Map<String, dynamic>? payment;
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
    this.payment,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create Appointment from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Appointment.fromJson: Parsing appointment data');
      print('🔍 Appointment.fromJson: JSON structure: $json');

      // Extract doctor name with better fallback logic
      String doctorName = 'Unknown Doctor';
      if (json['doctorId'] != null && json['doctorId'] is Map) {
        if (json['doctorId']['profile'] != null &&
            json['doctorId']['profile']['name'] != null) {
          doctorName = json['doctorId']['profile']['name'];
        } else if (json['doctorId']['name'] != null) {
          doctorName = json['doctorId']['name'];
        } else if (json['doctorId']['email'] != null) {
          // Extract name from email (e.g., "dr.john@example.com" -> "Dr. John")
          String email = json['doctorId']['email'];
          if (email.contains('@')) {
            String emailPrefix = email.split('@')[0];
            if (emailPrefix.startsWith('dr.')) {
              emailPrefix = emailPrefix.substring(3); // Remove "dr."
            }
            // Capitalize first letter and replace dots with spaces
            doctorName =
                'Dr. ${emailPrefix.replaceAll('.', ' ').split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ')}';
          }
        }
      } else if (json['doctorName'] != null) {
        doctorName = json['doctorName'];
      }

      print('🔍 Appointment.fromJson: Extracted doctor name: $doctorName');

      return Appointment(
        id: json['_id'] ?? json['id'] ?? '',
        patientId: json['patientId']?['_id'] ?? json['patientId'],
        doctorId: json['doctorId']?['_id'] ?? json['doctorId'],
        hospitalId: json['hospitalId']?['_id'] ?? json['hospitalId'],
        doctorName: doctorName,
        doctorImage: json['doctorImage'] ??
            'https://randomuser.me/api/portraits/men/1.jpg',
        specialty: json['specialty'] ?? 'General',
        isVideoCall: json['isVideoCall'] ?? false,
        date: json['date'] != null
            ? DateTime.parse(json['date']).toIso8601String().split('T')[0]
            : '',
        time: json['time'] ?? '10:00',
        appointmentType: json['appointmentType'] ?? 'consultation',
        reason: json['reason'],
        symptoms: json['symptoms'] != null
            ? List<String>.from(json['symptoms'])
            : null,
        insuranceProvider: json['insuranceProvider'],
        insuranceNumber: json['insuranceNumber'],
        preferredTimeSlot: json['preferredTimeSlot'],
        status: json['status'] ?? 'scheduled',
        preApprovalStatus: json['preApprovalStatus'] ?? 'notRequired',
        notes: json['notes'],
        payment: json['payment'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );
    } catch (e) {
      print('❌ Appointment.fromJson: Error parsing appointment: $e');
      print('❌ Appointment.fromJson: JSON data: $json');
      rethrow;
    }
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
      'payment': payment,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
