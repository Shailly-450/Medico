class Hospital {
  final String id;
  final String name;
  final String type;
  final String location;
  final double rating;
  final double distance;
  final int availableDoctors;
  final bool isOpen;
  final String? imageUrl;
  final String? description;
  final List<String> specialties;
  final Map<String, dynamic>? contactInfo;
  final double? latitude;
  final double? longitude;

  Hospital({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.rating,
    required this.distance,
    required this.availableDoctors,
    required this.isOpen,
    this.imageUrl,
    this.description,
    this.specialties = const [],
    this.contactInfo,
    this.latitude,
    this.longitude,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      availableDoctors: json['availableDoctors'] ?? 0,
      isOpen: json['isOpen'] ?? false,
      imageUrl: json['imageUrl'],
      description: json['description'],
      specialties: List<String>.from(json['specialties'] ?? []),
      contactInfo: json['contactInfo'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'location': location,
      'rating': rating,
      'distance': distance,
      'availableDoctors': availableDoctors,
      'isOpen': isOpen,
      'imageUrl': imageUrl,
      'description': description,
      'specialties': specialties,
      'contactInfo': contactInfo,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
} 