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
    return Doctor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      hospital: json['hospital'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isOnline: json['isOnline'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      experience: json['experience'] as int? ?? 0,
      education: json['education'] as String? ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      specializations: List<String>.from(json['specializations'] ?? []),
      about: json['about'] as String? ?? '',
      availability: Map<String, String>.from(json['availability'] ?? {}),
      awards: List<String>.from(json['awards'] ?? []),
      consultationFee: json['consultationFee'] as String? ?? '',
      acceptsInsurance: json['acceptsInsurance'] as bool? ?? false,
      insuranceProviders: List<String>.from(json['insuranceProviders'] ?? []),
      location: json['location'] as String? ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['isVerified'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      videoCall: json['videoCall'] as bool? ?? false,
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
