class Doctor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final int? age;
  final String specialty;
  final int experience;
  final String education;
  final double consultationFee;
  final double rating;
  final int reviewCount;
  final List<String> languages;
  final bool isOnline;
  final bool isVerified;
  final String profileImage;
  final List<Map<String, dynamic>> availability;
  final String hospital;
  final String? bio;
  final List<String>? achievements;
  final List<String>? services;

  // Legacy fields for backward compatibility
  final String imageUrl;
  final int reviews;
  final bool isAvailable;
  final double price;
  final List<String> specializations;
  final String about;
  final Map<String, String> availabilityMap;
  final List<String> awards;
  final String consultationFeeString;
  final bool acceptsInsurance;
  final List<String> insuranceProviders;
  final String location;
  final double distance;
  final String phoneNumber;
  final List<String> symptoms;
  final bool videoCall;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    this.age,
    required this.specialty,
    required this.experience,
    required this.education,
    required this.consultationFee,
    required this.rating,
    required this.reviewCount,
    required this.languages,
    required this.isOnline,
    required this.isVerified,
    required this.profileImage,
    required this.availability,
    required this.hospital,
    this.bio,
    this.achievements,
    this.services,
    // Legacy fields
    required this.imageUrl,
    required this.reviews,
    required this.isAvailable,
    required this.price,
    required this.specializations,
    required this.about,
    required this.availabilityMap,
    required this.awards,
    required this.consultationFeeString,
    required this.acceptsInsurance,
    required this.insuranceProviders,
    required this.location,
    required this.distance,
    required this.phoneNumber,
    required this.symptoms,
    required this.videoCall,
  });

  // Factory constructor to create Doctor from JSON (new API structure)
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      // New API fields
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'],
      specialty: json['specialty'] ?? '',
      experience: json['experience'] ?? 0,
      education: json['education'] ?? '',
      consultationFee: (json['consultationFee'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      languages: List<String>.from(json['languages'] ?? []),
      isOnline: json['isOnline'] ?? false,
      isVerified: json['isVerified'] ?? false,
      profileImage: json['profileImage'] ?? '',
      availability: List<Map<String, dynamic>>.from(json['availability'] ?? []),
      hospital: json['hospital'] ?? '',
      bio: json['bio'],
      achievements: json['achievements'] != null ? List<String>.from(json['achievements']) : null,
      services: json['services'] != null ? List<String>.from(json['services']) : null,
      
      // Legacy fields (for backward compatibility)
      imageUrl: json['profileImage'] ?? '',
      reviews: json['reviewCount'] ?? 0,
      isAvailable: json['isOnline'] ?? false,
      price: (json['consultationFee'] as num?)?.toDouble() ?? 0.0,
      specializations: [json['specialty'] ?? ''],
      about: json['bio'] ?? '',
      availabilityMap: {}, // Convert availability array to map if needed
      awards: json['achievements'] != null ? List<String>.from(json['achievements']) : [],
      consultationFeeString: (json['consultationFee']?.toString() ?? ''),
      acceptsInsurance: false, // Default value
      insuranceProviders: [],
      location: '',
      distance: 0.0,
      phoneNumber: json['phone'] ?? '',
      symptoms: [],
      videoCall: false,
    );
  }

  // Factory constructor for creating mock doctors (backward compatibility)
  factory Doctor.mock({
    required String id,
    required String name,
    String specialty = 'General Physician',
    String hospital = 'General Hospital',
    String imageUrl = '',
    double rating = 4.5,
    int reviews = 0,
    bool isAvailable = true,
    double price = 500.0,
    bool isOnline = false,
    int experience = 5,
    String education = 'MBBS',
    List<String> languages = const ['English'],
    bool isVerified = false,
    String phone = '+91-9876543210',
    String email = 'doctor@example.com',
  }) {
    return Doctor(
      id: id,
      name: name,
      email: email,
      phone: phone,
      gender: '',
      age: null,
      specialty: specialty,
      experience: experience,
      education: education,
      consultationFee: price,
      rating: rating,
      reviewCount: reviews,
      languages: languages,
      isOnline: isOnline,
      isVerified: isVerified,
      profileImage: imageUrl,
      availability: [],
      hospital: hospital,
      bio: null,
      achievements: null,
      services: null,
      // Legacy fields
      imageUrl: imageUrl,
      reviews: reviews,
      isAvailable: isAvailable,
      price: price,
      specializations: [specialty],
      about: '',
      availabilityMap: {},
      awards: [],
      consultationFeeString: price.toString(),
      acceptsInsurance: false,
      insuranceProviders: [],
      location: '',
      distance: 0.0,
      phoneNumber: phone,
      symptoms: [],
      videoCall: false,
    );
  }

  // Convert Doctor to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'age': age,
      'specialty': specialty,
      'experience': experience,
      'education': education,
      'consultationFee': consultationFee,
      'rating': rating,
      'reviewCount': reviewCount,
      'languages': languages,
      'isOnline': isOnline,
      'isVerified': isVerified,
      'profileImage': profileImage,
      'availability': availability,
      'hospital': hospital,
      'bio': bio,
      'achievements': achievements,
      'services': services,
    };
  }

  // Helper method to get availability as a formatted string
  String get availabilityString {
    if (availability.isEmpty) return 'Not available';
    
    final days = availability.map((a) => a['day'] ?? '').join(', ');
    return days.isNotEmpty ? days : 'Not available';
  }

  // Helper method to get languages as a formatted string
  String get languagesString {
    return languages.join(', ');
  }

  // Helper method to check if doctor is available today
  bool get isAvailableToday {
    if (availability.isEmpty) return false;
    
    final today = DateTime.now().weekday;
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todayName = dayNames[today - 1];
    
    return availability.any((a) => a['day'] == todayName);
  }

  // Helper method to get consultation fee as formatted string
  String get consultationFeeFormatted {
    return '₹${consultationFee.toInt()}';
  }

  // Helper method to get rating as formatted string
  String get ratingFormatted {
    return rating.toStringAsFixed(1);
  }
}
