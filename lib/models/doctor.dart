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
  final bool videoCall;
  final List<String> symptoms;

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
    required this.videoCall,
    this.symptoms = const [],
  });

  // Factory constructor to create Doctor from JSON
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      hospital: json['hospital'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviews: json['reviews'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      price: (json['price'] ?? 0.0).toDouble(),
      videoCall: json['videoCall'] ?? false,
      symptoms: List<String>.from(json['symptoms'] ?? []),
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
      'videoCall': videoCall,
      'symptoms': symptoms,
    };
  }
} 