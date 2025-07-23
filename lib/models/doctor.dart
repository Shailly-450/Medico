class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final String imageUrl;
  final double rating;
  final int reviews;
  final bool isAvailable;
  final double price;
  final bool isOnline;

  // Additional fields for enhanced doctor functionality
  final int experience;
  final String education;
  final List<String> languages;
  final List<String> specializations;
  final String about;
  final Map<String, String> availability;
  final List<String> awards;
  final String consultationFee;
  final bool acceptsInsurance;
  final List<String> insuranceProviders;
  final String location;
  final double distance;
  final bool isVerified;
  final String phoneNumber;
  final String email;
  final List<String> symptoms;
  final bool videoCall;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.isAvailable,
    required this.price,
    required this.isOnline,
    required this.experience,
    required this.education,
    required this.languages,
    required this.specializations,
    required this.about,
    required this.availability,
    required this.awards,
    required this.consultationFee,
    required this.acceptsInsurance,
    required this.insuranceProviders,
    required this.location,
    required this.distance,
    required this.isVerified,
    required this.phoneNumber,
    required this.email,
    required this.symptoms,
    required this.videoCall,
  });

  // Factory constructor to create Doctor from JSON
  factory Doctor.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] ?? {};
    final doctorProfile = json['doctorProfile'] ?? {};
    final rating = json['rating'] ?? {};

    return Doctor(
      id: json['_id'] as String? ?? '',
      name: profile['name'] ?? '',
      specialty: doctorProfile['specialty'] ?? '',
      hospital: json['hospital'] ?? '',
      imageUrl: profile['imageUrl'] ?? '',
      rating: (rating['average'] as num?)?.toDouble() ?? 0.0,
      reviews: rating['totalReviews'] as int? ?? 0,
      isAvailable: doctorProfile['availability'] != null ? (doctorProfile['availability'] as List).isNotEmpty : false,
      price: (doctorProfile['consultationFee'] as num?)?.toDouble() ?? 0.0,
      isOnline: doctorProfile['isOnline'] as bool? ?? false,
      experience: doctorProfile['experience'] as int? ?? 0,
      education: doctorProfile['education'] ?? '',
      languages: List<String>.from(doctorProfile['languages'] ?? []),
      specializations: doctorProfile['specializations'] != null ? List<String>.from(doctorProfile['specializations']) : [],
      about: doctorProfile['about'] ?? '',
      availability: const {}, // Map as needed
      awards: const [], // Map as needed
      consultationFee: (doctorProfile['consultationFee']?.toString() ?? ''),
      acceptsInsurance: doctorProfile['acceptsInsurance'] as bool? ?? false,
      insuranceProviders: const [], // Map as needed
      location: doctorProfile['location'] ?? '',
      distance: 0.0, // Map as needed
      isVerified: doctorProfile['isVerified'] as bool? ?? false,
      phoneNumber: profile['phone'] ?? '',
      email: json['email'] ?? '',
      symptoms: const [], // Map as needed
      videoCall: false, // Map as needed
    );
  }

  // Convert Doctor to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'hospital': hospital,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviews': reviews,
      'isAvailable': isAvailable,
      'price': price,
      'isOnline': isOnline,
      'experience': experience,
      'education': education,
      'languages': languages,
      'specializations': specializations,
      'about': about,
      'availability': availability,
      'awards': awards,
      'consultationFee': consultationFee,
      'acceptsInsurance': acceptsInsurance,
      'insuranceProviders': insuranceProviders,
      'location': location,
      'distance': distance,
      'isVerified': isVerified,
      'phoneNumber': phoneNumber,
      'email': email,
      'symptoms': symptoms,
      'videoCall': videoCall,
    };
  }
}
