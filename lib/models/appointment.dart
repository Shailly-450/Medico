class Appointment {
  final String doctorName;
  final String doctorImage;
  final String specialty;
  final bool isVideoCall;
  final String date;
  final String time;

  Appointment({
    required this.doctorName,
    required this.doctorImage,
    required this.specialty,
    required this.isVideoCall,
    required this.date,
    required this.time,
  });

  // Factory constructor to create Appointment from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      doctorName: json['doctorName'] as String,
      doctorImage: json['doctorImage'] as String,
      specialty: json['specialty'] as String,
      isVideoCall: json['isVideoCall'] as bool,
      date: json['date'] as String,
      time: json['time'] as String,
    );
  }

  // Convert Appointment to JSON
  Map<String, dynamic> toJson() {
    return {
      'doctorName': doctorName,
      'doctorImage': doctorImage,
      'specialty': specialty,
      'isVideoCall': isVideoCall,
      'date': date,
      'time': time,
    };
  }
} 