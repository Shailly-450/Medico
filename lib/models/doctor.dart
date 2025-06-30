class Doctor {
  final String name;
  final String imageUrl;
  final String specialty;
  final String hospital;
  final double rating;
  final int reviews;
  final double price;
  final bool isOnline;

  Doctor({
    required this.name,
    required this.imageUrl,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.isOnline,
  });

  // Factory constructor to create Doctor from JSON
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      specialty: json['specialty'] as String,
      hospital: json['hospital'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviews: json['reviews'] as int,
      price: (json['price'] as num).toDouble(),
      isOnline: json['isOnline'] as bool,
    );
  }

  // Convert Doctor to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'specialty': specialty,
      'hospital': hospital,
      'rating': rating,
      'reviews': reviews,
      'price': price,
      'isOnline': isOnline,
    };
  }
} 