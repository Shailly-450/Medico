import '../core/services/pre_approval_service.dart';

class Appointment {
  final String id;
  final String doctorName;
  final String doctorImage;
  final String specialty;
  final bool isVideoCall;
  final String date;
  final String time;
  final PreApprovalStatus preApprovalStatus;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.doctorImage,
    required this.specialty,
    required this.isVideoCall,
    required this.date,
    required this.time,
    this.preApprovalStatus = PreApprovalStatus.notRequired,
  });

  // Factory constructor to create Appointment from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      doctorName: json['doctorName'] as String,
      doctorImage: json['doctorImage'] as String,
      specialty: json['specialty'] as String,
      isVideoCall: json['isVideoCall'] as bool,
      date: json['date'] as String,
      time: json['time'] as String,
      preApprovalStatus: PreApprovalStatus.values.firstWhere(
        (e) =>
            e.toString() ==
            'PreApprovalStatus.${json['preApprovalStatus'] ?? 'notRequired'}',
        orElse: () => PreApprovalStatus.notRequired,
      ),
    );
  }

  // Convert Appointment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'doctorImage': doctorImage,
      'specialty': specialty,
      'isVideoCall': isVideoCall,
      'date': date,
      'time': time,
      'preApprovalStatus': preApprovalStatus.toString().split('.').last,
    };
  }
}
