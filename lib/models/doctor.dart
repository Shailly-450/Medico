class Doctor {
  final String id;
  final String name;
  final String imageUrl;
  final String specialty;
  final String hospital;
  final double rating;
  final int reviews;
  final double price;
  final bool isOnline;
  final int experience; // in years
  final String education;
  final List<String> languages;
  final List<String> specializations;
  final String about;
  final Map<String, dynamic> availability;
  final List<String> awards;
  final String consultationFee;
  final bool acceptsInsurance;
  final List<String> insuranceProviders;
  final String location;
  final double distance; // in km
  final bool isVerified;
  final String phoneNumber;
  final String email;

  Doctor({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.reviews,
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
  });

  // Factory constructor to create Doctor from JSON
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      specialty: json['specialty'] as String,
      hospital: json['hospital'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviews: json['reviews'] as int,
      price: (json['price'] as num).toDouble(),
      isOnline: json['isOnline'] as bool,
      experience: json['experience'] ?? 0,
      education: json['education'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      specializations: List<String>.from(json['specializations'] ?? []),
      about: json['about'] ?? '',
      availability: Map<String, dynamic>.from(json['availability'] ?? {}),
      awards: List<String>.from(json['awards'] ?? []),
      consultationFee: json['consultationFee'] ?? '',
      acceptsInsurance: json['acceptsInsurance'] ?? false,
      insuranceProviders: List<String>.from(json['insuranceProviders'] ?? []),
      location: json['location'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['isVerified'] ?? false,
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // Convert Doctor to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'specialty': specialty,
      'hospital': hospital,
      'rating': rating,
      'reviews': reviews,
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
    };
  }
}
